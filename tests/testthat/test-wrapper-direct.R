# Copyright (C) 2023 Avraham Adler. All Rights Reserved.
# This code is published under the L-GPL.
#
# File:   test-wrapper-direct
# Author: Avraham Adler
# Date:   6 February 2023
#
# Test wrapper calls to DIRECT algorithms
#
# Changelog:
#

# DirectL is not identical when calling randomized = TRUE. May be an issue with
# the randomization at the C level. For now, need to pass this tolarance for it
# to work.
# (AA: 2026-02-06)
tol <- 1e-6

## Functions for DIRECT and DIRECT_L
hartmann6 <- function(x) {
  a <- c(1, 1.2, 3, 3.2)
  A <- matrix(c(10,  0.05, 3, 17,
                3, 10,  3.5,  8,
                17, 17,  1.7,  0.05,
                3.5,  0.1, 10, 10,
                1.7,  8, 17,  0.1,
                8, 14,  8, 14),
              nrow = 4L, ncol = 6L)
  B  <- matrix(c(.1312, .2329, .2348, .4047,
                 .1696, .4135, .1451, .8828,
                 .5569, .8307, .3522, .8732,
                 .0124, .3736, .2883, .5743,
                 .8283, .1004, .3047, .1091,
                 .5886, .9991, .6650, .0381),
               nrow = 4L, ncol = 6L)
  fun <- 0
  for (i in 1:4) {
    fun <- fun - a[i] * exp(-sum(A[i, ] * (x - B[i, ]) ^ 2))
  }
  fun
}

# Test printout if nl.info passed. The word "Call:" should be in output if
# passed and not if not passed.
expect_output(suppressMessages(direct(hartmann6, rep(0, 6L), rep(1, 6L),
                                       nl.info = TRUE,
                                       control = list(xtol_rel = 1e-8,
                                                      maxeval = 1000L))),
              "Call:", fixed = TRUE)

expect_output(suppressMessages(directL(hartmann6, rep(0, 6L), rep(1, 6L),
                                       nl.info = TRUE,
                                       control = list(xtol_rel = 1e-8,
                                                    maxeval = 1000L))),
              "Call:", fixed = TRUE)

expect_silent(suppressMessages(direct(hartmann6, rep(0, 6L), rep(1, 6L),
                                      nl.info = FALSE,
                                      control = list(xtol_rel = 1e-8,
                                                     maxeval = 1000L))))

expect_silent(suppressMessages(directL(hartmann6, rep(0, 6L), rep(1, 6L),
                                       nl.info = FALSE,
                                       control = list(xtol_rel = 1e-8,
                                                      maxeval = 1000L))))

# Test DIRECT algorithm Scaled: TRUE Original: FALSE
directTest <- suppressMessages(direct(hartmann6, rep(0, 6L), rep(1, 6L),
                                    nl.info = FALSE,
                                    control = list(xtol_rel = 1e-8,
                                                   maxeval = 1000L)))

directControl <- nloptr(x0 = (rep(0, 6L) + rep(1, 6L)) / 2,
                        eval_f = hartmann6,
                        lb = rep(0, 6L),
                        ub = rep(1, 6L),
                        opts = list(algorithm = "NLOPT_GN_DIRECT",
                                    xtol_rel = 1e-8, maxeval = 1000L))

expect_identical(directTest$par, directControl$solution)
expect_identical(directTest$value, directControl$objective)
expect_identical(directTest$iter, directControl$iterations)
expect_identical(directTest$convergence, directControl$status)
expect_identical(directTest$message, directControl$message)

# Test DIRECT algorithm Scaled: FALSE Original: FALSE
directTest <- suppressMessages(direct(hartmann6, rep(0, 6L), rep(1, 6L),
                                      nl.info = FALSE, scaled = FALSE,
                                      control = list(xtol_rel = 1e-8,
                                                     maxeval = 1000L)))

directControl <- nloptr(x0 = (rep(0, 6L) + rep(1, 6L)) / 2,
                        eval_f = hartmann6,
                        lb = rep(0, 6L),
                        ub = rep(1, 6L),
                        opts = list(algorithm = "NLOPT_GN_DIRECT_NOSCAL",
                                    xtol_rel = 1e-8, maxeval = 1000L))

expect_identical(directTest$par, directControl$solution)
expect_identical(directTest$value, directControl$objective)
expect_identical(directTest$iter, directControl$iterations)
expect_identical(directTest$convergence, directControl$status)
expect_identical(directTest$message, directControl$message)

# Test DIRECT algorithm Original: TRUE
directTest <- suppressMessages(direct(hartmann6, rep(0, 6L), rep(1, 6L),
                                      nl.info = FALSE, scaled = FALSE,
                                      original = TRUE,
                                      control = list(xtol_rel = 1e-8,
                                                     maxeval = 1000L)))

directControl <- nloptr(x0 = (rep(0, 6L) + rep(1, 6L)) / 2,
                        eval_f = hartmann6,
                        lb = rep(0, 6L),
                        ub = rep(1, 6L),
                        opts = list(algorithm = "NLOPT_GN_ORIG_DIRECT",
                                    xtol_rel = 1e-8, maxeval = 1000L))

expect_identical(directTest$par, directControl$solution)
expect_identical(directTest$value, directControl$objective)
expect_identical(directTest$iter, directControl$iterations)
expect_identical(directTest$convergence, directControl$status)
expect_identical(directTest$message, directControl$message)

# Test DIRECTL algorithm Randomized: FALSE Original: FALSE
directLTest <- suppressMessages(directL(hartmann6, rep(0, 6L), rep(1, 6L),
                                        nl.info = FALSE,
                                        control = list(xtol_rel = 1e-8,
                                                       maxeval = 1000L)))

directLControl <- nloptr(x0 = (rep(0, 6L) + rep(1, 6L)) / 2,
                        eval_f = hartmann6,
                        lb = rep(0, 6L),
                        ub = rep(1, 6L),
                        opts = list(algorithm = "NLOPT_GN_DIRECT_L",
                                    xtol_rel = 1e-8, maxeval = 1000L))

expect_identical(directLTest$par, directLControl$solution)
expect_identical(directLTest$value, directLControl$objective)
expect_identical(directLTest$iter, directLControl$iterations)
expect_identical(directLTest$convergence, directLControl$status)
expect_identical(directLTest$message, directLControl$message)

# Test DIRECTL algorithm Randomized: TRUE Original: FALSE
set.seed(198L)
directLTest <- suppressMessages(directL(hartmann6, rep(0, 6L), rep(1, 6L),
                                        nl.info = FALSE, randomized = TRUE,
                                        control = list(xtol_rel = 1e-8,
                                                       maxeval = 1000L)))

set.seed(198L)
directLControl <- nloptr(x0 = (rep(0, 6L) + rep(1, 6L)) / 2,
                         eval_f = hartmann6,
                         lb = rep(0, 6L),
                         ub = rep(1, 6L),
                         opts = list(algorithm = "NLOPT_GN_DIRECT_L_RAND",
                                     xtol_rel = 1e-8, maxeval = 1000L))

# May have something to do with the randomization. Setting seeds before the
# calls does not help with check_identical
# (AA: 2023-02-06)
expect_equal(directLTest$par, directLControl$solution, tolerance = tol)
expect_equal(directLTest$value, directLControl$objective, tolerance = tol)
expect_identical(directLTest$iter, directLControl$iterations)
expect_identical(directLTest$convergence, directLControl$status)
expect_identical(directLTest$message, directLControl$message)

# Test DIRECTL algorithm Original: TRUE
directLTest <- suppressMessages(directL(hartmann6, rep(0, 6L), rep(1, 6L),
                                        nl.info = FALSE, randomized = TRUE,
                                        original = TRUE,
                                        control = list(xtol_rel = 1e-8,
                                                       maxeval = 1000L)))

directLControl <- nloptr(x0 = (rep(0, 6L) + rep(1, 6L)) / 2,
                         eval_f = hartmann6,
                         lb = rep(0, 6L),
                         ub = rep(1, 6L),
                         opts = list(algorithm = "NLOPT_GN_ORIG_DIRECT_L",
                                     xtol_rel = 1e-8, maxeval = 1000L))

expect_identical(directLTest$par, directLControl$solution)
expect_identical(directLTest$value, directLControl$objective)
expect_identical(directLTest$iter, directLControl$iterations)
expect_identical(directLTest$convergence, directLControl$status)
expect_identical(directLTest$message, directLControl$message)
