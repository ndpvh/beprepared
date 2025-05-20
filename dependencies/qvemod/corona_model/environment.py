import warnings
import math
from typing import Dict, List, Tuple, Union

from corona_model.agent import Agent

from corona_model.barriers import Wall, Shield
from corona_model.emissionpatterns import droplet_cough, aerosol_cough
from corona_model.air import Air, Void
from corona_model.facing import Facing
from corona_model.surfaces import Surface, Item, Fixture




class IllegalAgentPosition(Exception):
    pass


class Environment:

    def __init__(self, height, width, decay_rate_air, decay_rate_droplet, decay_rate_surface, air_exchange_rate,
                 droplet_to_surface_transfer_rate, barriers: List[Union[Wall, Shield]] = (), walls: List[Void] = ()):
        self.height = height  # the coordinates for the surface layer
        self.width = width
        self.air = None

        self.barriers: List[Union[Wall, Shield]] = barriers
        self.walls: List[Void] = walls
        self.decay_rate_air = decay_rate_air
        self.decay_rate_surface = decay_rate_surface
        self.decay_rate_droplet = decay_rate_droplet
        self.air_exchange_rate = air_exchange_rate  # only influence on the aerosols concentration in the room
        self.droplet_to_surface_transfer_rate = droplet_to_surface_transfer_rate
        self.mobility_space: List[List[Union[Agent, None]]] = [[None for _ in range(0, height)] for _ in range(0, width)]
        self.surfaces: List[List[List[Surface]]] = [[[] for _ in range(0, height)] for _ in range(0, width)]
        self.agent_lookup: Dict[Agent, Tuple[int, int]] = {}

        self.config = None
        self.reach = None

    def set_config(self, config):
        self.config = config
        self.reach = int(config['env']['AgentReach'] / config['env']['MobilityCellSize'])
        self.mobility_ratio = config['env']['MobilityCellSize'] / config['env']['AirCellSize']
        self.air = Air(config, self.width, self.height, self.decay_rate_air, self.decay_rate_droplet, self.air_exchange_rate, self.barriers, self.walls)

    def serialize(self):
        return {
            'height': self.height,
            'width': self.width,
            'decay_rate_air': self.decay_rate_air,
            'decay_rate_surface': self.decay_rate_surface,
            'decay_rate_droplet': self.decay_rate_droplet,
            'air_exchange_rate': self.air_exchange_rate,
            'droplet_to_surface_transfer_rate': self.droplet_to_surface_transfer_rate,
            'barriers': [b.serialize() for b in self.barriers],
            'walls': [w.serialize() for w in self.walls],
        }

    @classmethod
    def deserialize(cls, serial):
        serial['barriers']: List[Union[Wall, Shield]] = (
            [Wall.deserialize(b) for b in serial['barriers'] if b['type'] == "wall"] +
            [Shield.deserialize(b) for b in serial['barriers'] if b['type'] == "shield"]
        )
        serial['walls'] = [Void.deserialize(w) for w in serial["walls"]]
        return Environment(**serial)

    def place_surfaces(self, surfaces):
        """Take all surface lists and place them in surfaces layer"""
        for surface in surfaces:
            if isinstance(surface, Surface):
                self.surfaces[surface.init_x][surface.init_y].append(surface)

    def apply_entry(self, agent: Agent, entry):
        if self.air.is_void(entry.x, entry.y):
            raise IllegalAgentPosition
        self.mobility_space[entry.x][entry.y] = agent
        self.agent_lookup[agent] = entry.x, entry.y  # x and y using surface coordinate
        agent.set_facing(entry.facing)
        agent.is_active = True

    @staticmethod
    def get_direction(x1, y1, x2, y2):
        r = math.atan2(y2 - y1, x2 - x1)
        d = math.degrees(r)
        if 45 <= d <= 135:
            return 'N'
        elif -45 <= d <= 45:
            return 'E'
        elif -135 <= d <= -45:
            return 'S'
        else:
            return 'W'

    def process_agent_action(self, agent: Agent, action):
        if action.type == 'enter':
            self.apply_entry(agent, action)
        elif agent.is_active:
            cur_x, cur_y = self.agent_lookup[agent]
            if action.type == 'move':
                new_x = cur_x + action.x
                new_y = cur_y + action.y  
                if self.air.is_void(new_x, new_y):
                    raise IllegalAgentPosition
                agent.set_facing(action.facing or Environment.get_direction(cur_x, cur_y, new_x, new_y))
                # Move self
                self.mobility_space[cur_x][cur_y] = None
                self.mobility_space[new_x][new_y] = agent
                self.agent_lookup[agent] = new_x, new_y
                # Move held Items
                for item in agent.held:
                    self.surfaces[cur_x][cur_y].remove(item)
                    self.surfaces[new_x][new_y].append(item)
            elif action.type == 'leave':
                self.mobility_space[cur_x][cur_y] = None
                del self.agent_lookup[agent]  # Remove agent from environment
                for item in agent.held:  # Also remove all items agent had
                    self.surfaces[cur_x][cur_y].remove(item)
                agent.is_active = False
            elif action.type == 'pickup' or action.type == 'putdown':
                # TODO: Pickup and Putdown do not use AgentReach and are currently limited to their own cell
                items = [i for i in self.surfaces[cur_x][cur_y]
                         if isinstance(i, Item) and i.name == action.target]
                if len(items) > 1:
                    warnings.warn("Too many Items found with target name: {}".format(action.target))
                elif len(items) < 1:
                    warnings.warn("No Items found with target name: {}". format(action.target))
                else:
                    item = items.pop()
                    if action.type == 'pickup':
                        agent.hold(item)
                    elif action.type == 'putdown':
                        agent.release(item)
            elif action.type == 'handwash':
                agent.start_handwash_effect()
            elif action.type == 'donmask':
                agent.don_mask()
            elif action.type == 'doffmask':
                agent.doff_mask()
            elif action.type == 'face':
                agent.set_facing(action.direction)

    def add_load_air(self, agent: Agent):
        if self.agent_lookup.get(agent) is not None:
            x, y = self.agent_lookup[agent]
            if agent.queued_cough:
                direction = Facing(agent.facing.value)
                self.air.add_aerosol_pattern(x, y, agent.emit_aerosol(), aerosol_cough, direction)
                self.air.add_droplet_pattern(x, y, agent.emit_droplet(), droplet_cough, direction)
                agent.queued_cough = False  # Done processing cough
            else:
                self.air.add_aerosol(x, y, agent.emit_aerosol())
                self.air.add_droplet(x, y, agent.emit_droplet())

    def pickup_air(self, agent: Agent):
        if self.agent_lookup.get(agent) is not None:
            x, y = self.agent_lookup[agent]
            air_load = self.air.get_aerosol(x, y)
            agent.pickup_air(air_load, agent.pick_up_air)
            self.air.subtract_aerosol(x, y, agent.contamination_load_air)

    def pickup_droplet(self, agent: Agent):
        if self.agent_lookup.get(agent) is not None:
            x, y = self.agent_lookup[agent]
            droplet_load = self.air.get_droplet(x, y)
            agent.pickup_droplet(droplet_load, agent.pick_up_droplet)
            self.air.subtract_droplet(x, y, agent.contamination_load_droplet)

    def pickup_fixtures(self, agent: Agent):
        """If an Agent is active pickup contamination load from Surfaces"""
        if self.agent_lookup.get(agent) is not None:
            fixtures = []
            for x, y in self.reachable_surfaces(*self.agent_lookup[agent]):
                fixtures += [f for f in self.surfaces[x][y] if isinstance(f, Fixture)]
            for surface in fixtures:
                agent.pickup_from_surface(surface)

    def hand_contaminate_fixtures(self, agent: Agent):
        if self.agent_lookup.get(agent) is not None:
            fixtures = []
            for x, y in self.reachable_surfaces(*self.agent_lookup[agent]):
                fixtures += [f for f in self.surfaces[x][y] if isinstance(f, Fixture)]
            for surface in fixtures:
                agent.hand_to_surface_transfer(surface)

    def cleaning_surface(self):
        for x in range(0, self.width):
            for y in range(0, self.height):
                for surface in self.surfaces[x][y]:
                    if isinstance(surface, Fixture):
                        surface.contamination_load = 0

    def decay_surface(self):
        for x in range(0, self.width):
            for y in range(0, self.height):
                for surface in self.surfaces[x][y]:
                    surface.contamination_load *= math.exp(-surface.surface_decay_rate *
                                                           self.config['env']['SimulationTimeStep'])

    def decay_air(self):
        self.air.decay()

    def diffuse_air(self):
        self.air.diffuse()

    def droplet_to_surface_transfer(self):
        """Executed every tick to transfer droplets to surfaces"""
        for x in range(0, self.width):
            for y in range(0, self.height):
                for surface in self.surfaces[x][y]:  # If performance becomes a problem use a lookup like Agents do
                    # Process Fixtures
                    if isinstance(surface, Fixture):
                        surface.contamination_load += (
                                self.air.get_droplet(x, y) / (self.mobility_ratio**2) *
                                self.droplet_to_surface_transfer_rate *
                                self.config['env']['SimulationTimeStep']
                        )

    def surface_lookup(self, surface: Surface) -> Tuple[int, int]:
        if isinstance(surface, Fixture):
            return surface.init_x, surface.init_y
        for x in range(self.width):
            for y in range(self.height):
                if surface in self.surfaces[x][y]:
                    return x, y

    def reachable_surfaces(self, x: int, y: int) -> List[Tuple[int, int]]:
        """Get a list of surface coordinates in a reachable square around points x and y
        Filter out coordinates that are not in the grid
        Return empty list if center coordinates are not in grid"""
        if not 0 <= x < self.width or not 0 <= y < self.height:
            return []
        return [(x1, y1)
                for x1 in range(x - self.reach // 2, x + self.reach // 2 + 1)
                if x1 >= 0
                if x1 < self.width
                for y1 in range(y - self.reach // 2, y + self.reach // 2 + 1)
                if y1 >= 0
                if y1 < self.height]

    def __str__(self):
        to_print = str()
        for x in range(0, self.width):
            for y in range(0, self.height):
                if self.mobility_space[x][y] is not None:
                    to_print += self.mobility_space[x][y].name[0]
                else:
                    to_print += '-'
            to_print += '\n'
        return to_print

