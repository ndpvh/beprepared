class Handwash:
    """Reduce Contamination Load from surfaces for a time period"""
    def __init__(self):
        self.type = 'handwash'

    def serialize(self):
        return {
            'type': self.type,
        }

    @classmethod
    def deserialize(cls):
        return Handwash()
