from enum import Enum

from .writer import Writer


class AgentExposureWriter(Writer):

    FILE_NAME = "agent_exposure.csv"

    class Field(Enum):
        NAME = "Agent"
        TICK = "Tick"
        CONTAMINATION_LOAD_AEROSOL = "Contamination Load Aerosol"
        CONTAMINATION_LOAD_DROPLET = "Contamination Load Droplet"
        ACCUMULATED_CONTAMINATION_LOAD_SURFACE = "Accumulated Contamination Load Surface"
        CONTAMINATION_LOAD_FACE = "Contamination Load Face"

    def write(self, name: str, tick: int, contamination_load_aerosol: float, contamination_load_droplet: float,
              accumulated_contamination_load_surface: float, contamination_load_face: float):
        self._writer.writerow(
            {
                AgentExposureWriter.Field.NAME.value: name,
                AgentExposureWriter.Field.TICK.value: tick,
                AgentExposureWriter.Field.CONTAMINATION_LOAD_AEROSOL.value: contamination_load_aerosol,
                AgentExposureWriter.Field.CONTAMINATION_LOAD_DROPLET.value: contamination_load_droplet,
                AgentExposureWriter.Field.ACCUMULATED_CONTAMINATION_LOAD_SURFACE.value:
                    accumulated_contamination_load_surface,
                AgentExposureWriter.Field.CONTAMINATION_LOAD_FACE.value:
                    contamination_load_face
            }
        )
