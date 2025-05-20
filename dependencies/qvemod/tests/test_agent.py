import unittest
import os
from copy import deepcopy

from corona_model.agent import Agent, Facing
from corona_model.environment import Environment, IllegalAgentPosition
from corona_model.air import Void
from corona_model.model import Model
from corona_model.actions import *


CONFIG = {
    "env": {
        "AirCellSize": 50,
        "MobilityCellSize": 10,
        "AgentReach": 50,
        "SimulationTimeStep": 0.00834,
        "HandwashingContaminationFraction": 0.3,
        "HandwashingEffectDuration": 0.5,
        "MaskEmissionAerosolReductionEfficiency": 0.4,
        "MaskEmissionDropletReductionEfficiency": 0.04,
        "MaskAerosolProtectionEfficiency": 0.4,
        "MaskDropletProtectionEfficiency": 0.04,
        "CleaningInterval": 1,
        "Diffusivity": 23,
        "WallAbsorbingProportion": 0.0,
        "CoughingRate": 0,
        "CoughingFactor": 1000000,
        "CoughingAerosolPercentage": 0.01,
        "CoughingDropletPercentage": 0.99
    },
    "output": {
        "Suppress": True,
        "Path": "output",
        "AerosolContaminationWriteInterval": 15,
        "AerosolContaminationPrecision": 17,
        "DropletContaminationWriteInterval": 15,
        "DropletContaminationPrecision": 17,
        "SurfaceContaminationWriteInterval": 15,
        "SurfaceContaminationPrecision": 17
    }
}


COUGH_CONFIG = deepcopy(CONFIG)
COUGH_CONFIG['env']['CoughingRate'] = 121


class TestAgent(unittest.TestCase):

    def test_serialization(self):
        a = Agent('James Bond', 1, 1, 1, 0, 1, 1, 0, 0, {0: Enter(0, 0, 'N'), 1: Move(1, 0)})
        s = a.serialize()
        afroms = Agent.deserialize(deepcopy(s))  # deserialize will change script dict, need copy
        sfromafroms = afroms.serialize()
        self.assertEqual(s, sfromafroms)

    def test_agent_movement(self):
        e = Environment(5, 5, 0, 0, 0, 0, 0)
        a = Agent('James Bond', 1, 1, 1, 0, 1, 1, 0, 0, {
            0: Enter(0, 0, 'N'),
            1: Move(0, 1),
            2: Move(1, 0),
            3: Move(1, 0),
            4: Move(1, 0),
        })
        m = Model(5, e, [a])
        m.run(CONFIG)
        self.assertEqual((3, 1), m.env.agent_lookup[a])

    def test_agent_movement_to_north(self):
        e = Environment(5, 5, 0, 0, 0, 0, 0)
        a = Agent('James Bond', 1, 1, 1, 0, 1, 1, 0, 0, {
            0: Enter(2, 2, 'S'),
            1: Move(0, 1),
        })
        m = Model(2, e, [a])
        m.run(CONFIG)
        self.assertEqual((2, 3), m.env.agent_lookup[a])
        self.assertEqual(a.facing, Facing.NORTH)

    def test_agent_movement_to_east(self):
        e = Environment(5, 5, 0, 0, 0, 0, 0)
        a = Agent('James Bond', 1, 1, 1, 0, 1, 1, 0, 0, {
            0: Enter(2, 2),
            1: Move(1, 0),
        })
        m = Model(2, e, [a])
        m.run(CONFIG)
        self.assertEqual((3, 2), m.env.agent_lookup[a])
        self.assertEqual(a.facing, Facing.EAST)

    def test_agent_movement_to_south(self):
        e = Environment(5, 5, 0, 0, 0, 0, 0)
        a = Agent('James Bond', 1, 1, 1, 0, 1, 1, 0, 0, {
            0: Enter(2, 2),
            1: Move(0, -1),
        })
        m = Model(2, e, [a])
        m.run(CONFIG)
        self.assertEqual((2, 1), m.env.agent_lookup[a])
        self.assertEqual(a.facing, Facing.SOUTH)

    def test_agent_movement_to_west(self):
        e = Environment(5, 5, 0, 0, 0, 0, 0)
        a = Agent('James Bond', 1, 1, 1, 0, 1, 1, 0, 0, {
            0: Enter(2, 2),
            1: Move(-1, 0),
        })
        m = Model(2, e, [a])
        m.run(CONFIG)
        self.assertEqual((1, 2), m.env.agent_lookup[a])
        self.assertEqual(a.facing, Facing.WEST)

    def test_agent_movement_to_east_but_set_west(self):
        e = Environment(5, 5, 0, 0, 0, 0, 0)
        a = Agent('James Bond', 1, 1, 1, 0, 1, 1, 0, 0, {
            0: Enter(2, 2),
            1: Move(1, 0, 'W'),
        })
        m = Model(2, e, [a])
        m.run(CONFIG)
        self.assertEqual((3, 2), m.env.agent_lookup[a])
        self.assertEqual(a.facing, Facing.WEST)

    def test_action_enter(self):
        e = Environment(25, 25, 0, 0, 0, 0, 0)
        a = Agent('James Bond', 1, 1, 1, 0, 1, 1, 0, 0, {0: Enter(13, 13, 'N')}, wearing_mask=True)
        m = Model(2, e, [a])
        m.run(CONFIG)
        self.assertEqual(e.agent_lookup[a], (13, 13))
        self.assertEqual(a.facing.value, 'N')

    def test_action_enter_facing(self):
        e = Environment(25, 25, 0, 0, 0, 0, 0)
        a = Agent('James Bond', 1, 1, 1, 0, 1, 1, 0, 0, {0: Enter(13, 13, facing='S')}, wearing_mask=True)
        m = Model(2, e, [a])
        m.run(CONFIG)
        self.assertEqual(e.agent_lookup[a], (13, 13))
        self.assertEqual(a.facing.value, 'S')

    def test_action_enter_without_facing(self):
        e = Environment(25, 25, 0, 0, 0, 0, 0)
        a = Agent('James Bond', 1, 1, 1, 0, 1, 1, 0, 0, {0: Enter(13, 13)}, wearing_mask=True)
        m = Model(2, e, [a])
        m.run(CONFIG)
        self.assertEqual(e.agent_lookup[a], (13, 13))
        self.assertEqual(a.facing.value, 'N')

    def test_action_face(self):
        e = Environment(25, 25, 0, 0, 0, 0, 0)
        a = Agent('James Bond', 1, 1, 1, 0, 1, 1, 0, 0, {0: Enter(13, 13, 'N'), 1: Face('S')}, wearing_mask=True)
        m = Model(2, e, [a])
        m.run(CONFIG)
        self.assertEqual(e.agent_lookup[a], (13, 13))
        self.assertEqual(a.facing.value, 'S')

    def test_illegal_position_move(self):
        v = [Void(0, 1)]
        e = Environment(10, 5, 0, 0, 0, 0, 0, walls=v)
        a = Agent('Oscar', 0, 0, 0, 0, 0, 0, 0, 0, {0: Enter(2, 3, 'N'), 1: Move(0, 5)})
        m = Model(2, e, [a])
        self.assertRaises(IllegalAgentPosition, m.run, CONFIG)
    def test_illegal_position_enter(self):
        v = [Void(0, 1)]
        e = Environment(10, 5, 0, 0, 0, 0, 0, walls=v)
        a = Agent('Oscar', 0, 0, 0, 0, 0, 0, 0, 0, {0: Enter(2, 8, 'N')})
        m = Model(2, e, [a])
        self.assertRaises(IllegalAgentPosition, m.run, CONFIG)

    def test_coughing(self):
        e = Environment(30, 30, 0, 0, 0, 0, 0)
        a = Agent('Ted', 1, 0, 0, 0, 0, 0, 0, 0, {0: Enter(5, 5, 'N')})
        a.emission_rate_air = 1.0
        m = Model(1, e, [a])
        m.run(COUGH_CONFIG)
        self.assertNotEqual(0, m.env.air.get_aerosol(0, 20))
        self.assertEqual(0, m.env.air.get_aerosol(0, 25))

        self.assertNotEqual(0, m.env.air.get_aerosol(1, 20))
        self.assertEqual(0, m.env.air.get_aerosol(1, 25))

        self.assertNotEqual(0, m.env.air.get_aerosol(2, 20))
        self.assertEqual(0, m.env.air.get_aerosol(2, 25))

    def test_anti_coughing(self):
        e = Environment(101, 101, 0, 0, 0, 0, 0)
        a = Agent('Ted', 1, 0, 0, 0, 0, 0, 0, 0, {0: Enter(50, 50, 'N')})
        m = Model(1, e, [a])
        m.run(CONFIG)
        self.assertEqual(0, sum(sum(m.env.air._aerosols, [])))
        self.assertEqual(0, sum(sum(m.env.air._droplets, [])))


if __name__ == '__main__':
    unittest.main()

