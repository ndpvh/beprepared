class Move:
    def __init__(self, x, y, facing=None):
        self.type = 'move'
        self.x = x
        self.y = y
        assert facing in ('N', 'S', 'E', 'W') or facing is None
        self.facing = facing

    def serialize(self):
        serial = {
            'type': self.type,
            'x': self.x,
            'y': self.y
        }
        if self.facing:
            serial['facing'] = self.facing
        return serial

    @classmethod
    def deserialize(cls, serial):
        assert 'x' in serial
        assert 'y' in serial
        return Move(serial['x'], serial['y'], facing=serial.get('facing'))
