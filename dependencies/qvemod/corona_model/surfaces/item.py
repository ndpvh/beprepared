from .surface import Surface


class Item(Surface):
    """A movable surface"""

    def serialize(self):
        return {
            'name': self.name,
            'x': self.init_x,
            'y': self.init_y,
            'transfer_efficiency': self._transfer_efficiency,
            'surface_ratio': self._surface_ratio,
            'surface_decay_rate': self.surface_decay_rate
        }

    @classmethod
    def deserialize(cls, serial):
        assert 'name' in serial
        assert 'x' in serial
        assert 'y' in serial
        assert 'transfer_efficiency' in serial
        assert 'surface_ratio' in serial
        assert 'surface_decay_rate' in serial
        return Item(
            serial['name'],
            serial['x'],
            serial['y'],
            serial['transfer_efficiency'],
            serial['surface_ratio'],
            serial['surface_decay_rate']

        )
