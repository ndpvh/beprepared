class Putdown:
    def __init__(self, target):
        self.type = 'putdown'
        self.target = target

    def serialize(self):
        return {
            'type': self.type,
            'target': self.target
        }

    @classmethod
    def deserialize(cls, serial):
        assert 'target' in serial
        return Putdown(serial['target'])