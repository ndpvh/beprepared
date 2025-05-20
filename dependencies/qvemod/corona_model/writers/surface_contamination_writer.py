from enum import Enum

from .writer import Writer


class SurfaceContaminationWriter(Writer):

    FILE_NAME = "surface_contamination.csv"

    class Field(Enum):
        NAME = "Name"
        TYPE = "Type"
        TICK = "Tick"
        X = "X"
        Y = "Y"
        CONTAMINATION = "Contamination"

    def write(self, name: str, surface_class_name: str, tick: int, x: int, y: int, contamination: float):
        contamination: str = "{:.{precision}f}".format(contamination,
                                                       precision=self.config['output']['SurfaceContaminationPrecision'])
        self._writer.writerow(
            {
                SurfaceContaminationWriter.Field.NAME.value: name,
                SurfaceContaminationWriter.Field.TYPE.value: surface_class_name,
                SurfaceContaminationWriter.Field.TICK.value: tick,
                SurfaceContaminationWriter.Field.X.value: x,
                SurfaceContaminationWriter.Field.Y.value: y,
                SurfaceContaminationWriter.Field.CONTAMINATION.value: contamination
            }
        )
