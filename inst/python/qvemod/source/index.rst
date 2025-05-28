.. QVEmod documentation master file, created by
   sphinx-quickstart on Thu Jun 22 03:46:16 2023.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

QVEmod Documentation
==================================

.. contents:: Table of Contents
   :depth: 2


Overview
---------

QVEmod (Model for Quantifying Viruses in Environments) is an agent based virus spread model currently tooled for SARS-CoV-2 transmission. The model takes as input an environment description, a list of agents and their movements in the environment, and a set of epidemiologically defined disease transmission parameters. All model inputs are defined as well structured JSON that correspond directly to the objects defined and used by the model. All outputs are either in JSON or CSV files depending on the data type.

Implementation consists of three Cartesian grids that overlay one another, a mobility grid, an air grid, and a droplet grid. Agents move through the mobility grid according to their script. Agents emit virus contamination directly into the air grid and can pick up contamination through this grid as well. Air contamination can, over time, coalesce into contamination on the droplet grid. Agent interactions with objects in the environment can expose them to droplet contamination and agents can also directly contaminate objects with droplets.

The model starts by initializing the environment from the input files, then simulates agents moving through the mobility space. Model timesteps are called ‘ticks’ and ticks correspond to agent actions in their respective scripts. At each tick agents release airborne and surface contamination, airborne contamination can move down a level into the surface grid, and agents can become contaminated by either the airborne grid or the surface grid. The number of ticks simulated for each model run is determined in the input files.


QVEmod, in and of itself, does not create environments, agents, or their scripts, in any scientifically meaningful way. This code repository does contain sample model inputs used for demonstration and testing, however, to perform useful experiments with the model a robust pedestrian simulation model is needed as well. The paper published with this source code utilizes the NOMAD model, but other models can be used as the model input interface is robust and well defined.

Usage
------

The model can be run as seen below, which will instantiate a demo model, run the model, print model outputs to the screen, and store the model input at the local directory as model.json. Additional outputs can be found in the output folder (aerosol, droplet, surface contamination and exposure by agent). 

.. code-block:: console

    $ python3 ./main.py

Unit Tests
------------

The model has 42 unit tests that help ensure code changes do not break system functionality. Unittests are simple, self-contained segments of code that test a particular behavior or function of the system. The tests instantiate a version of the model, run a piece of the model, and then test the output against hardcoded values. If a test fails a message will be displayed on the screen notifying which test failed and with some information as to why the test failed. Unittests are a software engineering practice that helps maintain the quality and reliability of the code base. If you intend to modify the model it is strongly suggested to regularly run unit tests during development and to add unit tests for your new features. Unit tests can be run as follows:

.. code-block:: console

    $ ./python3 -m unittest 
     ----------------------------------------------------------------------
     Ran 42 tests in 0.117s
    
     OK

Source Code
============

Agent
--------------
.. py:class:: Agent(self, name, viral_load, contamination_load_air, contamination_load_droplet, contamination_load_surface, emission_rate_air, emission_rate_droplet, pick_up_air, pick_up_droplet, script, is_active=False, wearing_mask=False)

    Represents individual that can move through and interact with the environment

    :param name: Agent identifier, human readable, user selected.
    :param viral_load: Amount of virus an infected agent emits during the simulation.
    :param contamination_load_air: Amount of virus the agent has come into contact with through the air surface.
    :param contamination_load_droplet: Amount of virus the agent has come into contact with through the droplet surface.
    :param contamination_load_surface: Amount of virus the agent has come into contact with through items and fixtures.
    :param emission_rate_air: Rate of infected agent virus emission at the air surface.
    :param emission_rate_droplet: Rate of infected agent virus emission at the droplet surface.
    :param pick_up_air: Coefficient of exposure to viral contamination at the air surface.
    :param pick_up_droplet: Coefficient of exposure to viral contamination at the droplet surface.
    :param script: Time step or tick keyed dictionary of agent actions and movements.
    :param is_active: Toggle to disable or enable viral emission.
    :param wearing_mask: Masking intervention strategy toggle.

    .. py:method:: emit_aerosol(self) 

        Returns amount of virus the agent emits into the air surface given their current attributes.

        :return: Float

    .. py:method:: emit_droplet(self)

        Returns amount of virus the agent emits into the droplet surface given their current attributes.

        :return: Float

    .. py:method:: pickup_air(self, air_load, pick_up_air)

        Adjusts agent air surface contamination by values determined by the environment.

        :param air_load: The current amount of contamination at the agents location in the environment.
        :param pick_up_air: Environment driven contamination coefficient.
 
        :return: None

    .. py:method:: pickup_droplet(droplet_load, pick_up_droplet)
    
        Adjusts agent droplet surface contamination by values determined by the environment.

        :param droplet_load: The current amount of contamination at the agents location in the environment.
        :param pick_up_droplet: Environment driven contamination coefficient.
 
        :return: None

    .. py:method:: pickup_from_surface(self, surface)

        Adjusts agent fixture or item contamination by items in the object itself.

        :param surface: The item the agent is interacting with and contains attributes for determining contamination.

        :return: None
    

    .. py:method:: hand_to_surface_transfer(self, surface)

        Adjusts contamination in environmental object based upon agent viral load.

        :param surface: The item the agent is interacting with and contains attributes for determining contamination.

        :return: None

    .. py:method:: hold(self, item)

        Takes an item from the environment, gives the agent exclusive control of the item and handles contamination dynamics on pickup. 

        :param item: The environmental object the agent is interacting with according to the script.

        :return: None

    .. py:method:: release(self, item)
    
        Removes item from agent.

        :param item: The item to remove from the agent.

        :return: None    

    .. py:method:: start_handwash_effect(self)

        Agent washes hand as described in the script reducing viral load and contamination.

        :return: None

    .. py:method:: don_mask(self)

    Agent puts on a mask, reducing contamination and viral load.

    :return: None

    .. py:method:: doff_mask(self)
    
        Agent removes mask if currently wearing a mask, increasing contamination and viral load.

        :return: None

    .. py:method:: process_effects(self)

        Agents have 'effects' that increase or decrease their susceptibility to the virus and their infectiousness. Here we run the effects on the agent.

        :return: None

    .. py:method:: under_effect(self, name)

        Checks to see if an agent is under an effect.

        :param name: The effect to check if the agent is under

        :return: Bool

    .. py:method:: set_facing(self, direction)
    
        Changes the direction the agent is currently facing.

        :param direction: A string, ['N', 'S', 'E', 'W']

        :return: None

Actions
--------------

Each agent has a script. A script is a time step keyed dictionary of actions. The different types of actions are defined below.

.. py:class:: Move(self, x, y, facing=None)

    Moves an agent from one square in the mobility space to another square.

    :param x: The x coordinate of the square to move the agent.
    :param y: The y coordinate of the square to move the agent.
    :param facing: The direction the agent is facing ['N', 'S', 'E', 'W']

.. py:class:: Leave(self)

    Removes an agent from the environment at the agent's current location, contains no methods.

.. py:class:: Enter(self, x, y, facing='N')

    Places an agent in the environment.

    :param x: The x coordinate of the agent's entrance.
    :param y: The y coordinate of the agent's entrance.
    :param facing: The direction the agent is facing ['N', 'S', 'E', 'W']

.. py:class:: Face(self, direction)

    Changes the direction an agent is facing.

    :param facing: The new direction for the agent to face ['N', 'S', 'E', 'W']

.. py:class:: Handwash(self)

    Reduces contamination load from surfaces, contains no methods.

.. py:class:: DonMask(self)
    
    Agent puts on a mask, reducing emission and pickup at the air and droplet layers, contains no methods.

.. py:class:: DoffMask(self)

    Agent removes a mask, returning emission and pickup coefficients to default rates, contains no methods.

.. py:class:: Pickup(self, target)

    Agent takes an object out of the environment exchanging contamination.

    :param target: The item to pickup.

.. py:class:: Putdown(self, target)

    Agents puts an object in its possession back into the environment.

    :param target: The item to put back down.

Barriers
--------------

These are objects in the environment that block contamination dispersion. Agents cannot interact with these objects.

.. py:class:: Barrier(self, x1, y1, x2, y2)

    A rectangular object in the mobility space that prevents movement and contamination flow. There are two types on inherited members, Wall and Shield. These classes have no discrete implementation, differences in transmission are handled by the model. 

    :param x1: X coordinate of bottom left corner of rectangle.
    :param y2: Y coordinate of bottom left corner of rectangle
    :param x2: X coordinate of top right corner of rectangle.
    :param y2: Y coordinate of top right corner of rectangle.

.. py:class:: Barrier.Shield(self, x1, y1, x2, y2)

    A barrier that stops only part of the flow of contamination.

.. py:class:: Barrier.Wall(self, x1, y1, x2, y2)

    A barrier that prevents all contamination flow.


Surfaces
---------

Surfaces are objects in the environment that agents can interact with and contain a level of contamination.

.. py:class:: Surface(self, name, init_x, init_y, transfer_efficiency, surface_ratio, surface_decay_rate)

    The base surface class, abstract (not used, only derived classes are used).

    :param name: The name of the surface.
    :param init_x: The X coordinate of the starting position of the surface in the environment.
    :param init_y: The Y coordinate of the starting position of the surface in the environment.
    :param transfer_efficiency: A user specified coefficient describing contamination between the surface and an agent during interaction.
    :param surface ratio: A user specified coefficient used to determine the transfer ratio.
    :param surface_decay_rate: The rate at which contamination on the surface decays.

.. py:class:: Surface.Fixture(name, init_x, init_y, transfer_efficiency, surface_ratio, touch_frequency, surface_decay_rate)

    A surface object that cannot be moved by agents (tables, etc.) and contains an additional parameter, the tough frequency.

    :param name: The name of the surface.
    :param init_x: The X coordinate of the starting position of the surface in the environment.
    :param init_y: The Y coordinate of the starting position of the surface in the environment.
    :param transfer_efficiency: A user specified coefficient describing contamination between the surface and an agent during interaction.
    :param surface ratio: A user specified coefficient used to determine the transfer ratio.
    :param touch_frequency: How often a user interacts with the surface.
    :param surface_decay_rate: The rate at which contamination on the surface decays.

.. py:class:: Surface.Item(self, name, init_x, init_y, transfer_efficiency, surface_ratio, surface_decay_rate)
    
    A surface that can be moved by agents, contains no additional parameters.

    :param name: The name of the surface.
    :param init_x: The X coordinate of the starting position of the surface in the environment.
    :param init_y: The Y coordinate of the starting position of the surface in the environment.
    :param transfer_efficiency: A user specified coefficient describing contamination between the surface and an agent during interaction.
    :param surface ratio: A user specified coefficient used to determine the transfer ratio.
    :param surface_decay_rate: The rate at which contamination on the surface decays.


Writers
--------

Writers are objects used to store model output into CSV files for further analysis. There are a number already written which were used in the initial project. If you need different output, implementing a new writer would be the proper way to add it to the model. Writers manage the creation of files, proper formatting, and the definition of files. They differ only in their fields.

.. py:class:: Writer()

    The base writer class, never instantiated.

    .. py:attribute:: FILE_NAME

        The name of the output file that will store the desired data (csv file).

        :type: String

.. py:class:: Writer.AerosolContaminationWriter

    Used to store the aerosol contamination by grid coordinates over time.
    
    .. py:method:: write(self, tick, x, y, contamination)

        :param tick: The time step of the data.
        :param x: The x coordinate of the data.
        :param y: The y coordinate of the data.
        :param contamination: The viral load at the time step at (x,y)

        :return: None

.. py:class:: Writer.AgentExposureWriter

    Used to store agent viral exposure over time.

    .. py:method:: write(self, name, tick, contamination_load_aerosol, contamination_load_droplet, accumulated_contamination_load_surface)

        :param name: The name of the agent.
        :param tick: The time step of the data.
        :param contamination_load_aerosol: The aerosol contamination of the agent at the timestep.
        :param contamination_load_droplet: The droplet contamination of the agent at the timestep.
        :param accumulated contamination_load_surface: The total contamination the agent has been exposed to on surfaces at the timestep.

        :return: None

.. py:class:: Writer.DropletContaminationWriter
    
    Used to store the droplet contamination by grid coordinates over time.

    .. py:method:: write(self, tick, x, y, contamination)

        :param tick: The time step of the data.
        :param x: The x coordinate of the data.
        :param y: The y coordinate of the data.
        :param contamination: The viral load at the time step at (x,y)

        :return: None

.. py:class:: Writer.SurfaceContaminationWriter

    Used to store the surface contamination by grid coordinates over time.

    .. py:method:: write(self, name, type, tick, x, y, contamination)

        :param name: The surface object name.
        :param type: The surface object type.
        :param tick: The time step of the data.
        :param x: The x coordinate of the object.
        :param y: The y coordinate of the object.
        :param contamination: The viral load of the surface at the time step.

        :return: None

Environment
------------

.. py:class:: Environment(self, height, width, decay_rate_air, decay_rate_droplet, decay_rate_surface, air_exchange_rate, droplet_to_surface_transfer_rate, barriers, walls)

    A cornerstone class that manages the interactions of contamination between surfaces, agent movement, and agent contagion. The environment must be a rectangular shape as defined by the width and height parameters. The units of the environment are defined in the configuration file (defaulted to 10cm x 10cm)

    :param height: The height in configuration defined units of the environment.
    :param width: The width in configuration defined units of the environment.
    :param decay_rate_air: The rate at which contamination decays in the air surface.
    :param decay_rate_droplet: The rate at which contamination decays in the droplet surface.
    :param air_exchange_rate: The rate at which air is ventilated out of the environment.
    :param droplet_to_surface_transfer_rate: The rate at which droplets are transferred to items in the environment.
    :param barriers: A list of all the barrier objects in the environment.
    :param walls: A list of all the wall objects in the environment.

    .. py:attribute:: mobility_space

        A list of lists (cartesian plane) of agents (in a set) corresponding to their location in the environment.

        :type: List of list of sets.

    .. py:attribute:: agent_lookup

        A dictionary keyed on agents for determining an agents location in the mobility space. Values are (X, Y) tuples.

        :type: Dictionary

    .. py:attribute:: surfaces

        A List of lists (cartesian plane) of surfaces (in a list) correspond to their location in the environment.

        :type: List of list of lists.

    .. py:method:: place_surfaces(self, surfaces)

        Takes a list of surfaces and uses their internal coordinates (X, Y) and places them into the environment.

        :param surfaces: A list of surface objects to place in the environment.

        :return: None

    .. py:method:: apply_entry(self, agent, entry)        

        Puts an agent into the environment.

        :param agent: The agent to place into the environment.
        :param entry: The the entry action containing the (X, Y) coordinates of where the agent enters the mobility space.

        :return: None

    .. py:method:: get_direction(self, x1, y1, x2, y2)

        Determines the direction ['N', 'S', 'E', 'W'] of point one to point two.

        :param x1: The X coordinate of the first point.
        :param y1: The Y coordinate of the second point.
        :param x2: The X coordinate of the second point.
        :param y2: The Y coordinate of the second point.

        :return: String, one of the following ['N', 'S', 'E', 'W']

    .. py:method:: process_agent_action(self, agent, action)
    
        Runs an agent action and handles the impact on the agent and on the environment.

        :param agent: The agent of the action.
        :param action: The action the agent is performing.

        :return: None

    .. py:method:: add_load_air(self, agent)

        Adds contamination to the aerosol and droplet surfaces based upon agent attributes.

        :param agent: The agent increasing contamination in the environment.

        :return: None

    .. py:method:: pickup_droplet(self, agent)

        Adds contamination to the agent based upon the agent's location in the environment.

        :param agent: The agent picking up contamination.

        :return: None

    .. py:method:: pickup_fixtures(self, agent)

        Adds contamination to the agent based upon surfaces the agent can reach and items held by the agent.

        :param agent: The agent exposed to fixture contamination.

        :return: None

    .. py:method:: hand_contaminate_fixtures(self, agent)

        Adds contamination to the fixtures the agent is holding.

        :param agent: The agent contaminating fixtures.

        :return: None

    .. py:method:: cleaning_surface(self)

        Removes all contamination from all surfaces.

        :return: None

    .. py:method:: decay_surface(self)
    
        Partially removes contamination from all surfaces based upon decay rate.

        :return: None

    .. py:method:: decay_air(self)

        Partially removes contamination from the air cells based upon decay rate.

        :return: None

    .. py:method:: diffuse_air(self)
        
        Diffuses (spreads) contamination between air cells based upon diffusal rate.

        :return: None

    .. py:method:: droplet_to_surface_transfer(self)

        Transfers droplets to surfaces that share the same coordinates in the environment.

        :return: None

    .. py:method:: surface_lookup(self, surface)

        Takes a surface and returns the coordinates of its current location in the environment.

        :param surface: The surface in question.

        :return: Tuple (X, Y)

    .. py:method reachable_surfaces(self, x, y)

        Gathers a list of all surface coordinates that are reachable from the passed in coordinates.

        :param x: The X coordinate of the center point.
        :param y: The Y coordinate of the center point.

        :return: List of (X, Y) tuples

Air
----

.. py:class:: Void(self, x, y)

    A dead air cell which issued as the legacy definition of walls in the model.

    :param x: The X coordinate of the void on the mobility grid.
    :param y: The Y coordinate of the void on the mobility grid.

.. py:class:: Edge(self, x1, y1, x2, y2)

    Used to represent barriers in air cells. Rather than taking up a full square in the mobility grid as the void does, this enables more complexity in barriers. This class is primarily used in reference by other classes (not much model logic implemented in the class).

    :param x1: The X coordinate of the first point of the edge. 
    :param y1: The Y coordinate of the first point of the edge.
    :param x2: The X coordinate of the second point of the edge.
    :param y2: The Y coordinate of the second point of the edge.

.. py:class:: Air(self, width, height, aerosol_decay_rate, droplet_decay_rate, air_exchange_rate, barriers, voids)

    Cornerstone class that contains all information and logic about the air surface suspended above the mobility layer. The majority of transmission logic is contained in this class.

    :param width: Width of Environment in MobilityCellSize scale.
    :param height: Height of Environment in MobilityCellSize scale.
    :param aerosol_decay_rate: Rate at which aerosol contaminate decays.
    :param droplet_decay_rate: Rate at which droplet contaminate decays.
    :param air_exchange_rate: Rate at which air is cycled in Environment.
    :param barriers: List of Barrier classes with coordinates scaled from MobilityCellSize to AirCellSize.
    :param voids: List of Void spaces to remove from the Air with coordinates scaled from MobilityCellSize to AirCellSize.

    .. py:method:: is_void(self, x, y)

        Determines if there is a void object at the given coordinate.

        :param x: The X coordinate of the point to check for a void object.
        :param y: The Y coordinate of the point to check for a void object.

        :return: Boolean

    .. py:method:: get_aerosol(self, x, y)

        Gathers the aerosol contamination at the coordinate.

        :param x: The X coordinate of the point to gather contamination.
        :param y: The Y coordinate of the point to gather contamination.

        :return: Float

    .. py:method:: get_droplet(self, x, y)

        Gathers the droplet contamination at the coordinate.

        :param x: The X coordinate of the point to gather contamination.
        :param y: The Y coordinate of the point to gather contamination.

        :return: Float


    .. py:method:: get_layer(self, x, y, layer)

        Gathers contamination from the layer at the coordinate.

        :param x: The X coordinate of the point to gather contamination.
        :param y: The Y coordinate of the point to gather contamination.

        :return: Float

    .. py:method:: add_aerosol(self, x, y, addition)

        Adds aerosol contamination to the coordinate.

        :param x: The X coordinate of the point to add the aerosol contamination.
        :param y: The Y coordinate of the point to add the aerosol contamination.
        :param addition: The amount of contamination to add to the point.

        :return: None

    .. py:method:: add_droplet(self, x, y, addition)

        Adds droplet contamination to the coordinate.

        :param x: The X coordinate of the point to add the droplet contamination.
        :param y: The Y coordinate of the point to add the droplet contamination.
        :param addition: The amount of contamination to add to the point.

        :return: None

    .. py:method:: subtract_aerosol(self, x, y, subtraction)

        Removes aerosol contamination from the coordinate.

        :param x: The X coordinate of the point to subtract the aerosol contamination.
        :param y: The Y coordinate of the point to subtract the aerosol contamination.
        :param subtraction: The amount of contamination to subtract from the point.

        :return: None

    .. py:method:: subtract_droplet(self, x, y, subtraction)

        Removes droplet contamination from the coordinate.

        :param x: The X coordinate of the point to subtract the droplet contamination.
        :param y: The Y coordinate of the point to subtract the droplet contamination.
        :param subtraction: The amount of contamination to subtract from the point.

        :return: None

    .. py:method:: decay(self)

        Traverses through each cell on the aerosol and the droplet layers and reduces their contamination by the decay rates set at initialization.

        :return: None

    .. py:method:: diffuse(self)

        Traverses through each cell on each layer and diffuses contamination to neighboring cells.

        :return: None

    .. py:method:: add_aerosol_pattern(self, x, y, addition, pattern, direction)

        Applies contamination in a pattern (2D array of cells to contaminate) based on the direction from the origin point.

        :param x: The X coordinate of emission origin.
        :param y: The Y coordinate of emission origin.
        :param addition: Amount of contaminate to apply over pattern.
        :param layer: Air.Layer to add the contamination at.
        :param pattern: EmissionPattern validated by make_pattern.
        :param direction: Cardinal direction of emission from origin ['N', 'S', 'E', 'W'].

        :return: None

Configuration Files
-------------------

A number of parameters in the model are changed very rarely. These parameters are kept in a configuration file independent of the environment and agents. There are two sets of configuration settings, model and output. Model parameters describe simulation settings. Output parameters describe how to save results to files for further analysis. Below is a sample configuration file.

.. code-block:: ini

    [Output]
    Suppress: True

    [Environment]
    CoughingRate: 121

Default values for the configuration files can be found in the source code under the config class. As seen above, values are overridden as needed by ini files.
