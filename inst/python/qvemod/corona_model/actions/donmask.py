class DonMask:
    """Put on Mask reducing Emission and Pickup to and from Air and Droplet Layers"""
    def __init__(self):
        self.type = 'donmask'

    def serialize(self):
        return {
            'type': self.type,
        }

    @classmethod
    def deserialize(cls):
        return DonMask()
