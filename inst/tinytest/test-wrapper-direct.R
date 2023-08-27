# Copyright (C) 2023 Avraham Adler. All Rights Reserved.
# SPDX-License-Identifier: LGPL-3.0-or-later
#
# File:   test-wrapper-direct
# Author: Avraham Adler
# Date:   6 February 2023
#
# Test wrapper calls to DIRECT algorithms
#
# Changelog:
#   2023-08-23: Change _output to _stdout
#

library(nloptr)

# DirectL is not identical when calling randomized = TRUE. May be an issue with
# the randomization at the C level. For now, need to pass this tolerance for it
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
  B  <- matrix(c(0.1312, 0.2329, 0.2348, 0.4047,
                 0.1696, 0.4135, 0.1451, 0.8828,
                 0.5569, 0.8307, 0.3522, 0.8732,
                 0.0124, 0.3736, 0.2883, 0.5743,
                 0.8283, 0.1004, 0.3047, 0.1091,
                 0.5886, 0.9991, 0.6650, 0.0381),
               nrow = 4L, ncol = 6L)
  fun <- 0
  for (i in 1:4) {
    fun <- fun - a[i] * exp(-sum(A[i, ] * (x - B[i, ]) ^ 2))
  }
  fun
}

lb <- rep(0, 6L)
ub <- rep(1, 6L)
x0 <- rep(0.5, 6L)
ctl <- list(xtol_rel = 1e-8, maxeval = 1000L)

# Test printout if nl.info passed. The word "Call:" should be in output if
# passed and not if not passed.
expect_stdout(direct(hartmann6, lb, ub, nl.info = TRUE), "Call:", fixed = TRUE)

expect_stdout(directL(hartmann6, lb, ub, nl.info = TRUE), "Call:", fixed = TRUE)

expect_silent(direct(hartmann6, lb, ub))

expect_silent(directL(hartmann6, lb, ub))

# Test DIRECT algorithm Scaled: TRUE Original: FALSE
directTest <- direct(hartmann6, lb, ub, control = ctl)

directControl <- nloptr(x0 = x0,
                        eval_f = hartmann6,
                        lb = lb,
                        ub = ub,
                        opts = list(algorithm = "NLOPT_GN_DIRECT",
                                    xtol_rel = 1e-8, maxeval = 1000L))

expect_identical(directTest$par, directControl$solution)
expect_identical(directTest$value, directControl$objective)
expect_identical(directTest$iter, directControl$iterations)
expect_identical(directTest$convergence, directControl$status)
expect_identical(directTest$message, directControl$message)

# Test DIRECT algorithm Scaled: FALSE Original: FALSE
directTest <- direct(hartmann6, lb, ub, scaled = FALSE, control = ctl)

directControl <- nloptr(x0 = x0,
                        eval_f = hartmann6,
                        lb = lb,
                        ub = ub,
                        opts = list(algorithm = "NLOPT_GN_DIRECT_NOSCAL",
                                    xtol_rel = 1e-8, maxeval = 1000L))

expect_identical(directTest$par, directControl$solution)
expect_identical(directTest$value, directControl$objective)
expect_identical(directTest$iter, directControl$iterations)
expect_identical(directTest$convergence, directControl$status)
expect_identical(directTest$message, directControl$message)

# Test DIRECT algorithm Original: TRUE
directTest <- direct(hartmann6, lb, ub, scaled = FALSE, original = TRUE,
                     control = ctl)

directControl <- nloptr(x0 = x0,
                        eval_f = hartmann6,
                        lb = lb,
                        ub = ub,
                        opts = list(algorithm = "NLOPT_GN_ORIG_DIRECT",
                                    xtol_rel = 1e-8, maxeval = 1000L))

expect_identical(directTest$par, directControl$solution)
expect_identical(directTest$value, directControl$objective)
expect_identical(directTest$iter, directControl$iterations)
expect_identical(directTest$convergence, directControl$status)
expect_identical(directTest$message, directControl$message)

# Test DIRECTL algorithm Randomized: FALSE Original: FALSE
directLTest <- directL(hartmann6, lb, ub, control = ctl)

directLControl <- nloptr(x0 = x0,
                         eval_f = hartmann6,
                         lb = lb,
                         ub = ub,
                         opts = list(algorithm = "NLOPT_GN_DIRECT_L",
                                     xtol_rel = 1e-8, maxeval = 1000L))

expect_identical(directLTest$par, directLControl$solution)
expect_identical(directLTest$value, directLControl$objective)
expect_identical(directLTest$iter, directLControl$iterations)
expect_identical(directLTest$convergence, directLControl$status)
expect_identical(directLTest$message, directLControl$message)

# Test DIRECTL algorithm Original: TRUE
ctl <- list(xtol_rel = 1e-8, maxeval = 10000L)
directLTest <- directL(hartmann6, lb, ub, randomized = TRUE, original = TRUE,
                       control = ctl)

directLControl <- nloptr(x0 = x0,
                         eval_f = hartmann6,
                         lb = lb,
                         ub = ub,
                         opts = list(algorithm = "NLOPT_GN_ORIG_DIRECT_L",
                                     xtol_rel = 1e-8, maxeval = 10000L))

expect_identical(directLTest$par, directLControl$solution)
expect_identical(directLTest$value, directLControl$objective)
expect_identical(directLTest$iter, directLControl$iterations)
expect_identical(directLTest$convergence, directLControl$status)
expect_identical(directLTest$message, directLControl$message)

# Test DIRECTL algorithm Randomized: TRUE Original: FALSE
ctl <- list(xtol_rel = 1e-8, maxeval = 50000L)

directLTest <- directL(hartmann6, lb, ub, randomized = TRUE, control = ctl)

directLControl <- nloptr(x0 = x0,
                         eval_f = hartmann6,
                         lb = lb,
                         ub = ub,
                         opts = list(algorithm = "NLOPT_GN_DIRECT_L_RAND",
                                     xtol_rel = 1e-8, maxeval = 50000L))

# May have something to do with the randomization. Setting seeds before the
# calls does not help with check_identical
# (AA: 2023-02-06)
expect_equal(directLTest$par, directLControl$solution, tolerance = tol)
expect_equal(directLTest$value, directLControl$objective, tolerance = tol)
expect_identical(directLTest$iter, directLControl$iterations)
expect_identical(directLTest$convergence, directLControl$status)
expect_identical(directLTest$message, directLControl$message)

