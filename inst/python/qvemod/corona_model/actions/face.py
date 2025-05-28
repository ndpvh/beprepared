class Face:
    def __init__(self, direction):
        self.type = 'face'
        self.direction = direction

    def serialize(self):
        return {
            'type': self.type,
            'direction': self.direction
        }

    @classmethod
    def deserialize(cls, serial):
        assert 'direction' in serial
        return Face(serial['direction'])
