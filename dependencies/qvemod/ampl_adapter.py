import argparse
import csv
from json import dump

# Add the QVEmod package to the system path. Needed to import corona_model as 
# a module
import sys
import os
filename = os.path.join(
    os.path.dirname(__file__)
)

if not filename in sys.path:
    sys.path.append(filename)

# Load the corona_model dependencies
from corona_model.agent import Agent
from corona_model.actions import *
from corona_model.barriers import Wall
from corona_model.environment import Environment
from corona_model.model import Model


def get_max_agent_move(agent):
    max_x, max_y = 0, 0
    for move in agent.script.values():
        max_x = max(max_x, move.x)
        max_y = max(max_y, move.y)
    return max_x, max_y


def create_agents(in_fname, distance_conversion=10, default_emit_rate_air=.52, default_emit_rate_droplet=.47, default_pick_up_air=2.3, default_pick_up_droplet=2.3):
    with open(in_fname, 'r') as in_file:
        reader = csv.DictReader(in_file)
        raw_script = list(reader)

    unique_agents = set([l['agent'] for l in raw_script])
    raw_script_lookup = {agent: list() for agent in unique_agents}

    max_time_step = 0
    for l in raw_script:
        l['time_step'] = int(l['time_step'])
        max_time_step = max(l['time_step'], max_time_step)
        l['x'] = max(int(float(l['x']) * distance_conversion), 0)
        l['y'] = max(int(float(l['y']) * distance_conversion), 0)
        raw_script_lookup[l['agent']].append(l)

    agents = list()
    for agent, raw_script in raw_script_lookup.items():
        action = raw_script[0]

        script = dict()
        script[action['time_step']] = Enter(action['x'], action['y'])
        prev_x, prev_y = action['x'], action['y']

        for action in raw_script[1:]:
            script[action['time_step']] = Move(action['x'] - prev_x,
                                               action['y'] - prev_y)
            prev_x, prev_y = action['x'], action['y']

        agents.append(Agent(agent, 0, 0, 0, 0,
                            default_emit_rate_air,
                            default_emit_rate_droplet, 
                            default_pick_up_air,
                            default_pick_up_droplet,
                            script)
                    )
    return agents, max_time_step


def create_environment(walls_fname, width, height, distance_conversion=10, decay_rate_air=1.51, decay_rate_surface=0.262, decay_rate_droplet=0.3, air_exchange_rate=0.2, droplet_to_surface_transfer_rate=18.18):

    with open(walls_fname, 'r') as in_file:
        reader = csv.DictReader(in_file)
        raw_walls = list(reader)
    raw_walls = [{k: int(float(v) * distance_conversion) for k, v in row.items()} for row in raw_walls]

    walls = list()
    for r in raw_walls:
        '''
            AMPL walls are rectangles defined by two points. We need to create four walls.
                 C
             @-------@
           A |       | B
             @-------@
                 D
        '''
        walls.append(Wall(r['x1'], r['y1'], r['x1'], r['y2'])) # A
        walls.append(Wall(r['x2'], r['y2'], r['x2'], r['y1'])) # B
        walls.append(Wall(r['x1'], r['y2'], r['x2'], r['y2'])) # C
        walls.append(Wall(r['x1'], r['y1'], r['x2'], r['y1'])) # D

    env = Environment(height,
                      width,
                      decay_rate_air,
                      decay_rate_droplet,
                      decay_rate_surface,
                      air_exchange_rate,
                      droplet_to_surface_transfer_rate,
                      barriers=walls)

    return env


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--script', default='ampl_sample_script.csv', type=str)
    parser.add_argument('--walls', default='ampl_sample_walls.csv', type=str)
    parser.add_argument('--width', default=405, type=int)
    parser.add_argument('--height', default=255, type=int)
    args = parser.parse_args()

    agents, max_time_step = create_agents(args.script)
    agents[0].viral_load = 1
    env = create_environment(args.walls, args.width, args.height)
    model = Model(max_time_step, env, agents)

    with open('env.json', 'w') as out_file:
        dump(env.serialize(), out_file, indent=4)

    with open('agents.json', 'w') as out_file:
        agents = [agent.serialize() for agent in agents]
        dump(agents, out_file, indent=4)

    model.run()

