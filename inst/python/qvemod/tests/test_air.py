import unittest

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
from corona_model.air import Air, Void
from corona_model.facing import Facing
from corona_model.emissionpatterns import initial_cough
from corona_model.barriers import Shield


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


class TestAir(unittest.TestCase):

    def test_aerosol_emission_pattern_north(self):
        air = Air(CONFIG, 101, 101, 0, 0, 0)
        air.add_aerosol_pattern(50, 50, 2, initial_cough, Facing.NORTH)
        self.assertNotEqual(0, air.get_aerosol(50, 50))
        self.assertNotEqual(0, air.get_aerosol(50, 55))
        self.assertNotEqual(0, air.get_aerosol(50, 60))
        self.assertNotEqual(0, air.get_aerosol(50, 65))
        self.assertNotEqual(0, air.get_aerosol(50, 70))
        self.assertNotEqual(0, air.get_aerosol(40, 70))
        self.assertNotEqual(0, air.get_aerosol(60, 70))
        self.assertEqual(0, air.get_aerosol(50, 75))
        self.assertEqual(0, air.get_aerosol(50, 45))

    def test_droplet_emission_pattern_north(self):
        air = Air(CONFIG, 101, 101, 0, 0, 0)
        air.add_droplet_pattern(50, 50, 2, initial_cough, Facing.NORTH)
        self.assertNotEqual(0, air.get_droplet(50, 50))
        self.assertNotEqual(0, air.get_droplet(50, 55))
        self.assertNotEqual(0, air.get_droplet(50, 60))
        self.assertNotEqual(0, air.get_droplet(50, 65))
        self.assertNotEqual(0, air.get_droplet(50, 70))
        self.assertNotEqual(0, air.get_droplet(40, 70))
        self.assertNotEqual(0, air.get_droplet(60, 70))
        self.assertEqual(0, air.get_droplet(50, 75))
        self.assertEqual(0, air.get_droplet(50, 45))

    def test_aerosol_emission_pattern_south(self):
        air = Air(CONFIG, 101, 101, 0, 0, 0)
        air.add_aerosol_pattern(50, 50, 2, initial_cough, Facing.SOUTH)
        self.assertNotEqual(0, air.get_aerosol(50, 50))
        self.assertNotEqual(0, air.get_aerosol(50, 45))
        self.assertNotEqual(0, air.get_aerosol(50, 40))
        self.assertNotEqual(0, air.get_aerosol(50, 35))
        self.assertNotEqual(0, air.get_aerosol(50, 30))
        self.assertNotEqual(0, air.get_aerosol(40, 30))
        self.assertNotEqual(0, air.get_aerosol(60, 30))
        self.assertEqual(0, air.get_aerosol(50, 25))
        self.assertEqual(0, air.get_aerosol(50, 55))

    def test_aerosol_emission_pattern_east(self):
        air = Air(CONFIG, 101, 101, 0, 0, 0)
        air.add_aerosol_pattern(50, 50, 2, initial_cough, Facing.EAST)
        self.assertNotEqual(0, air.get_aerosol(50, 50))
        self.assertNotEqual(0, air.get_aerosol(55, 50))
        self.assertNotEqual(0, air.get_aerosol(60, 50))
        self.assertNotEqual(0, air.get_aerosol(65, 50))
        self.assertNotEqual(0, air.get_aerosol(70, 50))
        self.assertNotEqual(0, air.get_aerosol(70, 40))
        self.assertNotEqual(0, air.get_aerosol(70, 60))
        self.assertEqual(0, air.get_aerosol(75, 50))
        self.assertEqual(0, air.get_aerosol(45, 50))

    def test_aerosol_emission_pattern_west(self):
        air = Air(CONFIG, 101, 101, 0, 0, 0)
        air.add_aerosol_pattern(50, 50, 2, initial_cough, Facing.WEST)
        self.assertNotEqual(0, air.get_aerosol(50, 50))
        self.assertNotEqual(0, air.get_aerosol(45, 50))
        self.assertNotEqual(0, air.get_aerosol(40, 50))
        self.assertNotEqual(0, air.get_aerosol(35, 50))
        self.assertNotEqual(0, air.get_aerosol(30, 50))
        self.assertNotEqual(0, air.get_aerosol(30, 40))
        self.assertNotEqual(0, air.get_aerosol(30, 60))
        self.assertEqual(0, air.get_aerosol(25, 50))
        self.assertEqual(0, air.get_aerosol(55, 50))

    def test_aerosol_emission_pattern_wall_north(self):
        air = Air(CONFIG, 101, 101, 0, 0, 0, voids=[Void(10, 12)])
        air.add_aerosol_pattern(50, 50, 2, initial_cough, Facing.NORTH)
        self.assertNotEqual(0, air.get_aerosol(50, 50))
        self.assertNotEqual(0, air.get_aerosol(50, 55))
        self.assertIsNone(air.get_aerosol(50, 60))
        self.assertEqual(0, air.get_aerosol(50, 65))
        self.assertNotEqual(0, air.get_aerosol(40, 70))
        self.assertNotEqual(0, air.get_aerosol(60, 70))

    def test_aerosol_emission_pattern_wall_east(self):
        air = Air(CONFIG, 101, 101, 0, 0, 0, voids=[Void(12, 10)])
        air.add_aerosol_pattern(50, 50, 2, initial_cough, Facing.EAST)
        self.assertNotEqual(0, air.get_aerosol(50, 50))
        self.assertNotEqual(0, air.get_aerosol(55, 50))
        self.assertIsNone(air.get_aerosol(60, 50))
        self.assertEqual(0, air.get_aerosol(65, 50))
        self.assertNotEqual(0, air.get_aerosol(70, 40))
        self.assertNotEqual(0, air.get_aerosol(70, 60))

    def test_droplet_emission_pattern_wall_east(self):
        air = Air(CONFIG, 101, 101, 0, 0, 0, voids=[Void(12, 10)])
        air.add_droplet_pattern(50, 50, 2, initial_cough, Facing.EAST)
        self.assertNotEqual(0, air.get_droplet(50, 50))
        self.assertNotEqual(0, air.get_droplet(55, 50))
        self.assertIsNone(air.get_droplet(60, 50))
        self.assertEqual(0, air.get_droplet(65, 50))
        self.assertNotEqual(0, air.get_droplet(70, 40))
        self.assertNotEqual(0, air.get_droplet(70, 60))

    def test_droplet_emission_pattern_shield_east(self):
        air = Air(CONFIG, 101, 101, 0, 0, 0, barriers=[Shield(12, 10, 12, 11)])
        air.add_droplet_pattern(50, 50, 2, initial_cough, Facing.EAST)
        self.assertNotEqual(0, air.get_droplet(50, 50))
        self.assertNotEqual(0, air.get_droplet(55, 50))
        self.assertEqual(0, air.get_droplet(60, 50))
        self.assertEqual(0, air.get_droplet(65, 50))
        self.assertNotEqual(0, air.get_droplet(70, 40))
        self.assertNotEqual(0, air.get_droplet(70, 60))

    def test_droplet_emission_pattern_shield_north(self):
        air = Air(CONFIG, 101, 101, 0, 0, 0, barriers=[Shield(10, 12, 11, 12)])
        air.add_droplet_pattern(50, 50, 2, initial_cough, Facing.NORTH)
        self.assertNotEqual(0, air.get_droplet(50, 50))
        self.assertNotEqual(0, air.get_droplet(50, 55))
        self.assertEqual(0, air.get_droplet(50, 60))
        self.assertEqual(0, air.get_droplet(50, 65))
        self.assertNotEqual(0, air.get_droplet(40, 70))
        self.assertNotEqual(0, air.get_droplet(60, 70))

    def test_aerosol_emission_pattern_near_high_edge(self):
        air = Air(CONFIG, 101, 101, 0, 0, 0)
        air.add_aerosol_pattern(50, 90, 2, initial_cough, Facing.NORTH)
        self.assertNotEqual(0, air.get_aerosol(50, 90))
        self.assertNotEqual(0, air.get_aerosol(50, 95))
        self.assertNotEqual(0, air.get_aerosol(50, 100))
        self.assertNotEqual(0, air.get_aerosol(50, 101))

    def test_aerosol_emission_pattern_near_low_edge(self):
        air = Air(CONFIG, 101, 101, 0, 0, 0)
        air.add_aerosol_pattern(10, 50, 2, initial_cough, Facing.WEST)
        self.assertNotEqual(0, air.get_aerosol(10, 50))
        self.assertNotEqual(0, air.get_aerosol(5, 50))
        self.assertNotEqual(0, air.get_aerosol(0, 50))

    def test_aerosol_emission_pattern_near_corner(self):
        air = Air(CONFIG, 101, 101, 0, 0, 0)
        air.add_aerosol_pattern(5, 5, 2, initial_cough, Facing.SOUTH)
        self.assertNotEqual(0, air.get_aerosol(5, 5))
        self.assertNotEqual(0, air.get_aerosol(5, 0))

    def test_droplet_emission_pattern_next_to_void(self):
        pattern = [[0.1, 0.1, 0.1],
                   [0.1, 0.1, 0.1],
                   [0.1, 0.1, 0.1],
                   [0.1, 0.1, 0.1],
                   [0.1, 0.1, 0.1]]
        air = Air(CONFIG, 101, 101, 0, 0, 0, voids=[Void(9, 10)])
        air.add_droplet_pattern(50, 50, 2, pattern, Facing.NORTH)
        self.assertNotEqual(0, air.get_droplet(50, 50))
        self.assertIsNone(air.get_droplet(45, 50))
        self.assertEqual(0, air.get_droplet(40, 50))

    def test_droplet_emission_pattern_next_to_wall(self):
        pattern = [[0.1, 0.1, 0.1],
                   [0.1, 0.1, 0.1],
                   [0.1, 0.1, 0.1],
                   [0.1, 0.1, 0.1],
                   [0.1, 0.1, 0.1]]
        air = Air(CONFIG, 101, 101, 0, 0, 0, barriers=[Shield(10, 10, 10, 11)])
        air.add_droplet_pattern(50, 50, 2, pattern, Facing.NORTH)
        self.assertNotEqual(0, air.get_droplet(50, 50))
        self.assertEqual(0, air.get_droplet(45, 50))
        self.assertEqual(0, air.get_droplet(40, 50))

    def test_droplet_emission_pattern_next_to_wall_edge(self):
        pattern = [[0.1, 0.1, 0.1],
                   [0.1, 0.1, 0.1],
                   [0.1, 0.1, 0.1],
                   [0.1, 0.1, 0.1],
                   [0.1, 0.1, 0.1]]
        air = Air(CONFIG, 101, 101, 0, 0, 0, barriers=[Shield(10, 10, 10, 12)])
        air.add_droplet_pattern(50, 50, 2, pattern, Facing.NORTH)
        self.assertNotEqual(0, air.get_droplet(50, 50))
        self.assertEqual(0, air.get_droplet(45, 50))
        self.assertEqual(0, air.get_droplet(45, 55))
        self.assertEqual(0, air.get_droplet(45, 60))
        self.assertEqual(0, air.get_droplet(45, 65))
        self.assertEqual(0, air.get_droplet(45, 70))
        self.assertEqual(0, air.get_droplet(45, 75))
        self.assertEqual(0, air.get_droplet(40, 50))

    def test_droplet_emission_pattern_next_to_wall_edge_right(self):
        pattern = [[0.1, 0.1, 0.1],
                   [0.1, 0.1, 0.1],
                   [0.1, 0.1, 0.1],
                   [0.1, 0.1, 0.1],
                   [0.1, 0.1, 0.1]]
        air = Air(CONFIG, 101, 101, 0, 0, 0, barriers=[Shield(11, 10, 11, 12)])
        air.add_droplet_pattern(50, 50, 2, pattern, Facing.NORTH)
        self.assertNotEqual(0, air.get_droplet(50, 50))
        self.assertEqual(0, air.get_droplet(55, 50))
        self.assertEqual(0, air.get_droplet(55, 55))
        self.assertEqual(0, air.get_droplet(60, 50))


if __name__ == '__main__':
    unittest.main()
