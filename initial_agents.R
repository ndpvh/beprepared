################################################################################
# initial_agents.R                                                             #
#                                                                              #
# PURPOSE: Define some initial agents that should be used within a given       #
#          environment. Is reserved for people who work in a given             #
#          environment (e.g., cashiers, bartenders,...).                       #
################################################################################

initial_agents <- list() 





################################################################################
# SUPERMARKETS
################################################################################

# For Supermarket 1, there are no cashiers and thus no-one to account for
initial_agents[["supermarket 1"]] <- list()

# Create the cashiers for Supermarket 2. These cashiers will be the same in the 
# free flow condition and the restricted condition.
#
# Note that we just use the BaselineEuropean parameters for these cashiers and 
# make them the default 0.25 size. In reality, their size does not matter, nor 
# do their parameters, as they won't walk around.
initial_agents[["supermarket 2: free flow"]] <- list(
    predped::agent(
        id = "cashier 1",
        center = c(21.7, 0.305),
        radius = 0.25,
        orientation = 90,
        current_goal = predped::goal(
            id = "goal exit",
            path = matrix(0, nrow = 1, ncol = 2)
        ),
        status = "wait",
        waiting_counter = 1000,
        parameters = predped::params_from_csv[["params_archetypes"]] %>%
            dplyr::filter(name == "BaselineEuropean")
    ),
    predped::agent(
        id = "cashier 2",
        center = c(21.7, 2.175),
        radius = 0.25,
        orientation = 270,
        current_goal = predped::goal(
            id = "goal exit",
            path = matrix(0, nrow = 1, ncol = 2)
        ),
        status = "wait",
        waiting_counter = 1000,
        parameters = predped::params_from_csv[["params_archetypes"]] %>%
            dplyr::filter(name == "BaselineEuropean")
    ),
    predped::agent(
        id = "cashier 3",
        center = c(21.7, 2.785),
        radius = 0.25,
        orientation = 90,
        current_goal = predped::goal(
            id = "goal exit",
            path = matrix(0, nrow = 1, ncol = 2)
        ),
        status = "wait",
        waiting_counter = 1000,
        parameters = predped::params_from_csv[["params_archetypes"]] %>%
            dplyr::filter(name == "BaselineEuropean")
    ),
    predped::agent(
        id = "cashier 4",
        center = c(21.7, 4.655),
        radius = 0.25,
        orientation = 270,
        current_goal = predped::goal(
            id = "goal exit",
            path = matrix(0, nrow = 1, ncol = 2)
        ),
        status = "wait",
        waiting_counter = 1000,
        parameters = predped::params_from_csv[["params_archetypes"]] %>%
            dplyr::filter(name == "BaselineEuropean")
    ),
    predped::agent(
        id = "cashier 5",
        center = c(21.7, 5.265),
        radius = 0.25,
        orientation = 90,
        current_goal = predped::goal(
            id = "goal exit",
            path = matrix(0, nrow = 1, ncol = 2)
        ),
        status = "wait",
        waiting_counter = 1000,
        parameters = predped::params_from_csv[["params_archetypes"]] %>%
            dplyr::filter(name == "BaselineEuropean")
    ),
    predped::agent(
        id = "cashier 6",
        center = c(21.7, 7.135),
        radius = 0.25,
        orientation = 270,
        current_goal = predped::goal(
            id = "goal exit",
            path = matrix(0, nrow = 1, ncol = 2)
        ),
        status = "wait",
        waiting_counter = 1000,
        parameters = predped::params_from_csv[["params_archetypes"]] %>%
            dplyr::filter(name == "BaselineEuropean")
    )
)

initial_agents[["supermarket 2: restricted"]] <- initial_agents[["supermarket 2: free flow"]]
