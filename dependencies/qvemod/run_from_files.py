import argparse
from json import loads, dumps

from corona_model.agent import Agent
from corona_model.environment import Environment
from corona_model.model import Model



if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--agents', default='agents.json', type=str)
    parser.add_argument('--env', default='env.json', type=str)
    parser.add_argument('--config', default='default_config.json', type=str)
    parser.add_argument('--time_step', default=1000, type=int)
    args = parser.parse_args()

    with open(args.env, 'r') as in_file:
        env = Environment.deserialize(loads(in_file.read()))

    with open(args.agents, 'r') as in_file:
        agents = [Agent.deserialize(a) for a in loads(in_file.read())]

    with open(args.config, 'r') as in_file:
        config = loads(in_file.read())

    #infect an agent
    agents[0].viral_load = 1

    model = Model(args.time_step, env, agents)
    model.run(config)

