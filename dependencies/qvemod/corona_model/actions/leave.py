class Leave:
    def __init__(self):
        self.type = 'leave'

    def serialize(self):
        return {
            'type': self.type
        }

    @classmethod
    def deserialize(cls):
        return Leave()
