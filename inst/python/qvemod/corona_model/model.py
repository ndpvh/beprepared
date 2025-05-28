import math

# Add the QVEmod package to the system path. Needed to import corona_model as 
# a module
import sys
import os
filename = os.path.join(
    os.path.dirname(__file__),
    ".."
)

if not filename in sys.path:
    sys.path.append(filename)

# Load the corona_model dependencies
from corona_model.agent import Agent
from corona_model.environment import Environment
from corona_model.surfaces import Item, Fixture
from corona_model.writers import (
    AgentExposureWriter, AerosolContaminationWriter, DropletContaminationWriter, SurfaceContaminationWriter
)


class Model:
    def __init__(self, ticks, env, agents, surfaces=(), name=''):
        self.ticks = ticks
        self.env = env
        self.agents = agents
        self.surfaces = surfaces
        self.name = name
        self.termination_routines = []

        # No duplicate Surface names
        names = [surface.name for surface in self.surfaces]
        assert not [name for name in names if names.count(name) > 1], "Duplicate name found in surfaces"

    @classmethod
    def deserialize(cls, serial):
        serial['env'] = Environment.deserialize(serial['env'])
        serial['agents'] = [Agent.deserialize(a) for a in serial['agents']]
        # combine surface types
        serial['surfaces'] = \
            [Item.deserialize(i) for i in serial['items']] + \
            [Fixture.deserialize(f) for f in serial['fixtures']]
        # remove old keys
        del serial['items']
        del serial['fixtures']

        return Model(**serial)

    def serialize(self):
        return {
            'name': self.name,
            'ticks': self.ticks,
            'env': self.env.serialize(),
            'agents': [agent.serialize() for agent in self.agents],
            'items': [s.serialize() for s in self.surfaces if isinstance(s, Item)],
            'fixtures': [s.serialize() for s in self.surfaces if isinstance(s, Fixture)],
        }

    def run(self, config, callback=None):
        # setup writers
        agent_exposure_writer = None
        aerosol_contamination_writer = None
        droplet_contamination_writer = None
        surface_contamination_writer = None
        if not config['output']['Suppress']:
            agent_exposure_writer = AgentExposureWriter(config)
            self.termination_routines.append(lambda: agent_exposure_writer.close())
            aerosol_contamination_writer = AerosolContaminationWriter(config)
            self.termination_routines.append(lambda: aerosol_contamination_writer.close())
            droplet_contamination_writer = DropletContaminationWriter(config)
            self.termination_routines.append(lambda: droplet_contamination_writer.close())
            surface_contamination_writer = SurfaceContaminationWriter(config)
            self.termination_routines.append(lambda: surface_contamination_writer.close())

        # setup environment
        self.env.place_surfaces(self.surfaces)
        self.env.set_config(config)

        for agent in self.agents:
            agent.set_config(config)

        # main loop
        for tick in range(0, self.ticks):
            for agent in self.agents:
                if tick in agent.script:
                    self.env.process_agent_action(agent, agent.script[tick])

            for agent in self.agents:
                if agent.is_active:
                    self.env.pickup_air(agent)
                    self.env.pickup_droplet(agent)
                    # If the Agent is infected surface pickup is negligible so skip; only susceptible Agents
                    if agent.viral_load == 0:
                        self.env.pickup_fixtures(agent)
                    if agent.viral_load > 0:
                        self.env.hand_contaminate_fixtures(agent)
                    agent.process_effects()
            if tick % math.ceil(config['env']['CleaningInterval'] / config['env']['SimulationTimeStep']) == 0:
                self.env.cleaning_surface()
            self.env.diffuse_air()
            self.env.droplet_to_surface_transfer()
            self.env.decay_air()
            self.env.decay_surface()

            for agent in self.agents:
                if agent.is_active:
                    self.env.add_load_air(agent)

            if agent_exposure_writer:
                for agent in self.agents:
                    if agent.is_active:
                        agent_exposure_writer.write(agent.name, tick, agent.contamination_load_air,
                                                    agent.contamination_load_droplet,
                                                    agent.contamination_load_surface_accumulation,
                                                    config['env']['SimulationTimeStep'] * agent.contamination_load_surface_accumulation * config['env']['SurfaceExposureRatio'])
            if aerosol_contamination_writer and tick % config['output']['AerosolContaminationWriteInterval'] == 0:
                for x in range(self.env.air._width):
                    for y in range(self.env.air._height):
                        if self.env.air._get_aerosol(x, y) is not None:
                            aerosol_contamination_writer.write(tick, x, y, self.env.air._get_aerosol(x, y))
            if droplet_contamination_writer and tick % config['output']['DropletContaminationWriteInterval'] == 0:
                for x in range(self.env.air._width):
                    for y in range(self.env.air._height):
                        if self.env.air._get_droplet(x, y) is not None:
                            droplet_contamination_writer.write(tick, x, y, self.env.air._get_droplet(x, y))
            if surface_contamination_writer and tick % config['output']['SurfaceContaminationWriteInterval'] == 0:
                for surface in self.surfaces:
                    surface_contamination_writer.write(surface.name, surface.__class__.__name__, tick,
                                                       *self.env.surface_lookup(surface), surface.contamination_load)

            if callback is not None:
                callback(model=self, tick=tick)

        self.terminate(condition=0)

    def terminate(self, condition=99):
        for routine in self.termination_routines:
            routine()
        if condition != 0:  # Skip exit call on clean termination for tests or wrappers
            exit(condition)  # Condition defaults to a unique 99 to indicate early termination

    def air_exposure(self):
        return {agent.name: agent.contamination_load_air for agent in self.agents}

    def droplet_exposure(self):
        return {agent.name: agent.contamination_load_droplet for agent in self.agents}

    def surface_exposure(self):
        return {agent.name: agent.contamination_load_surface_accumulation for agent in self.agents}

