testthat::test_that(
    "Test known errors",
    {
        params <- data.frame(
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
        )

        # id not defined
        testthat::expect_error(
            beprepared::assign_values(
                NULL,
                params
            )
        )

        # params not defined
        testthat::expect_error(
            beprepared::assign_values(
                "test",
                NULL
            )
        )

        # both are undefined
        testthat::expect_error(
            beprepared::assign_values()
        )

        # both are defined
        testthat::expect_no_error(
            beprepared::assign_values(
                "test",
                params
            )
        )
    }
)

testthat::test_that(
    "Test output",
    {
        # Simplified version
        params <- data.frame(
            prob = 1,
            viral_load = 1
        )

        ref <- data.frame(
            id = "test",
            viral_load = 1
        )
        tst <- beprepared::assign_values(
            "test",
            params
        )

        testthat::expect_equal(tst, ref)

        # More difficult version
        params <- data.frame(
            prob = 2, 
            viral_load = 1,
            contamination_load = 0
        )

        ref <- data.frame(
            id = c("1", "2", "3"),
            viral_load = rep(1, 3),
            contamination_load = rep(0, 3)
        )
        tst <- beprepared::assign_values(
            c("1", "2", "3"),
            params
        )

        testthat::expect_equal(tst, ref)
    }
)
