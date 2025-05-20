class Surface:
    """Base Class for all Surfaces"""
    def __init__(self, name, init_x, init_y, transfer_efficiency, surface_ratio, surface_decay_rate):
        self.name = name
        self.init_x = init_x
        self.init_y = init_y
        self.contamination_load = 0.0
        self._transfer_efficiency = transfer_efficiency
        self.surface_decay_rate = surface_decay_rate
        self._surface_ratio = surface_ratio
        self.transfer_rate = transfer_efficiency * surface_ratio

    def __repr__(self):
        return '{name}({load})'.format(name=self.name, load=self.contamination_load)

    def serialize(self):
        pass

    @classmethod
    def deserialize(cls, serial):
        pass
