class Pickup:
    def __init__(self, target):
        self.type = 'pickup'
        self.target = target

    def serialize(self):
        return {
            'type': self.type,
            'target': self.target
        }

    @classmethod
    def deserialize(cls, serial):
        assert 'target' in serial
        return Pickup(serial['target'])