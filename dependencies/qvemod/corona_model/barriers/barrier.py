class Barrier:
    """Base class for Barriers"""

    def __init__(self, x1, y1, x2, y2):
        assert x1 == x2 or y1 == y2, "Only vertical or horizontal Barriers"
        self.x1, self.y1 = x1, y1
        self.x2, self.y2 = x2, y2

    def serialize(self):
        return {
            "type": self.__class__.__name__.lower(),
            "x1": self.x1,
            "y1": self.y1,
            "x2": self.x2,
            "y2": self.y2
        }

    @classmethod
    def deserialize(cls, s):
        assert "x1" in s
        assert "y1" in s
        assert "x2" in s
        assert "y2" in s
        return cls(
            s["x1"],
            s["y1"],
            s["x2"],
            s["y2"]
        )
