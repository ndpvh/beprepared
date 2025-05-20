from enum import Enum

from .writer import Writer


class DropletContaminationWriter(Writer):

    FILE_NAME = "droplet_contamination.csv"

    class Field(Enum):
        TICK = "Tick"
        X = "X"
        Y = "Y"
        CONTAMINATION = "Contamination"

    def write(self, tick: int, x: int, y: int, contamination: float):
        contamination: str = "{:.{precision}f}".format(contamination,
                                                       precision=self.config['output']['DropletContaminationPrecision'])
        self._writer.writerow(
            {
                DropletContaminationWriter.Field.TICK.value: tick,
                DropletContaminationWriter.Field.X.value: x,
                DropletContaminationWriter.Field.Y.value: y,
                DropletContaminationWriter.Field.CONTAMINATION.value: contamination
            }
        )
