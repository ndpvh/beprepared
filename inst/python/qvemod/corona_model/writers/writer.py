import os
import csv
from enum import Enum


class Writer: 

    FILE_NAME = str()

    class Field(Enum):
        pass

    @classmethod
    def fieldnames(cls):
        return [f.value for f in cls.Field]

    def __init__(self, config):
        self.config = config

        if not os.path.isdir(config['output']['Path']):
            os.mkdir(config['output']['Path'])

        self._file = open(os.path.join(config['output']['Path'], self.__class__.FILE_NAME), 'w', newline='')
        self._file.truncate()
        self._writer = csv.DictWriter(self._file, fieldnames=self.__class__.fieldnames())
        self._writer.writeheader()

    def close(self):
        self._file.close()
