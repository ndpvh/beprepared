class DoffMask:
    """Take of Mask returning Emission and Pickup to and from Air and Droplet Layers to effected rates"""
    def __init__(self):
        self.type = 'doffmask'

    def serialize(self):
        return {
            'type': self.type,
        }

    @classmethod
    def deserialize(cls):
        return DoffMask()
