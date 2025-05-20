from json import loads, dumps

from corona_model.agent import Agent
from corona_model.environment import Environment
from corona_model.air import Void as Wall
from corona_model.model import Model
from corona_model.actions import *
from corona_model.surfaces import Item, Fixture


def create_dummy_model(height=25, width=25, ticks=5, decay_rate_air=1.51, decay_rate_surface=0.262,decay_rate_droplet=0.3,
                       air_exchange_rate=0.2, droplet_to_surface_transfer_rate=18.18):
    walls = [Wall(4, 0), Wall(4, 1)]
    env = Environment(height, width, decay_rate_air, decay_rate_droplet, decay_rate_surface, air_exchange_rate,
                      droplet_to_surface_transfer_rate, walls=walls)
    garcon = Agent('Garcon', 1, 0,0,1,0.53,0.47,2.3,2.3,
                   {
            1: Enter(0, 0, 'N'),
            2: Move(2, 2),
            4: Pickup('Menu'),
            5: Putdown('Menu'),
            6: Move(-1, -1),  # Garcon enters and then walks Pacman style to the other corner, see environment.py:69
            7: Move(-1, 0),
            9: Move(0, -1),
            10: Move(0, -1),
            11: DoffMask(),
            13: Move(1, 1),
            14: Move(0, 1),
            15: Move(0, 1),
        },
        
    )

    oscar = Agent('Oscar', 0, 0, 0,0,0.53,0.47,30,30,
        {
            0: Enter(0, 0, 'N'),
            1: Move(1, 1),
            20: Leave(),
        } 
        
    )
    vigo = Agent('Vigo', 0, 0, 0,0,0.53,0.47,30,30,
        {
            1: Enter(0, 0, 'N'),
            2: Move(0, 1),
            3: Move(0, 1),
            4: Move(0, 1),
            5: Move(1, 0),
            30: Leave(),
        }
    )
    agents = [garcon, oscar, vigo]

    items = [
        Item('Menu', 1, 3, 0.7, 0.2, 0.274),
        Item('Fork', 1, 2, 0.3, 0.05, 0.2)
    ]
    fixtures = [
        Fixture('Table', 1, 1, 0.5, 0.8, 15, 0.969),
        Fixture('Chair', 1, 2, 0.5, 0.4, 15, 0.969)
    ]
    surfaces = items + fixtures

    model = Model(ticks, env, agents, surfaces=surfaces)

    with open('model.json', 'w') as out_file:
        out_file.write(dumps(model.serialize()))


def main(model_fname, config_fname):
    with open(config_fname, 'r') as in_file:
        config = loads(in_file.read())

    with open(model_fname, 'r') as in_file:
        model = Model.deserialize(loads(in_file.read()))

    model.run(config)
    print(model.air_exposure())
    print(model.droplet_exposure())
    print(model.surface_exposure())


if __name__ == '__main__':
    create_dummy_model()
    main('model.json', 'default_config.json')

