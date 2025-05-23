testthat::test_that(
    "Defaults: Test basic output",
    {
        def <- data.frame(
            x = 1,
            y = 2
        )

        # No input 
        tst <- beprepared::defaults(NULL, def)
        testthat::expect_equal(tst, def)

        # No rows
        tst <- beprepared::defaults(data.frame(), def)
        testthat::expect_equal(tst, def)

        # Single row: Contained in def
        tst <- beprepared::defaults(data.frame(x = 0), def)
        testthat::expect_equal(
            tst, 
            data.frame(x = 0, y = 2)
        )

        # Single row: Not contained in def
        tst <- beprepared::defaults(data.frame(z = 0), def)
        testthat::expect_equal(tst, def)

        # Multiple rows: Contained in def
        tst <- beprepared::defaults(data.frame(x = rep(0, 3)), def)
        testthat::expect_equal(
            tst, 
            data.frame(
                x = rep(0, 3), 
                y = rep(2, 3)
            )
        )

        # Multiple rows: Not contained in def
        tst <- beprepared::defaults(data.frame(z = c(0, 0, 0)), def)
        testthat::expect_equal(
            tst, 
            data.frame(
                x = rep(1, 3), 
                y = rep(2, 3)
            )
        )
    }
)

testthat::test_that(
    "Defaults: Test probability",
    {
        def <- data.frame(
            prob = 1,
            x = 1,
            y = 2
        )

        # Single row: Prob not changed
        tst <- beprepared::defaults(data.frame(x = 0), def)
        testthat::expect_equal(tst, data.frame(prob = 1, x = 0, y = 2))

        # Single row: Prob changed
        tst <- beprepared::defaults(data.frame(prob = 0.5), def)
        testthat::expect_equal(tst, def)

        # Multiple row: Prob not changed
        tst <- beprepared::defaults(data.frame(x = rep(0, 2)), def)
        testthat::expect_equal(tst, data.frame(prob = rep(0.5, 2), x = rep(0, 2), y = rep(2, 2)))

        # Multiple row: Prob changed
        tst <- beprepared::defaults(data.frame(prob = rep(0.25, 2)), def)
        testthat::expect_equal(tst, data.frame(prob = rep(0.5, 2), x = rep(1, 2), y = rep(2, 2)))
    }
)
