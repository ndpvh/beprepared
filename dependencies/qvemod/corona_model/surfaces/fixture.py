from .surface import Surface


class Fixture(Surface):
    """A fixed surface in the environment"""

    def __init__(self, name, init_x, init_y, transfer_efficiency, surface_ratio,
                 touch_frequency, surface_decay_rate):
        Surface.__init__(self, name, init_x, init_y, transfer_efficiency, surface_ratio, surface_decay_rate)
        self._touch_frequency = touch_frequency
        self.transfer_rate = transfer_efficiency * surface_ratio * touch_frequency

    def serialize(self):
        return {
            'name': self.name,
            'x': self.init_x,
            'y': self.init_y,
            'transfer_efficiency': self._transfer_efficiency,
            'surface_ratio': self._surface_ratio,
            'touch_frequency': self._touch_frequency,
            'surface_decay_rate': self.surface_decay_rate
        }

    @classmethod
    def deserialize(cls, serial):
        assert 'name' in serial
        assert 'x' in serial
        assert 'y' in serial
        assert 'transfer_efficiency' in serial
        assert 'surface_ratio' in serial
        assert 'touch_frequency' in serial
        assert 'surface_decay_rate' in serial
        return Fixture(
            serial['name'],
            serial['x'],
            serial['y'],
            serial['transfer_efficiency'],
            serial['surface_ratio'],
            serial['touch_frequency'],
            serial['surface_decay_rate']
        )
