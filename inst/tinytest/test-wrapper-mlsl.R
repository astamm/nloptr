# Copyright (C) 2023 Avraham Adler. All Rights Reserved.
# SPDX-License-Identifier: LGPL-3.0-or-later
#
# File:   test-wrapper-mlsl
# Author: Avraham Adler
# Date:   6 February 2023
#
# Test wrapper calls MLSL algorithm.
#
# Changelog:
#   2023-08-23: Change _stdout to _stdout and _lte to _true
#

library(nloptr)

tol <- 8e-8

## Functions for the algorithms
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

hart.gr <- function(x) nl.grad(x, hartmann6)

x0 <- lb <- rep(0, 6L)
ub <- rep(1, 6L)
ctl <- list(xtol_rel = 1e-8, maxeval = 750L)
lopt <- list(algorithm = "NLOPT_LD_LBFGS", xtol_rel = 1e-4)

# Test printout if nl.info passed. The word "Call:" should be in output if
# passed and not if not passed.
expect_stdout(mlsl(x0 = x0, hartmann6, lower = lb, upper = ub, nl.info = TRUE),
              "Call:", fixed = TRUE)

expect_silent(mlsl(x0 = x0, hartmann6, lower = lb, upper = ub))

# Test Warning
expect_warning(mlsl(x0, hartmann6, hart.gr, lb, ub, local.method = "MMA"),
               "Only gradient-based LBFGS available as local met", fixed = TRUE)

# No passed gradient: Low discrepancy
mlslTest <- mlsl(x0, hartmann6, lower = lb, upper = ub, control = ctl)

mlslControl <- nloptr(x0 = x0,
                      eval_f = hartmann6,
                      eval_grad_f = hart.gr,
                      lb = lb,
                      ub = ub,
                      opts = list(algorithm = "NLOPT_GD_MLSL_LDS",
                                  xtol_rel = 1e-8, maxeval = 750L,
                                  local_opts = lopt))

expect_identical(mlslTest$par, mlslControl$solution)
expect_identical(mlslTest$value, mlslControl$objective)
expect_identical(mlslTest$iter, mlslControl$iterations)
expect_identical(mlslTest$convergence, mlslControl$status)
expect_identical(mlslTest$message, mlslControl$message)

# Passed gradient: No low discrepancy
mlslTest <- mlsl(x0, hartmann6, hart.gr, lb, ub, low.discrepancy = FALSE,
                 control = ctl)

mlslControl <- nloptr(x0 = x0,
                      eval_f = hartmann6,
                      eval_grad_f = hart.gr,
                      lb = lb,
                      ub = ub,
                      opts = list(algorithm = "NLOPT_GD_MLSL",
                                  xtol_rel = 1e-8, maxeval = 750L,
                                  local_opts = lopt))

expect_equal(mlslTest$par, mlslControl$solution, tolerance = tol)
expect_equal(mlslTest$value, mlslControl$objective, tolerance = tol)
# See https://nlopt.readthedocs.io/en/latest/NLopt_Reference/#stopping-criteria
# "This is not a strict maximum: the number of function evaluations may exceed
# maxeval slightly, depending upon the algorithm."
expect_true(abs(mlslTest$iter - mlslControl$iterations) <= 10L)
expect_identical(mlslTest$convergence, mlslControl$status)
expect_identical(mlslTest$message, mlslControl$message)
