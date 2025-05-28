from enum import Enum

from .writer import Writer


class AerosolContaminationWriter(Writer):

    FILE_NAME = "aerosol_contamination.csv"

    class Field(Enum):
        TICK = "Tick"
        X = "X"
        Y = "Y"
        CONTAMINATION = "Contamination"

    def write(self, tick: int, x: int, y: int, contamination: float):
        contamination: str = "{:.{precision}f}".format(contamination,
                                                       precision=self.config['output']['AerosolContaminationPrecision'])
        self._writer.writerow(
            {
                AerosolContaminationWriter.Field.TICK.value: tick,
                AerosolContaminationWriter.Field.X.value: x,
                AerosolContaminationWriter.Field.Y.value: y,
                AerosolContaminationWriter.Field.CONTAMINATION.value: contamination
            }
        )
