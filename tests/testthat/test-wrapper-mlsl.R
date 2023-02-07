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
#

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

hart.gr <- function(x) nl.grad(x, hartmann6)

x0 <- lb <- rep(0, 6L)
ub <- rep(1, 6L)
ctl <- list(xtol_rel = 1e-8, maxeval = 1000L)

# Test printout if nl.info passed. The word "Call:" should be in output if
# passed and not if not passed.
expect_output(mlsl(x0 = x0, hartmann6, lower = lb, upper = ub, nl.info = TRUE),
              "Call:", fixed = TRUE)

expect_silent(mlsl(x0 = x0, hartmann6, lower = lb, upper = ub))

# Test Warning
# Have to wrap warning test in expect_error because Cannot test for warning
# because "gr" gets overridden to NULL and then the global algorithm spits back
# an error. Need to discuss with Aymeric or Hans if that is intended behavior.
# (AA: 2023-02-06)

expect_error(expect_warning(mlsl(x0, hartmann6, hart.gr, lb, ub,
                                 local.method = "MMA"),
                            "Only gradient-based LBFGS available as local met",
                            fixed = TRUE))

# No passed gradient: Low discrepancy
mlslTest <- mlsl(x0, hartmann6, lower = lb, upper = ub, control = ctl)

mlslControl <- nloptr(x0 = x0,
                      eval_f = hartmann6,
                      eval_grad_f = hart.gr,
                      lb = lb,
                      ub = ub,
                      opts = list(algorithm = "NLOPT_GD_MLSL_LDS",
                                  xtol_rel = 1e-8, maxeval = 1000L,
                                  local_opts = list(
                                    algorithm = "NLOPT_LD_LBFGS",
                                    xtol_rel  = 1e-4)))

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
                                  xtol_rel = 1e-8, maxeval = 1000L,
                                  local_opts = list(
                                    algorithm = "NLOPT_LD_LBFGS",
                                    xtol_rel  = 1e-4)))

expect_equal(mlslTest$par, mlslControl$solution, tolerance = tol)
expect_equal(mlslTest$value, mlslControl$objective, tolerance = tol)
expect_identical(mlslTest$iter, mlslControl$iterations)
expect_identical(mlslTest$convergence, mlslControl$status)
expect_identical(mlslTest$message, mlslControl$message)
