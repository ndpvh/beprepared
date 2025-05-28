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
#'          {how much the agent comes in contact with a virus through the three 
#'           different media}
#'     \item{\code{emission_rate_air}, \code{emission_rate_droplet}:}
#'          {how much the virus is spread through air or droplets by an infected
#'           agent}
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
#'     \item{\code{transfer_efficiency}:}
#'          {how efficiently contamination is spread on touch}
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
#'     \item{\code{transfer_efficiency}:}
#'          {how efficiently contamination on the item is spread on touch}
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
#' @param archetypes_filename Character denoting the path of where to find the 
#' values for the \code{predped} parameters. Defaults to \code{NULL}, using 
#' \code{predped}s defaults.
#' @param sep Character denoting the separator value used in the file specified
#' in \code{archetypes_filename}. Defaults to \code{","}.
#' @param dx Numeric denoting the width and height of each cell in the simulation.
#' While \code{predped} operates on continuous space, \code{QVEmod} requires 
#' this space to consist of discretized cells. This argument is therefore 
#' multiplied with the values of \code{AirCellSize}, \code{MobilityCellSize}, 
#' and \code{AgentReach}. Defaults to \code{0.1}, which should be interpreted as
#' 10cm, making \code{dx} in meters (i.e., just like the units of 
#' \code{environment}). This default is based on the contagion patterns of 
#' \code{QVEmod}, which are defined in 10cm as a unit. Note that QVEmod doesn't 
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
                     archetypes_filename = NULL,
                     sep = ",",
                     dx = 0.1,
                     path = file.path("results"),
                     filename = NULL, 
                     save_gif = FALSE,
                     plot_args = list(),
                     env_args = data.frame(),
                     surf_args = data.frame(),
                     item_args = data.frame(),
                     agent_args = data.frame(),
                     env_config = data.frame(),
                     output_config = data.frame(),
                     time_step = 0.5,
                     ...) {

    #---------------------------------------------------------------------------
    # Step 0: Check of arguments
    #---------------------------------------------------------------------------

    # Adjust the configuration data.frame's with the defaults 
    env_args <- defaults(env_args, default_env)
    surf_args <- defaults(surf_args, default_surf)
    item_args <- defaults(item_args, default_item)
    agent_args <- defaults(agent_args, default_agent)
    env_config <- defaults(env_config, default_env_config)
    output_config <- defaults(output_config, default_output_config)

    # Adjust the cell sizes in env_config with the dx argument
    env_config$AirCellSize <- env_config$AirCellSize * dx
    env_config$MobilityCellSize <- env_config$MobilityCellSize * dx
    env_config$AgentReach <- env_config$AgentReach * dx

    env_config$SimulationTimeStep <- env_config$SimulationTimeStep * time_step

    # Add current path to the output_config
    output_config$Path <- file.path(path, output_config$Path)



    #---------------------------------------------------------------------------
    # Step 1: Agent movement
    #---------------------------------------------------------------------------

    # Define the predped model to use for the simulation
    model <- predped::predped(
        setting = environment, 
        archetypes = archetypes, 
        weights = weights,
        filename = archetypes_filename,
        sep = sep
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
        function(x) grepl("surface", predped::id(x), fixed = TRUE)
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
            predped::size()
        env_center <- environment %>% 
            predped::shape() %>% 
            predped::center()
        
        if(length(env_size) == 1) {
            env_size <- rep(env_size, 2) * 2
        }

        air_dx <- (env_config$AirCellSize / env_config$MobilityCellSize) * dx
        x <- seq(
            env_center[1] - env_size[1]/2 + air_dx/2, 
            env_center[1] + env_size[1]/2 - air_dx/2, 
            by = air_dx
        )
        y <- seq(
            env_center[2] - env_size[2]/2 + air_dx/2, 
            env_center[2] + env_size[2]/2 - air_dx/2, 
            by = air_dx
        )
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

        # Counter to the documentation of QVEmod, Voids are defined on the air grid!
        void_centers <- void_centers[within > 0, ] %>% 
            as.data.frame() %>% 
            setNames(c("x", "y")) %>% 
            dplyr::mutate(
                x = as.integer((x + env_size[1]/2) / air_dx),
                y = as.integer((y + env_size[2]/2) / air_dx)
            )

    } else {
        void_centers <- data.frame(
            x = integer(0),
            y = integer(0)
        )
    }

    qve_environment <- python_functions$translate_env(
        shape_segments, 
        object_segments,
        void_centers,
        env_args
    )
    # qve_environment <- translate_env(
    #     shape_segments, 
    #     object_segments,
    #     void_centers,
    #     env_args
    # )

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
    surfaces <- python_functions$translate_items(
        discr_data, 
        item_args
    )
    # surfaces <- translate_items(
    #     discr_data, 
    #     item_args
    # )

    # Now do the `Fixture`s. These can only be done when there are any fixtures 
    # in the environment in the first place
    if(sum(idx) > 0) {
        # Translate to data.frame containing the necessary information
        obj <- lapply(
            predped::objects(environment)[idx],
            function(x) data.frame(
                id = predped::id(x), 
                x = predped::center(x)[1], 
                y = predped::center(x)[2],
                ratio = ifelse(
                    inherits(x, "circle"),
                    1,
                    predped::size(x)[1] / predped::size(x)[2]   # Derived what this should be from 'Menu' and 'Fork' examples
                )
            )
        )
        obj <- do.call("rbind", obj)

        # Assign parameter values and then translate the data.frame to `Fixture`s
        surf_args <- assign_values(
            obj$id, 
            surf_args
        )
        # obj <- python_functions$translate_surf(
        #     obj, 
        #     surf_args
        # )
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
        dplyr::arrange(id, time) %>% 
        dplyr::group_by(id) %>% 
        tidyr::nest() %>% 
        dplyr::mutate(
            data = data %>% 
                as.data.frame() %>% 
                dplyr::mutate(
                    x = relative_movement(x),
                    y = relative_movement(y)
                ) %>% 
                list()
        ) %>% 
        tidyr::unnest(data) %>% 
        dplyr::ungroup()

    agent_args <- assign_values(
        unique(discr_data$id),
        agent_args
    )
    agents <- python_functions$translate_data(
        discr_data, 
        agent_args
    )
    # agents <- translate_data(
    #     discr_data, 
    #     agent_args
    # )







    #---------------------------------------------------------------------------
    # Step 3: Infection risk
    #---------------------------------------------------------------------------  

    # Combine all information in a QVEmod `Model`
    viral_model <- python_functions$Model(
        as.integer(max(data$iteration) - 1), 
        qve_environment, 
        agents, 
        surfaces = surfaces
    )
    # viral_model <- Model(
    #     as.integer(max(data$iteration) - 1), 
    #     qve_environment, 
    #     agents, 
    #     surfaces = surfaces
    # )

    # Execute the model with the configuration
    cat("\rRunning viral model")
    python_functions$run_model(
        viral_model,
        list(env_config, output_config),
        c("env", "output")
    )
    # run_model(
    #     viral_model,
    #     list(env_config, output_config),
    #     c("env", "output")
    # )
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

    # If the filename is defined, save the results
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
        #
        # We delete all none-predped argument from the plot_args list first
        predped_args <- plot_args
        if(length(predped_args) != 0) {
            heatmap_labels <- c(
                "heatmap.fill", 
                "Z.label", 
                "Z.limits", 
                "X.limits", 
                "Y.limits", 
                "legend.position", 
                "legend.title.size", 
                "legend.text.size"
            )
            idx <- !(names(predped_args) %in% heatmap_labels)

            predped_args <- predped_args[idx]
        }
        movement <- do.call(
            predped::plot,
            list(trace, "print_progress" = FALSE) %>% 
                append(predped_args)
        )

        # Find out which agents are contagious and adjust the plots so that 
        # they are clearly shown in the gif.
        agent_args <- results[["agents"]]
        ill_agents <- agent_args$id[agent_args$viral_load == 1]
        env_size <- environment %>% 
            predped::shape() %>% 
            predped::size() 
        if(length(env_size) == 1) {
            env_size <- rep(env_size, 2) * 2
        }

        env_center <- environment %>% 
            predped::shape() %>% 
            predped::center() 

        # Check if there are any agents that are ill
        if(length(ill_agents) > 0) {
            # Get the color of the infection
            infected <- ifelse(
                is.null(plot_args$heatmap.fill), 
                "salmon",
                plot_args$heatmap.fill[2]
            )

            # Loop over all plots and add which agents are infected and which 
            # ones aren't
            movement <- lapply(
                seq_along(movement),
                function(i) {
                    # Retrieve all agents who were currently running around in the 
                    # simulation
                    agent_list <- predped::agents(trace[[i]])

                    # Loop over all these agents, check whether the agents are ill, and
                    # if so, add an X over this agent.
                    for(j in agent_list) {       
                        if(predped::id(j) %in% ill_agents) {                            
                            infected_agent <- do.call(
                                predped::plot, 
                                list(
                                    j,
                                    agent.fill = infected
                                ) %>%
                                    append(plot_args)
                            )
                            movement[[i]] <- movement[[i]] +
                                infected_agent
                        }
                    }

                    return(movement[[i]])
                }
            )
        }



        # Air level: Shows the changes in the air-level
        cat("\rVisualizing results: |==      |")

        # Read in the data
        data <- results[["aerosol"]]

        # Rescale X and Y to the continuous positions of the centers of their 
        # bins.
        data <- data %>% 
            dplyr::mutate(
                X = X * air_dx + env_center[1] - env_size[1]/2 + air_dx/2, 
                Y = Y * air_dx + env_center[2] - env_size[2]/2 + air_dx/2
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

                return(plt)
            }
        )



        # Droplet level: Shows the changes in the droplet-level
        cat("\rVisualizing results: |====    |")

        # Read in the data
        data <- results[["droplet"]]

        # Rescale X and Y to the continuous positions of the centers of their 
        # bins.
        data <- data %>% 
            dplyr::mutate(
                X = X * air_dx + env_center[1] - env_size[1]/2 + air_dx/2, 
                Y = Y * air_dx + env_center[2] - env_size[2]/2 + air_dx/2
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

                return(plt)
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

    # Delete the obsolete saved data.
    unlink(file.path(output_config$Path), recursive = TRUE)

    return(results)
}