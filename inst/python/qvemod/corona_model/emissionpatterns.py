from typing import List

EmissionPattern = List[List[float]]


def make_pattern(pattern: List[List[float]]) -> EmissionPattern:
    """
    Validates given pattern and returns it as an validated emission pattern.

    :param pattern: 2d List of dispersion pattern
    :return: Validated emission pattern
    """
    # Pattern should be a rectangle/square
    assert all(len(y) == len(pattern[0]) for y in pattern)
    # All floats should add up to 1 (can't create extra contaminate)
    assert 1 >= sum(sum(pattern, []))
    # Length of x axis is odd so pattern is not skewed
    assert 0 != len(pattern) % 2

    return pattern


aerosol_cough: EmissionPattern = make_pattern(
    [[0.0, 0.0, 0.000, 0.0,   0.00],
     [0.0, 0.0, 0.000, 0.125, 0.00],
     [0.0, 0.0, 0.125, 0.375, 0.25],
     [0.0, 0.0, 0.000, 0.125, 0.00],
     [0.0, 0.0, 0.000, 0.0,   0.00]]
)

droplet_cough: EmissionPattern = make_pattern(
    [[0.0, 0.0, 0.0, 0.0,  0.00],
     [0.0, 0.0, 0.0, 0.0,  0.00],
     [0.0, 0.0, 0.0, 0.25, 0.75],
     [0.0, 0.0, 0.0, 0.0,  0.00],
     [0.0, 0.0, 0.0, 0.0,  0.00]]
)

initial_cough: EmissionPattern = make_pattern(
    [[0.0, 0.0, 0.0, 0.0,    0.04],
     [0.0, 0.0, 0.0, 0.0666, 0.04],
     [0.2, 0.2, 0.2, 0.0667, 0.04],
     [0.0, 0.0, 0.0, 0.0666, 0.04],
     [0.0, 0.0, 0.0, 0.0,    0.04]]
)

