import unittest

from corona_model.environment import Environment


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


class TestEnvironment(unittest.TestCase):

    def test_default_reachable_surfaces(self):
        e = Environment(5, 5, 0, 0, 0, 0, 0)
        e.set_config(CONFIG)
        assert len(e.reachable_surfaces(2, 2)) == 5 * 5
        assert len(e.reachable_surfaces(1, 1)) == 4 * 4
        assert len(e.reachable_surfaces(0, 0)) == 3 * 3
        assert len(e.reachable_surfaces(2, 1)) == 5 * 4
        assert len(e.reachable_surfaces(2, 0)) == 5 * 3
        assert len(e.reachable_surfaces(3, 3)) == 4 * 4
        assert len(e.reachable_surfaces(4, 4)) == 3 * 3
        assert len(e.reachable_surfaces(6, 2)) == 0
        assert len(e.reachable_surfaces(5, 5)) == 0
        assert len(e.reachable_surfaces(-1, -1)) == 0
        coordinates = e.reachable_surfaces(0, 0)
        assert (0, 0) in coordinates
        assert (-1, -1) not in coordinates
        assert (4, 4) not in coordinates
        assert (5, 5) not in coordinates
        assert (2, 2) in coordinates

        e2 = Environment(100, 100, 0, 0, 0, 0, 0)
        e2.set_config(CONFIG)
        coordinates = e2.reachable_surfaces(20, 30)
        assert len(coordinates) == 5 * 5
        assert (20, 30) in coordinates
        assert (18, 30) in coordinates
        assert (17, 30) not in coordinates
        assert (22, 32) in coordinates
        assert (22, 33) not in coordinates
        assert (23, 32) not in coordinates


if __name__ == '__main__':
    unittest.main()
