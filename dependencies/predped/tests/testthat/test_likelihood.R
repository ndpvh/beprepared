testthat::test_that("Likelihood R and Rcpp converge", {
    ############################################################################
    # SUMMED

    # Read in some test data. Of these, select only the first 100, as these 
    # already contain all necessary ingredients (social simulation)
    data <- readRDS(file.path("data", "data_mll.Rds"))
    data <- data[!is.na(data$ps_speed), ]
    data <- data[1:100, ]

    # Retrieve the parameters of the SocialBaselineEuropean
    params <- predped::params_from_csv[["params_archetypes"]]
    params <- params[params$name == "SocialBaselineEuropean", ]

    # Create test and reference and compare both across all datapoints. Here, 
    # we don't transform the parameters
    ref <- predped::mll(data, params, transform = FALSE, cpp = FALSE, summed = TRUE)
    tst <- predped::mll(data, params, transform = FALSE, cpp = TRUE, summed = TRUE)

    testthat::expect_equal(ref, tst)

    # And now do one where you do transform the parameters
    params <- predped::to_unbounded(params, predped::params_from_csv[["params_bounds"]])

    ref <- predped::mll(data, params, transform = TRUE, cpp = FALSE, summed = TRUE)
    tst <- predped::mll(data, params, transform = TRUE, cpp = TRUE, summed = TRUE)

    testthat::expect_equal(ref, tst)



    ############################################################################
    # RAW

    # Read in some test data. Of these, select only the first 100, as these 
    # already contain all necessary ingredients (social simulation)
    data <- readRDS(file.path("data", "data_mll.Rds"))
    data <- data[1:100, ]

    # Retrieve the parameters of the SocialBaselineEuropean
    params <- predped::params_from_csv[["params_archetypes"]]
    params <- params[params$name == "SocialBaselineEuropean", ]

    # Create test and reference and compare both across all datapoints. Here, 
    # we don't transform the parameters
    ref <- predped::mll(data, params, transform = FALSE, cpp = FALSE, summed = FALSE)
    tst <- predped::mll(data, params, transform = FALSE, cpp = TRUE, summed = FALSE)

    testthat::expect_equal(ref, tst)

    # And now do one where you do transform the parameters
    params <- predped::to_unbounded(params, predped::params_from_csv[["params_bounds"]])

    ref <- predped::mll(data, params, transform = TRUE, cpp = FALSE, summed = FALSE)
    tst <- predped::mll(data, params, transform = TRUE, cpp = TRUE, summed = FALSE)

    testthat::expect_equal(ref, tst)
})