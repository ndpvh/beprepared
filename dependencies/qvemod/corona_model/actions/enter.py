class Enter:
    """Used to place the Agent in their initial entry point in the Environment"""
    def __init__(self, x, y, facing='N'):
        self.type = 'enter'
        self.x = x
        self.y = y
        assert facing in ('N', 'S', 'E', 'W')
        self.facing = facing

    def serialize(self):
        return {
            'type': self.type,
            'x': self.x,
            'y': self.y,
            'facing': self.facing
        }

    @classmethod
    def deserialize(cls, serial):
        assert 'x' in serial
        assert 'y' in serial
        assert 'facing' in serial
        return Enter(serial['x'], serial['y'], serial['facing'])
