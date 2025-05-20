testthat::test_that(
    "Discretize: Test output",
    {
        x <- seq(-1, 1, 0.2)

        # Differing stepsizes and minima
        dx <- c(0.5, 1)
        min_x <- c(min(x), -2)

        # Create the different references for the different settings
        ref_11 <- c(0, 0, 0, 1, 1, 2, 2, 2, 3, 3, 4)
        ref_12 <- ref_11 + 2
        ref_21 <- c(0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 2)
        ref_22 <- ref_21 + 1

        # Create the tests
        tst_11 <- beprepared::discretize(x, dx = dx[1], min_x = min_x[1])
        tst_12 <- beprepared::discretize(x, dx = dx[1], min_x = min_x[2])
        tst_21 <- beprepared::discretize(x, dx = dx[2], min_x = min_x[1])
        tst_22 <- beprepared::discretize(x, dx = dx[2], min_x = min_x[2])

        # Compare them
        testthat::expect_equal(tst_11, ref_11)
        testthat::expect_equal(tst_12, ref_12)
        testthat::expect_equal(tst_21, ref_21)
        testthat::expect_equal(tst_22, ref_22)
    }
)

testthat::test_that(
    "Segmentize: Test output",
    {
        # Create the three object types
        objects <- list(
            rectangle(center = c(0, 0), size = c(2, 2)),
            polygon(points = cbind(c(1, 1, -1, -1), c(1, -1, -1, 1))),
            circle(center = c(0, 0), radius = 1)
        )

        # Without discretization
        tst <- lapply(
            objects,
            \(x) beprepared::segmentize(x, discretize = FALSE)
        )

        rect <- data.frame(
            x1 = c(-1, -1, 1, 1),
            y1 = c(-1, 1, 1, -1),
            x2 = c(-1, 1, 1, -1),
            y2 = c(1, 1, -1, -1)
        )
        poly <- data.frame(
            x1 = c(1, 1, -1, -1),
            y1 = c(1, -1, -1, 1),
            x2 = c(1, -1, -1, 1),
            y2 = c(-1, -1, 1, 1)
        )
        circ <- data.frame(
            x1 = cos(seq(0, 2 * pi, length.out = 101)[1:100]),
            y1 = sin(seq(0, 2 * pi, length.out = 101)[1:100]),
            x2 = cos(seq(0, 2 * pi, length.out = 101)[c(2:100, 1)]),
            y2 = sin(seq(0, 2 * pi, length.out = 101)[c(2:100, 1)])
        )

        ref <- list(rect, poly, circ)

        testthat::expect_equal(tst, ref)

        # With discretization
        tst <- lapply(
            objects,
            \(x) beprepared::segmentize(
                x, 
                discretize = TRUE,
                dx = 1,
                origin = c(-1, -1))
        )

        rect <- data.frame(
            x1 = c(0, 0, 2, 2),
            y1 = c(0, 2, 2, 0),
            x2 = c(0, 2, 2, 0),
            y2 = c(2, 2, 0, 0)
        )
        poly <- data.frame(
            x1 = c(2, 2, 0, 0),
            y1 = c(2, 0, 0, 2),
            x2 = c(2, 0, 0, 2),
            y2 = c(0, 0, 2, 2)
        )
        circ <- data.frame(
            x1 = c(2, rep(1, 24), rep(0, 51), rep(1, 24)),
            y1 = c(rep(1, 25), 2, rep(1, 24), rep(0, 50)),
            x2 = c(rep(1, 24), rep(0, 51), rep(1, 24), 2),
            y2 = c(rep(1, 24), 2, rep(1, 24), rep(0, 50), 1)
        )

        ref <- list(rect, poly, circ)

        testthat::expect_equal(tst, ref)
    }
)
