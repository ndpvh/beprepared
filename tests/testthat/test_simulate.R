testthat::test_that(
    "Simulate: Test expected errors",
    {
        # Not enough columns in env_args
        cols <- c(
            "decay_rate_air", 
            "decay_rate_droplet", 
            "decay_rate_surface", 
            "air_exchange_rate", 
            "droplet_to_surface_transfer_rate"
        )
        args <- rep(0, length(cols)) %>% 
            t() %>% 
            as.data.frame() %>% 
            setNames(cols)

        for(i in seq_along(cols)) {
            testthat::expect_error(
                beprepared::simulate(
                    "test",
                    background(shape = rectangle(center = c(0, 0), size = c(1, 1))),
                    env_args = args[, -i]
                )
            )
        }

        # Not enough columns in surf_args
        cols <- c(
            "prob", 
            "transfer_efficiency",
            "touch_frequency",
            "surface_decay_rate"
        )
        args <- rep(0, length(cols)) %>% 
            t() %>% 
            as.data.frame() %>% 
            setNames(cols)

        for(i in seq_along(cols)) {
            testthat::expect_error(
                beprepared::simulate(
                    "test",
                    background(shape = rectangle(center = c(0, 0), size = c(1, 1))),
                    surf_args = args[, -i]
                )
            )
        }

        # Not enough columns in item_args
        cols <- c(
            "prob", 
            "transfer_efficiency",
            "surface_ratio",
            "surface_decay_rate"
        )
        args <- rep(0, length(cols)) %>% 
            t() %>% 
            as.data.frame() %>% 
            setNames(cols)

        for(i in seq_along(cols)) {
            testthat::expect_error(
                beprepared::simulate(
                    "test",
                    background(shape = rectangle(center = c(0, 0), size = c(1, 1))),
                    item_args = args[, -i]
                )
            )
        }

        # Also for agent_args?
    }
)

# testthat::test_that(
#     "Simulate: Test of output",
#     {
#         # Mock environment
#         env <- predped::background(
#             shape = predped::rectangle(center = c(0, 0), size = c(5, 5)),
#             objects = list(
#                 predped::rectangle(
#                     id = "surface", 
#                     center = c(0, 0), 
#                     size = c(1, 1)
#                 )
#             ),
#             entrance = c(-2.5, 0)
#         )

#         # Do a simulation
#         set.seed(1)
#         output <- invisible(
#             capture.output(
#                 results <- beprepared::simulate(
#                      env,
#                      iterations = 25,
#                      max_agents = 5,
#                      add_agent_after = 1
#                 ) 
#             )
#         )

#         # Compare the different parts in results to the reference
#         ref <- readRDS(file.path("results", "ref_simulate.Rds"))

#         testthat::expect_equal(results[["agents"]], ref[["agents"]], tolerance = 1e-4)
#         testthat::expect_equal(results[["movement"]], ref[["movement"]], tolerance = 1e-4)
#         testthat::expect_equal(results[["aerosol"]], ref[["aerosol"]], tolerance = 1e-4)
#         testthat::expect_equal(results[["droplet"]], ref[["droplet"]], tolerance = 1e-4)
#         testthat::expect_equal(results[["surface"]], ref[["surface"]], tolerance = 1e-4)
#         testthat::expect_equal(results[["agent_exposure"]], ref[["agent_exposure"]], tolerance = 1e-4)
#     }
# )
