#' Simulate agent movements
#' 
#' Use the \code{\link[predped]{simulate,predped-method}} function to simulate 
#' agent movements and assess the risk of infection for each of the agents in 
#' the simulation. Combines the different steps that you would normally have 
#' to go through in one function, allowing one to simulate data with minimal 
#' effort.
#' 
#' @details 
#' This function allows for simulating viral disease spread through a 
#' combination two simulation models, namely the M4MA pedestrian model
#' (which governs walking behavior) and the QVE viral disease spread
#' model (which governs disease spread). The packages surrounding these models 
#' are used for the simulation and allow for a lot of personalization, providing
#' a lot of flexibility on the side of the user. In what follows, one will see 
#' which parameters can be changed and for what purposes.
#' 
#' With regard to the M4MA, one can change all of the arguments of the 
#' \code{\link[predped]{simulate,predped-method}} function from the \code{predped}
#' package by calling them as an independent argument. For example, if one wants
#' to change the number of iterations of the simulation to \code{1000}, one 
#' should call \code{simulate(<filename>, <environment>, iterations = 1000)}, 
#' where \code{<filename>} and \code{<environment>} are a user-provided filename
#' and environment in which the agents have to walk around. 
#' 
#' For a full list of arguments that can be used to tweak the walking simulation, 
#' we refer to the documentation of the 
#' \code{\link[predped]{simulate,predped-method}} function. Here, we only list 
#' the most interesting arguments:
#' 
#' \itemize{
#'     \item{\code{iterations}:}
#'          {integer, the number of the iterations the simulation should run}
#'     \item{\code{max_agents}:}
#'          {integer, the number of agents that are maximally allowed in the room}
#'     \item{\code{add_agent_after}:}
#'          {integer, the minimal number of iterations between each agent 
#'           entering the space}
#'     \item{\code{goal_number}:}
#'          {integer or function, the number of goals each agent will have in 
#'           the simulation (if integer) or a function that determines this 
#'           number through random sampling, taking in a single argument for the 
#'           number of draws to sample (e.g., \code{function(x) rnorm(x, 10, 2)})}
#'     \item{\code{goal_duration}:}
#'          {integer or function, determines the number of iterations it takes 
#'           to complete a goal in the same way as for \code{goal_number}}
#'     \item{\code{individual_differences}:}
#'          {logical, whether the parameters of the agents are allowed to differ 
#'           slightly between agents}
#'     \item{\code{fx}:}
#'          {function, a function that is executed at each iteration, allowing 
#'           the user to change a given state of the simulation, influencing the 
#'           future of the simulation (e.g., useful to invoke evacuation 
#'           behavior)}
#'     \item{\code{print_iterations}:}
#'          {logical, whether to print at which iteration the model is currently}
#' }
#' 
#' With regard to QVE, one can change most of the characteristics that guide the 
#' viral disease spread. These characteristics have been neatly categorized 
#' according to the object to which they apply, namely to the agents, environment, 
#' surfaces, and items, each through supplying a \code{data.frame} to the 
#' respective arguments \code{agent_args}, \code{env_args}, \code{surf_args}, 
#' and \code{item_args}. Importantly, these \code{data.frame}s should all be 
#' fully specified for the code to work, meaning that you should specify all 
#' parameters if you wish to change the defaults.
#' 
#' The \code{agent_args} take in the following specifications (all numeric 
#' vectors):
#' \itemize{
#'     \item{\code{prob}:}
#'          {probability of assigning this parameter set to an agent}
#'     \item{\code{viral_load}:}
#'          {the viral load of the agent}
#'     \item{\code{contamination_load_air}, \code{contamination_load_droplet}, 
#'           \code{contamination_load_surface}:}
#'          {contamination load of the agent through the three different ways to 
#'           spread and pick up the virus}
#'     \item{\code{emission_rate_air}, \code{emission_rate_droplet}:}
#'          {how much the virus is spread through air or droplets}
#'     \item{\code{pick_up_air}, \code{pick_up_droplet}:}
#'          {how much the virus is picked up through air and droplets}
#'     \item{\code{wearing_mask}:}
#'          {whether the agent is wearing a mask, indicated by a 0 (for false) or
#'           a 1 (for true)}
#' }
#' 
#' The \code{env_args} take in the following specifications (singular numerics):
#' \itemize{
#'     \item{\code{decay_rate_air}, \code{decay_rate_droplet}, \code{decay_rate_surface}:}
#'          {how much the contamination decays across media}
#'     \item{\code{air_exchange_rate}:}
#'          {how much the air in the room is refreshed}
#'     \item{\code{droplet_to_surface_transfer_rate}:}
#'          {how much contamination in the droplets is transferred to a surface}
#' }
#' 
#' The \code{surf_args} take in the following specifications (numeric vectors):
#' \itemize{
#'     \item{\code{prob}:}
#'          {probability of assigning a given set of surface parameters to a 
#'           particular surface in the environment}
#'     \item{\code{transfer_decay_rate}:}
#'          {how much contamination on the surface decays on touch}
#'     \item{\code{touch_frequency}:}
#'          {how often agents touch the surface}
#'     \item{\code{surface_decay_rate}:}
#'          {how much contamination on the surface decays}
#' }
#' 
#' The \code{item_args} take in the following specifications (numeric vectors):
#' \itemize{
#'     \item{\code{prob}:}
#'          {probability of assigning a given set of item parameters to a 
#'           particular goal that the agent has accomplished}
#'     \item{\code{transfer_decay_rate}:}
#'          {how much contamination on the item decays on touch}
#'     \item{\code{surface_ratio}:}
#'          {ratio of the height vs the width of the item}
#'     \item{\code{surface_decay_rate}:}
#'          {how much contamination on the surface of the item decays}
#' }
#' 
#' For full information on the arguments one can change and examples, we refer 
#' the interested reader to the documentations of \code{predped} and 
#' \code{QVEmod}.
#' 
#' @param environment Object of the \code{\link[predped]{background-class}} 
#' denoting the environment in which agents are to walk around.
#' @param archetypes Character vector denoting the parameter sets of 
#' \code{predped} to use for the simulation. Defaults to "BaselineEuropean".
#' @param weights Numeric vector denoting the probability with which each 
#' parameter set can be chosen to enter the simulation. Defaults to equal 
#' weighing of each entry in \code{archetypes}.
#' @param dx Numeric denoting the width and height of each cell in the simulation.
#' While \code{predped} operates on continuous space, \code{QVEmod} requires 
#' this space to consist of discretized cells. This argument is therefore 
#' multiplied with the values of \code{AirCellSize}, \code{MobilityCellSize}, 
#' and \code{AgentReach}. Defaults to \code{0.01}, which should be interpreted as
#' 1cm, making \code{dx} in meters (i.e., just like the units of 
#' \code{environment}). This default is based on the contagion patterns of 
#' \code{QVEmod}, which are defined in cm as a unit. Note that QVEmod doesn't 
#' allow changes to this argument yet.
#' @param path String denoting the path under which to save the results of the 
#' simulation. Defaults to a folder "results" under the current directory.
#' @param filename Character denoting what to call this simulation in the output
#' files. Defaults to \code{NULL}, meaning results won't be saved.
#' @param save_gif Logical denoting whether to save a gif of the simulation. 
#' Only shows the movement of the agents, not whether they are spreading a 
#' disease. Defaults to \code{FALSE}.
#' @param plot_args Named list containing optional arguments to use when 
#' plotting the simulation. Only used when \code{save_gif = TRUE}. Defaults to 
#' an empty list.
#' @param env_args Data.frame containing optional arguments for the parameters 
#' that make up the \code{Environment} as defined by QVEmod. Defaults to the 
#' values used by default through QVEmod.
#' @param surf_args Data.frame containing optional arguments for the parameters 
#' that make up the \code{Fixture}s in the environment, as defined by QVEmod. 
#' Defaults to the values used by default through QVEmod.
#' @param item_args Data.frame containing optional arguments for the parameters 
#' that make up the \code{Item}s in the environment, as defined by QVEmod. 
#' Defaults to the values used by default through QVEmod.
#' @param agent_args Data.frame containing optional arguments for the parameters 
#' that make up the \code{Agent}s in the simulation, as defined by QVEmod. 
#' Defaults to the values used by default through QVEmod.
#' @param env_config Data.frame containing optional arguments for the 
#' configuration of the environment. Defaults to the values found in the 
#' `default_config.json` file of QVEmod.
#' @param output_config Data.frame containing optional arguments for the 
#' configuration of the output Defaults to the values found in the 
#' `default_config.json` file of QVEmod.
#' @param time_step Numeric denoting the time between each iteration. Defaults 
#' to \code{0.5} (the same as in \code{\link[predped]{simulate,predped-method}}).
#' @param ... Additional arguments passed on to 
#' \code{\link[predped]{simulate,predped-method}}
#' 
#' @return Named list containing the results of the simulation, where 
#' \code{"agents"} contains the viral parameters of the agents, \code{"movement"}
#' the positions of the agents at each time step, \code{"aerosol"}, 
#' \code{"droplet"}, and \code{"surface"} the contamination of the agents through
#' each source, and \code{"agent_exposure"} the total infection risk of the agent
#' 
#' @export 
#
# DEFAULTS QVEmod
#   - For Environment, taken from the example in main.py
#   - For Items, taken from the "Menu" in the example in main.py, except for 
#     surface ratio, which I assume to be equal to 0.5 (a square): predped does
#     not have surfaced goals
#   - For Fixtures, taken from the "Table" in the example in main.py
#   - For Agent, taken from the three cases in the example of main.py
simulate <- function(environment, 
                     archetypes = "BaselineEuropean", 
                     weights = rep(1 / length(archetypes), length(archetypes)), 
                     dx = 0.01,
                     path = file.path("results"),
                     filename = NULL, 
                     save_gif = FALSE,
                     plot_args = list(),
                     env_args = data.frame(
                        decay_rate_air = 1.51, 
                        decay_rate_droplet = 0.3, 
                        decay_rate_surface = 0.262,
                        air_exchange_rate = 0.2, 
                        droplet_to_surface_transfer_rate = 18.18
                     ),
                     surf_args = data.frame(
                        prob = 1, 
                        transfer_decay_rate = 0.5,
                        touch_frequency = 15,
                        surface_decay_rate = 0.969
                     ),
                     item_args = data.frame(
                        prob = 1,
                        transfer_decay_rate = 0.7, 
                        surface_ratio = 0.5,
                        surface_decay_rate = 0.274
                     ),
                     agent_args = data.frame(
                        prob = rep(1/3, 3),
                        viral_load = c(1, 0, 0), 
                        contamination_load_air = c(0, 0, 0), 
                        contamination_load_droplet = c(0, 0, 0), 
                        contamination_load_surface = c(1, 0, 0),
                        emission_rate_air = rep(0.53, 3), 
                        emission_rate_droplet = rep(0.47, 3), 
                        pick_up_air = c(2.3, 30, 30), 
                        pick_up_droplet = c(2.3, 30, 30),
                        wearing_mask = c(0, 0, 0)
                     ),
                     env_config = data.frame(
                        AirCellSize = 500,
                        MobilityCellSize = 100,
                        AgentReach = 500,
                        SimulationTimeStep = 1/(120 * 30),
                        HandwashingContaminationFraction = 0.3,
                        HandwashingEffectDuration = 0.5,
                        MaskEmissionAerosolReductionEfficiency = 0.4,
                        MaskEmissionDropletReductionEfficiency = 0.04,
                        MaskAerosolProtectionEfficiency = 0.4,
                        MaskDropletProtectionEfficiency = 0.04,
                        CleaningInterval = 1,
                        Diffusivity = 23,
                        WallAbsorbingProportion = 0.0,
                        CoughingRate = 121,
                        CoughingFactor = 1,
                        CoughingAerosolPercentage = 1.0,
                        CoughingDropletPercentage = 1.0,
                        SurfaceExposureRatio = 0.01
                     ),
                     output_config = data.frame(
                        Suppress = FALSE,
                        Path = file.path(path, "output"),
                        AerosolContaminationWriteInterval = 15,
                        AerosolContaminationPrecision = 17,
                        DropletContaminationWriteInterval = 15,
                        DropletContaminationPrecision = 17,
                        SurfaceContaminationWriteInterval = 15,
                        SurfaceContaminationPrecision = 17
                     ),
                     time_step = 0.5,
                     ...) {

    #---------------------------------------------------------------------------
    # Step 0: Check of arguments
    #---------------------------------------------------------------------------

    # Function for checking the presence of the necessary columns in the arguments
    # to be passed on to QVEmod
    check_columns <- function(expected, 
                              received,
                              argument) {

        check <- expected %in% received

        if(!all(check)) {
            stop(
                paste(
                    "Columns",
                    expected[check], 
                    "not defined in argument", 
                    argument
                )
            )
        }
    }

    # Check the arguments for the QVEmod Environment class
    cols <- c(
        "decay_rate_air", 
        "decay_rate_droplet", 
        "decay_rate_surface", 
        "air_exchange_rate", 
        "droplet_to_surface_transfer_rate"
    )
    check_columns(cols, colnames(env_args), "`env_args`")
    
    # Check the arguments for the QVEmod Fixture class
    cols <- c(
        "prob", 
        "transfer_decay_rate",
        "touch_frequency",
        "surface_decay_rate"
    )
    check_columns(cols, colnames(surf_args), "`surf_args`")

    # Check the arguments for the QVEmod Item class
    cols <- c(
        "prob", 
        "transfer_decay_rate",
        "surface_ratio",
        "surface_decay_rate"
    )
    check_columns(cols, colnames(item_args), "`item_args`")

    # Multiply the discretization space in the env_config with dx, putting it on 
    # the meter scale
    env_config$AirCellSize <- env_config$AirCellSize * dx
    env_config$MobilityCellSize <- env_config$MobilityCellSize * dx
    env_config$AgentReach <- env_config$AgentReach * dx

    # Multiply the time_step with the env_config times
    env_config$SimulationTimeStep <- env_config$SimulationTimeStep * time_step




    #---------------------------------------------------------------------------
    # Step 1: Agent movement
    #---------------------------------------------------------------------------

    # Define the predped model to use for the simulation
    model <- predped::predped(
        setting = environment, 
        archetypes = archetypes, 
        weights = weights
    )

    # Actually do the simulation and transform the data to a time-series format.
    trace <- predped::simulate(model, time_step = time_step, ...)
    data <- predped::time_series(trace)

    # Add an indicator that says whether the agent has performed their goal or 
    # not. Used in the translation functions
    data <- data %>% 
        dplyr::arrange(id, time) %>% 
        dplyr::mutate(end_goal = c(FALSE, diff(goal_x) != 0))





    #---------------------------------------------------------------------------
    # Step 2: Translation of trace to QVEmod
    #---------------------------------------------------------------------------    

    # Get all surfaces out of the objects list
    idx <- sapply(
        predped::objects(environment), 
        function(x) grepl("surface", id(x), fixed = TRUE)
    )

    # Get the value to use as the value for `min_x` in `discretize`. This value 
    # corresponds to the minimal value of `x` and `y` extracted from the shape
    # of the environment.
    origin <- environment %>% 
        predped::shape() %>% 
        predped::points() %>% 
        matrixStats::colMins()

    # Discretize the relevant positions in the data, them being the positions of 
    # the agents and the position of the goals.
    discr_data <- data %>% 
        dplyr::mutate(
            x = discretize(
                x, 
                min_x = origin[1],
                dx = dx
            ),
            y = discretize(
                y, 
                min_x = origin[2],
                dx = dx
            ),
            goal_x = discretize(
                goal_x, 
                min_x = origin[1],
                dx = dx
            ),
            goal_y = discretize(
                goal_y,
                min_x = origin[2],
                dx = dx
            )
        )

    # Translate the environment. First translate shape and objects (not surfaces)
    # to segments with a start and end point. Then use these segments to 
    # translate them to Walls and Barriers using the Python-defined translate 
    # function, as expected by the QVEmod functions.
    shape_segments <- environment %>% 
        predped::shape() %>% 
        segmentize(
            discretize = TRUE,
            origin = origin,
            dx = dx
        ) 

    object_segments <- lapply(
        predped::objects(environment)[!idx],
        \(x) segmentize(
            x, 
            discretize = TRUE,
            origin = origin,
            dx = dx
        )
    )
    object_segments <- do.call("rbind", object_segments)

    # We also need to impose Voids in the environment. Importantly, these are 
    # defined on the air-cell level, not on the general space level.
    #
    # Note that if there are only surfaces in the environment, no void centers 
    # exist (they only exist in unreachable spaces)
    if(sum(!idx) > 1) {
        env_size <- environment %>% 
            predped::shape() %>% 
            size()

        air_dx <- (env_config$AirCellSize / env_config$MobilityCellSize) * dx
        x <- seq(air_dx/2, env_size[1] - air_dx/2, by = air_dx)
        y <- seq(air_dx/2, env_size[2] - air_dx/2, by = air_dx)
        void_centers <- cbind(
            rep(x, each = length(y)),
            rep(y, times = length(x))
        )

        within <- rowSums(
            sapply(
                predped::objects(environment)[!idx],
                \(x) predped::in_object(x, void_centers)
            )
        )

         void_centers <- void_centers[within > 0, ] %>% 
            as.data.frame() %>% 
            setNames(c("x", "y")) %>% 
            dplyr::mutate(
                x = as.integer((x - air_dx/2) / air_dx),
                y = as.integer((y - air_dx/2) / air_dx)
            )

    } else {
        void_centers <- data.frame(
            x = integer(0),
            y = integer(0)
        )
    }

    qve_environment <- translate_env(
        shape_segments, 
        object_segments,
        void_centers,
        env_args
    )

    # Translate the surfaces and items, which need to be provided to the model 
    # separately. For both `Item`s and `Surface`s, we make an additional check
    # of the defaults, as a completely empty data.frame would give an error.
    # Note that for both, the positions have been discretized above already.
    #
    # First do the `Item`s
    item_args <- assign_values(
        unique(data$goal_id),
        item_args
    )
    surfaces <- translate_items(
        discr_data, 
        item_args
    )

    # Now do the `Fixture`s. These can only be done when there are any fixtures 
    # in the environment in the first place
    if(sum(idx) > 0) {
        # Translate to data.frame containing the necessary information
        obj <- lapply(
            predped::objects(environment)[idx],
            function(x) data.frame(
                id = id(x), 
                x = center(x)[1], 
                y = center(x)[2],
                ratio = size(x)[1] / size(x)[2]   # Derived what this should be from 'Menu' and 'Fork' examples
            )
        )

        # Assign parameter values and then translate the data.frame to `Fixture`s
        surf_args <- assign_values(
            obj$id, 
            surf_args
        )
        obj <- translate_surf(
            obj, 
            surf_args
        )

        # Add to the surfaces. Necessary, as items and surfaces share a same 
        # argument in QVEmod
        surfaces <- append(
            surfaces, 
            obj
        )
    } 

    # Translate the time-series data itself to a list of Actions and Agents that
    # execute them. Importantly, movement is relative to the previous position,
    # meaning that we first need to make it so. 
    discr_data <- discr_data %>% 
        dplyr::group_by(id) %>% 
        dplyr::arrange(id, time) %>% 
        dplyr::mutate(
            x = ifelse(
                length(x) > 1, 
                c(x[1], x[2:length(x)] - x[2:length(x) - 1]),
                x[1]
            ),
            y = ifelse(
                length(y) > 1,
                c(y[1], y[2:length(y)] - y[2:length(y) - 1]),
                y[1]
            )
        ) %>% 
        dplyr::ungroup()

    agent_args <- assign_values(
        unique(discr_data$id),
        agent_args
    )
    agents <- translate_data(
        discr_data, 
        agent_args
    )







    #---------------------------------------------------------------------------
    # Step 3: Infection risk
    #---------------------------------------------------------------------------  

    # Combine all information in a QVEmod `Model`
    viral_model <- Model(
        as.integer(max(data$iteration)), 
        qve_environment, 
        agents, 
        surfaces = surfaces
    )

    # Execute the model with the configuration
    # browser()
    cat("\rRunning viral model")
    run_model(
        viral_model,
        list(env_config, output_config),
        c("env", "output")
    )
    cat("\n")







    #---------------------------------------------------------------------------
    # Step 4: Visualization and data handling
    #---------------------------------------------------------------------------  

    # Save all of the results in an .Rds file. Is by far the easiest way to keep 
    # all data together and unique (as QVEmod automatically overrides results).
    # Also add the agent characteristics, which will help for determining risk.
    results <- list(
        "agents" = agent_args,
        "movement" = data, 
        "aerosol" = data.table::fread(
            file.path(output_config$Path, "aerosol_contamination.csv"),
            data.table = FALSE
        ), 
        "droplet" = data.table::fread(
            file.path(output_config$Path, "droplet_contamination.csv"),
            data.table = FALSE
        ),
        "surface" = data.table::fread(
            file.path(output_config$Path, "surface_contamination.csv"),
            data.table = FALSE
        ), 
        "agent_exposure" = data.table::fread(
            file.path(output_config$Path, "agent_exposure.csv"),
            data.table = FALSE
        )
    )

    if(!is.null(filename)) {
        saveRDS(
            results,
            file.path(path, paste0(filename, ".Rds"))
        )
    }

    # If you want to save the gif of this simulation, do so
    if(save_gif) {
        # Movement level: Shows the agents walking around without any other 
        # nuisances.
        cat("\rVisualizing results: |        |")
        
        # First create the plots through predped. Given that plot_args is a list 
        # of arguments to pass along the plot function, we need to add the trace
        # to this list and use do.call to actually perform the plotting.
        movement <- do.call(
            plot,
            list(trace, "print_progress" = FALSE) %>% 
                append(plot_args)
        )

        # Find out which agents are contagious and adjust the plots so that 
        # they are clearly shown in the gif.
        ill_agents <- agent_args$id[agent_args$viral_load == 1]
        env_size <- environment %>% 
            shape() %>% 
            size() %>% 
            max()

        for(i in seq_along(trace)) {
            # Retrieve all agents who were currently running around in the 
            # simulation
            agent_list <- agents(trace[[i]])

            # Loop over all these agents, check whether the agents are ill, and
            # if so, add an X over this agent.
            for(j in agent_list) {                
                if(id(j) %in% ill_agents) {
                    movement[[i]] <- movement[[i]] +
                        ggplot2::annotate(
                            "text", 
                            label = "X",
                            x = position(j)[1],
                            y = position(j)[2],
                            color = color(j),
                            hjust = 0.5,
                            size = 500 * radius(j) / env_size
                        )
                }
            }
        }



        # Air level: Shows the changes in the air-level
        cat("\rVisualizing results: |==      |")

        # Read in the data
        data <- data.table::fread(
            file.path(output_config$Path, "aerosol_contamination.csv"),
            data.table = FALSE
        )

        # Rescale X and Y to the continuous positions of the centers of their 
        # bins.
        data <- data %>% 
            dplyr::mutate(
                X = X * air_dx + air_dx/2, 
                Y = Y * air_dx + air_dx/2
            ) %>% 
            dplyr::rename(Z = Contamination) 

        # Create a heatmap for each Tick separately
        air <- lapply(
            seq_along(movement),
            function(i) {
                # Make sure you always have some data to report on
                idx <- data$Tick == i - 1
                if(sum(idx) == 0) {
                    idx <- data$Tick == max(data$Tick[data$Tick < i - 1])
                } 
                
                plt <- do.call(
                    heatmap, 
                    append(
                        list(
                            data[idx, ],
                            "X.limits" = range(shape(environment)@points[, 1]),
                            "Y.limits" = range(shape(environment)@points[, 2]),
                            "Z.label" = "Contamination",
                            "plot.title" = "Air contamination",
                            "legend.position" = "none"
                        ), 
                        plot_args
                    )
                )
            }
        )



        # Droplet level: Shows the changes in the droplet-level
        cat("\rVisualizing results: |====    |")

        # Read in the data
        data <- data.table::fread(
            file.path(output_config$Path, "droplet_contamination.csv"),
            data.table = FALSE
        )

        # Rescale X and Y to the continuous positions of the centers of their 
        # bins.
        data <- data %>% 
            dplyr::mutate(
                X = X * air_dx + air_dx/2, 
                Y = Y * air_dx + air_dx/2
            ) %>% 
            dplyr::rename(Z = Contamination)

        # Create a heatmap for each Tick separately
        droplet <- lapply(
            seq_along(movement),
            function(i) {
                # Make sure you always have some data to report on
                idx <- data$Tick == i - 1
                if(sum(idx) == 0) {
                    idx <- data$Tick == max(data$Tick[data$Tick < i - 1])
                } 
                
                plt <- do.call(
                    heatmap, 
                    append(
                        list(
                            data[idx, ],
                            "X.limits" = range(shape(environment)@points[, 1]),
                            "Y.limits" = range(shape(environment)@points[, 2]),
                            "Z.label" = "Contamination",
                            "plot.title" = "Droplet contamination",
                            "legend.position" = "none"
                        ), 
                        plot_args
                    )
                )
            }
        )



        # Create a GIF displaying all of the information
        cat("\rVisualizing results: |======  |")

        # Combine all plots for each iteration with each other
        plt <- lapply(
            seq_along(movement),
            \(i) ggpubr::ggarrange(
                plotlist = list(
                    movement[[i]],
                    air[[i]],
                    droplet[[i]]
                ),
                nrow = 1
            )
        )

        gifski::save_gif(
            lapply(plt, \(x) print(x)),
            file.path(path, paste0(filename, ".gif")),
            delay = 1/10,
            progress = FALSE
        )

        cat("\rVisualizing results: |========|\n")
    }

    return(results)
}