import unittest
import os
from copy import deepcopy

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
from corona_model.air import Void
from corona_model.model import Model
from corona_model.actions import Enter, Leave
from corona_model.barriers import Wall, Shield


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


class TestModel(unittest.TestCase):

    def test_serialization(self):
        e = Environment(25, 25, 0, 0, 0, 0, 0,
                        barriers=[Wall(2, 2, 2, 3), Shield(1, 1, 1, 2)],
                        walls=[Void(4, 4)])
        a = Agent('James Bond', 1, 1, 1, 0, 1, 1, 0, 0, {0: Enter(0, 0, 'N')})
        m = Model(5, e, [a])
        s = m.serialize()
        mfroms = Model.deserialize(deepcopy(s))
        sfrommfroms = mfroms.serialize()
        self.assertEqual(s, sfrommfroms)

    def test_mask_emission(self):
        env1 = Environment(25, 25, 0, 0, 0, 0, 0)
        env2 = Environment(25, 25, 0, 0, 0, 0, 0)
        biden = Agent('Joe Biden', 1, 1, 1, 0, 1, 1, 0, 0, {0: Enter(13, 13, 'N')}, wearing_mask=True)
        trump = Agent('Donald Trump', 1, 1, 1, 0, 1, 1, 0, 0, {0: Enter(13, 13, 'N')}, wearing_mask=False)
        model1 = Model(5, env1, [biden])
        model2 = Model(5, env2, [trump])
        model1.run(CONFIG)
        model2.run(CONFIG)
        self.assertLess(sum(sum(env1.air._aerosols, [])), sum(sum(env2.air._aerosols, [])))
        self.assertLess(sum(sum(env1.air._droplets, [])), sum(sum(env2.air._droplets, [])))

    def test_void_coughing_parallel(self):
        v = [Void(2, 0), Void(2, 1), Void(2, 2), Void(2, 3), Void(2, 4)]
        e = Environment(25, 25, 0.1, 0.1, 0, 0.1, 0, walls=v)
        a = Agent('Oscar', 1, 1, 1, 0, 1, 1, 0, 0, {0: Enter(15, 2, 'N')})
        m = Model(15, e, [a])
        m.run(COUGH_CONFIG)
        for x in range(2):
            for y in range(e.air._height):
                assert e.air._get_aerosol(x, y) == 0
                assert e.air._get_droplet(x, y) == 0

    def test_void_no_coughing(self):
        v = [Void(2, 0), Void(2, 1), Void(2, 2), Void(2, 3), Void(2, 4)]
        e = Environment(25, 25, 0.1, 0.1, 0, 0.1, 0, walls=v)
        a = Agent('Oscar', 1, 1, 1, 0, 1, 1, 0, 0, {0: Enter(15, 2, 'N')})
        m = Model(15, e, [a])
        m.run(CONFIG)
        for x in range(2):
            for y in range(e.air._height):
                assert e.air._get_aerosol(x, y) == 0
                assert e.air._get_droplet(x, y) == 0

    def test_walls(self):
        w = [Wall(2, 0, 2, 5)]
        e = Environment(25, 20, 0.1, 0.1, 0, 0.1, 0, barriers=w)
        a = Agent('Oscar', 1, 1, 1, 0, 1, 1, 0, 0, {0: Enter(15, 2, 'N')})
        m = Model(15, e, [a])
        m.run(CONFIG)
        for x in range(2):
            for y in range(e.air._height):
                assert e.air._get_aerosol(x, y) == 0
                assert e.air._get_droplet(x, y) == 0

    def test_walls_coughing_parallel(self):
        w = [Wall(2, 0, 2, 5)]
        e = Environment(25, 20, 0.1, 0.1, 0, 0.1, 0, barriers=w)
        a = Agent('Oscar', 1, 1, 1, 0, 1, 1, 0, 0, {0: Enter(15, 2, facing='N')})
        m = Model(15, e, [a])
        m.run(COUGH_CONFIG)
        for x in range(2):
            for y in range(e.air._height):
                assert e.air._get_aerosol(x, y) == 0
                assert e.air._get_droplet(x, y) == 0

    def test_shields(self):
        s = [Shield(3, 0, 3, 5)]
        e = Environment(25, 25, 0.1, 0.1, 0, 0.1, 0, barriers=s)
        a = Agent('Oscar', 1, 1, 1, 0, 1, 1, 0, 0, {0: Enter(15, 2, 'N')})
        m = Model(15, e, [a])
        m.run(CONFIG)
        for x in range(2):
            for y in range(e.air._height):
                self.assertNotEqual(0, e.air._get_aerosol(x, y))
                self.assertEqual(0, e.air._get_droplet(x, y))

    def test_agent_leave_reenter(self):
        e = Environment(25, 25, 0, 0, 0, 0, 0)
        script = {0: Enter(10, 10), 2: Leave(), 8: Enter(15, 15)}
        a = Agent('Joe', 1, 0, 0, 0, 1, 1, 0, 0, script)

        def checker(model, tick):
            if tick == 1:
                self.assertEqual((10, 10), model.env.agent_lookup.get(a))
            elif tick == 3:
                self.assertIsNone(model.env.agent_lookup.get(a))
            elif tick == 9:
                self.assertEqual((15, 15), model.env.agent_lookup.get(a))
        m = Model(10, e, [a])
        m.run(CONFIG, callback=checker)

    def test_agent_no_script(self):
        e = Environment(25, 25, 0, 0, 0, 0, 0)
        script = {}
        a = Agent('Joe', 1, 0, 0, 0, 1, 1, 0, 0, script)
        Model(10, e, [a])

if __name__ == '__main__':
    unittest.main()
