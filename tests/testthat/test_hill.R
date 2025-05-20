testthat::test_that(
    "Hill: Test known errors",
    {
        # Character arguments
        testthat::expect_error(
            beprepared::hill_function("test")
        )

        testthat::expect_error(
            beprepared::hill_function(1, alpha = "test")
        )

        testthat::expect_error(
            beprepared::hill_function(1, lambda = "test")
        )

        # Logical arguments
        testthat::expect_error(
            beprepared::hill_function(TRUE)
        )

        testthat::expect_error(
            beprepared::hill_function(1, alpha = TRUE)
        )

        testthat::expect_error(
            beprepared::hill_function(1, lambda = TRUE)
        )

        # Empty arguments
        testthat::expect_no_error(
            beprepared::hill_function(numeric(0))
        )

        testthat::expect_error(
            beprepared::hill_function(1, alpha = numeric(0))
        )

        testthat::expect_error(
            beprepared::hill_function(1, lambda = numeric(0))
        )

        # Vector arguments
        testthat::expect_no_error(
            beprepared::hill_function(rep(1, 10))
        )

        testthat::expect_error(
            beprepared::hill_function(1, alpha = rep(1, 10))
        )

        testthat::expect_error(
            beprepared::hill_function(1, lambda = rep(1, 10))
        )
        
        # Defaults should work
        testthat::expect_no_error(
            beprepared::hill_function(1)
        )
    }
)

testthat::test_that(
    "Hill: Test output",
    {
        tst <- beprepared::hill_function(
            1:5, 
            alpha = 1, 
            lambda = 2
        )
        ref <- (1:5) / (2 + 1:5)

        testthat::expect_equal(tst, ref)
    }
)
