import os
import pandas as pd
import numpy as np
import math
import ipdb

os.chdir("dependencies/qvemod")
from corona_model.agent import Agent
from corona_model.environment import Environment
from corona_model.air import Wall, Shield, Void, EmissionPattern
from corona_model.model import Model
from corona_model.actions import *
from corona_model.surfaces import Item, Fixture
os.chdir("../../")