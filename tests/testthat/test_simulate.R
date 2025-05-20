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
            "transfer_decay_rate",
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
            "transfer_decay_rate",
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
