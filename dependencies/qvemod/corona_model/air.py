import math
from typing import List, Tuple, Union, Dict
from enum import auto, Enum
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
from corona_model.facing import Facing
from corona_model.barriers import Wall, Shield
from corona_model.emissionpatterns import EmissionPattern


class OutOfBoundsException(Exception):
    pass


class Void:
    """A dead air cell which is used as the legacy definition of Walls"""

    def __init__(self, x, y):
        self.x = x
        self.y = y

    def __repr__(self):
        return 'Void({},{})'.format(self.x, self.y)

    def __eq__(self, o):
        if isinstance(o, Void) and self.x == o.x and self.y == o.y:
            return True
        else:
            return False

    def serialize(self):
        return {
            'x': self.x,
            'y': self.y
        }

    @classmethod
    def deserialize(cls, serial):
        assert 'x' in serial
        assert 'y' in serial
        return cls(
            serial['x'],
            serial['y']
        )


class Edge:

    def __init__(self, x1: int, y1: int, x2: int, y2: int):
        self.x1, self.y1 = min(x1, x2), min(y1, y2)
        self.x2, self.y2 = max(x1, x2), max(y1, y2)
        assert ((self.x2 - self.x1 == 1 or self.y2 - self.y1 == 1) and
                (self.x2 == self.x1 or self.y2 == self.y1)), "Edge must be between two adjacent coordinates"

    def __hash__(self):
        return hash((self.x1, self.y1, self.x2, self.y2))

    def __eq__(self, o):
        if isinstance(o, Edge) and self.x1 == o.x1 and self.y1 == o.y1 and self.x2 == o.x2 and self.y2 == o.y2:
            return True
        return False

    def __repr__(self):
        return f'Edge({self.x1},{self.y1},{self.x2},{self.y2})'


def get_edges(x1: int, y1: int, x2: int, y2: int) -> List[Edge]:
    assert x1 == x2 or y1 == y2, "Only vertical or horizontal lines"
    edges = []
    if x1 == x2:  # Vertical
        for y in range(min(y1, y2), max(y1, y2)):
            edges.append(Edge(x1 - 1, y, x1, y))
    elif y1 == y2:  # Horizontal
        for x in range(min(x1, x2), max(x1, x2)):
            edges.append(Edge(x, y1 - 1, x, y1))
    return edges


class Air:
    FloatGrid = List[List[Union[float, None]]]

    class Layer(Enum):
        AEROSOLS = 0
        DROPLETS = 1

    def convert_coordinates(self, x: int, y: int) -> Tuple[int, int]:
        return math.floor(x * self.mobility_ratio), math.floor(y * self.mobility_ratio)

    def __init__(self, config: dict, width: int, height: int, aerosol_decay_rate: float, droplet_decay_rate: float,
                 air_exchange_rate: float, barriers: List[Union[Wall, Shield]] = (), voids: List[Void] = ()):
        """
        Creates a new Air layer which covers the entire width and height of the Environment.

        :param width: Width of Environment in MobilityCellSize scale
        :param height: Height of Environment in MobilityCellSize scale
        :param aerosol_decay_rate: Rate at which aerosol contaminate decays
        :param droplet_decay_rate: Rate at which droplet contaminate decays
        :param air_exchange_rate: Rate at which air is cycled in Environment
        :param barriers: List of Barrier classes with coordinates scaled from MobilityCellSize to AirCellSize
        :param voids: List of Void spaces to remove from the Air with coordinates scaled from MobilityCellSize to AirCellSize
        """
        self.config = config
        self.mobility_ratio = config['env']['MobilityCellSize'] / config['env']['AirCellSize']
        # Compute Air size, rounding up to cover entire width and height
        self._width = math.ceil(width * self.mobility_ratio)
        self._height = math.ceil(height * self.mobility_ratio)

        self._aerosol_decay_rate = aerosol_decay_rate
        self._droplet_decay_rate = droplet_decay_rate
        self._air_exchange_rate = air_exchange_rate  # only influence on the aerosols concentration in the room

        # Initialize aerosols and droplets to 0.0
        self._aerosols: Air.FloatGrid = [[0.0 for _ in range(self._height)] for _ in range(self._width)]
        self._droplets: Air.FloatGrid = [[0.0 for _ in range(self._height)] for _ in range(self._width)]

        # Initialize aerosol and droplet barrier dictionary
        self._aerosol_barriers: Dict[Edge, bool] = {}
        self._droplet_barriers: Dict[Edge, bool] = {}

        # Add barrier edges
        for barrier in barriers:
            for edge in get_edges(barrier.x1, barrier.y1, barrier.x2, barrier.y2):
                if isinstance(barrier, Wall):
                    self._aerosol_barriers[edge] = True
                    self._droplet_barriers[edge] = True
                elif isinstance(barrier, Shield):
                    self._droplet_barriers[edge] = True

        # Set void cells to None
        self._voids = voids
        for void in self._voids:
            if not 0 <= void.x < self._width or not 0 <= void.y < self._height:
                raise OutOfBoundsException
            self._aerosols[void.x][void.y] = None
            self._droplets[void.x][void.y] = None

    def is_void(self, x: int, y: int) -> bool:
        x, y = self.convert_coordinates(x, y)
        if Void(x, y) in self._voids:
            return True
        else:
            return False

    def get_aerosol(self, x: int, y: int) -> Union[float, None]:
        return self.get_layer(x, y, Air.Layer.AEROSOLS)

    def _get_aerosol(self, x: int, y: int) -> Union[float, None]:
        return self._get_layer(x, y, Air.Layer.AEROSOLS)

    def get_droplet(self, x: int, y: int) -> Union[float, None]:
        return self.get_layer(x, y, Air.Layer.DROPLETS)

    def _get_droplet(self, x: int, y: int) -> Union[float, None]:
        return self._get_layer(x, y, Air.Layer.DROPLETS)

    def get_layer(self, x: int, y: int, layer: Layer) -> Union[float, None]:
        x, y = self.convert_coordinates(x, y)
        return self._get_layer(x, y, layer)

    def _get_layer(self, x: int, y: int, layer: Layer) -> Union[float, None]:
        if not 0 <= x < self._width or not 0 <= y < self._height:
            raise OutOfBoundsException
        if layer == Air.Layer.AEROSOLS:
            return self._aerosols[x][y]
        elif layer == Air.Layer.DROPLETS:
            return self._droplets[x][y]

    def add_aerosol(self, x: int, y: int, addition: float) -> None:
        x, y = self.convert_coordinates(x, y)
        self._set_layer(x, y, self._get_aerosol(x, y) + addition, Air.Layer.AEROSOLS)

    def add_droplet(self, x: int, y: int, addition: float) -> None:
        x, y = self.convert_coordinates(x, y)
        self._set_layer(x, y, self._get_droplet(x, y) + addition, Air.Layer.DROPLETS)

    def _add_layer(self, x: int, y: int, addition: float, layer: Layer) -> None:
        if layer == Air.Layer.AEROSOLS:
            self._set_layer(x, y, self._get_aerosol(x, y) + addition, layer)
        elif layer == Air.Layer.DROPLETS:
            self._set_layer(x, y, self._get_droplet(x, y) + addition, layer)

    def subtract_aerosol(self, x: int, y: int, subtraction: float) -> None:
        x, y = self.convert_coordinates(x, y)
        self._set_layer(x, y, self._get_aerosol(x, y) - subtraction, Air.Layer.AEROSOLS)

    def subtract_droplet(self, x: int, y: int, subtraction: float) -> None:
        x, y = self.convert_coordinates(x, y)
        self._set_layer(x, y, self._get_droplet(x, y) - subtraction, Air.Layer.DROPLETS)

    def _set_aerosol(self, x: int, y: int, f: float) -> None:
        self._set_layer(x, y, f, Air.Layer.AEROSOLS)

    def _set_droplet(self, x: int, y: int, f: float) -> None:
        self._set_layer(x, y, f, Air.Layer.DROPLETS)

    def _set_layer(self, x: int, y: int, f: float, layer: Layer) -> None:
        if layer == Air.Layer.AEROSOLS:
            if self._get_aerosol(x, y) is not None:
                self._aerosols[x][y] = f
        elif layer == Air.Layer.DROPLETS:
            if self._get_droplet(x, y) is not None:
                self._droplets[x][y] = f

    def decay(self) -> None:
        for x in range(self._width):
            for y in range(self._height):
                if self._get_aerosol(x, y) is not None:
                    self._set_aerosol(x, y, self._get_aerosol(x, y) *
                                      math.exp(-(self._aerosol_decay_rate + self._air_exchange_rate) *
                                               self.config['env']['SimulationTimeStep']))
                if self._get_droplet(x, y) is not None:
                    self._set_droplet(x, y, self._get_droplet(x, y) -
                                      (self._get_droplet(x, y) *
                                       self._droplet_decay_rate *
                                       self.config['env']['SimulationTimeStep']))

    def diffuse(self) -> None:
        self._diffuse_aerosols()
        self._diffuse_droplets()

    def _diffuse_aerosols(self) -> None:
        next_aerosols = deepcopy(self._aerosols)
        for x in range(self._width):
            for y in range(self._height):
                if self._get_aerosol(x, y) is not None:  # Is this a void cell?
                    s = []
                    # North
                    if (y + 1 < self._height and
                            self._get_aerosol(x, y + 1) is not None and
                            self._aerosol_barriers.get(Edge(x, y, x, y + 1)) is None):
                        s.append(self._get_aerosol(x, y + 1))
                    # South
                    if (y - 1 >= 0 and
                            self._get_aerosol(x, y - 1) is not None and
                            self._aerosol_barriers.get(Edge(x, y, x, y - 1)) is None):
                        s.append(self._get_aerosol(x, y - 1))
                    # East
                    if (x + 1 < self._width and  # In bounds
                            self._get_aerosol(x + 1, y) is not None and  # Not a void cell
                            self._aerosol_barriers.get(Edge(x, y, x + 1, y)) is None):  # No barrier between cells
                        s.append(self._get_aerosol(x + 1, y))
                    # West
                    if (x - 1 >= 0 and
                            self._get_aerosol(x - 1, y) is not None and
                            self._aerosol_barriers.get(Edge(x, y, x - 1, y)) is None):
                        s.append(self._get_aerosol(x - 1, y))
                    next_aerosols[x][y] += (
                            self.config['env']['Diffusivity'] *
                            (sum(s) - (len(s) + ((4 - len(s)) * self.config['env']['WallAbsorbingProportion'])) *
                             self._get_aerosol(x, y)) * self.config['env']['SimulationTimeStep']
                    )
        self._aerosols = next_aerosols

    def _diffuse_droplets(self) -> None:
        next_droplets = deepcopy(self._droplets)
        for x in range(self._width):
            for y in range(self._height):
                if self._get_droplet(x, y) is not None:
                    s = []
                    # North
                    if (y + 1 < self._height and
                            self._get_droplet(x, y + 1) is not None and
                            self._droplet_barriers.get(Edge(x, y, x, y + 1)) is None):
                        s.append(self._get_droplet(x, y + 1))
                    # South
                    if (y - 1 >= 0 and
                            self._get_droplet(x, y - 1) is not None and
                            self._droplet_barriers.get(Edge(x, y, x, y - 1)) is None):
                        s.append(self._get_droplet(x, y - 1))
                    # East
                    if (x + 1 < self._width and
                            self._get_droplet(x + 1, y) is not None and
                            self._droplet_barriers.get(Edge(x, y, x + 1, y)) is None):
                        s.append(self._get_droplet(x + 1, y))
                    # West
                    if (x - 1 >= 0 and
                            self._get_droplet(x - 1, y) is not None and
                            self._droplet_barriers.get(Edge(x, y, x - 1, y)) is None):
                        s.append(self._get_droplet(x - 1, y))
                    next_droplets[x][y] += (
                            self.config['env']['Diffusivity'] *
                            (sum(s) - (len(s) + ((4 - len(s)) * self.config['env']['WallAbsorbingProportion'])) *
                             self._get_droplet(x, y)) * self.config['env']['SimulationTimeStep']
                    )
        self._droplets = next_droplets

    def add_aerosol_pattern(self, x: int, y: int, addition: float,
                            pattern: EmissionPattern, direction: Facing) -> None:
        self._add_layer_pattern(x, y, addition, Air.Layer.AEROSOLS, pattern, direction)

    def add_droplet_pattern(self, x: int, y: int, addition: float,
                            pattern: EmissionPattern, direction: Facing) -> None:
        self._add_layer_pattern(x, y, addition, Air.Layer.DROPLETS, pattern, direction)

    def _add_layer_pattern(self, x: int, y: int, addition: float, layer: Layer,
                           pattern: EmissionPattern, direction: Facing) -> None:
        """
        Adds given addition to Layer based on pattern and direction in front of origin.

        :param x: X coordinate of emission origin
        :param y: Y coordinate of emission origin
        :param addition: Amount of contaminate to apply over pattern
        :param layer: Air.Layer to add to
        :param pattern: EmissionPattern validated by make_pattern
        :param direction: Cardinal direction of emission from origin
        :return:
        """
        x, y = self.convert_coordinates(x, y)

        if direction == Facing.NORTH:
            pattern_x0, pattern_y0 = x - (len(pattern) // 2), y
        elif direction == Facing.SOUTH:
            pattern_x0, pattern_y0 = x + (len(pattern) // 2), y
        elif direction == Facing.EAST:
            pattern_x0, pattern_y0 = x, y + (len(pattern) // 2)
        elif direction == Facing.WEST:
            pattern_x0, pattern_y0 = x, y - (len(pattern) // 2)
        else:
            raise ValueError

        class Flow(Enum):
            LEFT = auto()
            RIGHT = auto()

        def process(range_from_center: range, flow: Union[Flow, None]):
            block_at_0 = False
            till_y = len(pattern[0])
            for pattern_x in range_from_center:
                for pattern_y in range(len(pattern[0])):

                    if pattern_y == 0 and block_at_0:
                        continue

                    if direction == Facing.NORTH:
                        target_x, target_y = pattern_x0 + pattern_x, pattern_y0 + pattern_y
                    elif direction == Facing.SOUTH:
                        target_x, target_y = pattern_x0 - pattern_x, pattern_y0 - pattern_y
                    elif direction == Facing.EAST:
                        target_x, target_y = pattern_x0 + pattern_y, pattern_y0 - pattern_x
                    elif direction == Facing.WEST:
                        target_x, target_y = pattern_x0 - pattern_y, pattern_y0 + pattern_x
                    else:
                        raise ValueError

                    # Check for edge of environment
                    if not 0 <= target_x < self._width or not 0 <= target_y < self._height:
                        break

                    # Check facing barriers
                    if pattern_y != 0:  # Skip first cell because Agent won't emit backwards
                        # Compute prev_target: previous value for target
                        if direction == Facing.NORTH:
                            prev_target_x, prev_target_y = target_x, target_y - 1
                        elif direction == Facing.SOUTH:
                            prev_target_x, prev_target_y = target_x, target_y + 1
                        elif direction == Facing.EAST:
                            prev_target_x, prev_target_y = target_x - 1, target_y
                        elif direction == Facing.WEST:
                            prev_target_x, prev_target_y = target_x + 1, target_y
                        else:
                            raise ValueError
                        # Evaluate facing barriers
                        if layer == Air.Layer.AEROSOLS:
                            if self._aerosol_barriers.get(
                                    Edge(prev_target_x, prev_target_y, target_x, target_y)) is True:
                                till_y = pattern_y
                                break
                        elif layer == Air.Layer.DROPLETS:
                            if self._droplet_barriers.get(
                                    Edge(prev_target_x, prev_target_y, target_x, target_y)) is True:
                                till_y = pattern_y
                                break
                    # Check side barriers
                    if flow:  # Only check if flow column
                        # Compute flow_target: cell from which air is flowing
                        if direction == Facing.NORTH:
                            if flow == Flow.LEFT:
                                flow_target_x = target_x + 1
                            elif flow == Flow.RIGHT:
                                flow_target_x = target_x - 1
                            else:
                                raise ValueError
                            flow_target_y = target_y
                        elif direction == Facing.SOUTH:
                            if flow == Flow.LEFT:
                                flow_target_x = target_x - 1
                            elif flow == Flow.RIGHT:
                                flow_target_x = target_x + 1
                            else:
                                raise ValueError
                            flow_target_y = target_y
                        elif direction == Facing.EAST:
                            flow_target_x = target_x
                            if flow == Flow.LEFT:
                                flow_target_y = target_y + 1
                            elif flow == Flow.RIGHT:
                                flow_target_y = target_y - 1
                            else:
                                raise ValueError
                        elif direction == Facing.WEST:
                            flow_target_x = target_x
                            if flow == Flow.LEFT:
                                flow_target_y = target_y - 1
                            elif flow == Flow.RIGHT:
                                flow_target_y = target_y + 1
                            else:
                                raise ValueError
                        else:
                            raise ValueError
                        # Evaluate side barriers
                        if layer == Air.Layer.AEROSOLS:
                            if self._aerosol_barriers.get(
                                    Edge(flow_target_x, flow_target_y, target_x, target_y)) is True:
                                if pattern_y == 0:
                                    block_at_0 = True
                                    continue
                                till_y = pattern_y
                                break
                        elif layer == Air.Layer.DROPLETS:
                            if self._droplet_barriers.get(
                                    Edge(flow_target_x, flow_target_y, target_x, target_y)) is True:
                                if pattern_y == 0:
                                    block_at_0 = True
                                    continue
                                till_y = pattern_y
                                break

                    # Check for a Void cell
                    if self._get_aerosol(target_x, target_y) is None:
                        if pattern_y == 0:
                            block_at_0 = True
                            continue
                        till_y = pattern_y
                        break

                    if pattern_y >= till_y:
                        break

                    self._add_layer(target_x, target_y, addition * pattern[pattern_x][pattern_y], layer)

        left = range(len(pattern) // 2 - 1, -1, -1)
        center = range(len(pattern) // 2, len(pattern) // 2 + 1)
        right = range(len(pattern) // 2 + 1, len(pattern))
        process(left, Flow.LEFT)
        process(center, None)
        process(right, Flow.RIGHT)

    def __str__(self) -> str:
        import os

        def chart(layer: Air.Layer) -> str:
            output = os.linesep  # Start on a fresh line
            output += "     {:=^{w}} ".format(layer.name.title(), w=(8 * self._width)) + os.linesep
            for y in range(self._height - 1, -1, -1):
                row = str()
                row += "{:3} | ".format(y)  # 6 char gutter
                for x in range(self._width):
                    if self._get_layer(x, y, layer) is not None:
                        row += "{:7.5f} ".format(self._get_layer(x, y, layer))
                    else:
                        row += " " * 8
                output += row + os.linesep
            output += "    '" + ("-" * 8 * self._width) + os.linesep
            output += "      " + " ".join(["{:^7}".format(n) for n in range(self._width)]) + os.linesep
            return output

        return chart(Air.Layer.AEROSOLS) + chart(Air.Layer.DROPLETS)
