# Copyright (C) 2023 Avraham Adler. All Rights Reserved.
# SPDX-License-Identifier: LGPL-3.0-or-later
#
# File:   test-is.nloptr
# Author: Avraham Adler
# Date:   6 February 2023
#
# Test code in "is.nloptr" function that is not tested elsewhere.
#
# Changelog:
#

ctlNM <- list(algorithm = "NLOPT_LN_NELDERMEAD", xtol_rel = 1e-8)
ctlLB <- list(algorithm = 'NLOPT_LD_LBFGS', xtol_rel = 1e-8)

# Check whether the object exists and is a list
expect_false(is.nloptr(NULL))
expect_false(is.nloptr(3))

# Check whether the needed wrapper functions are supplied
# This seems to ALWAYS be preempted by .checkfunargs in nloptr itself (AA)

fphv <- function(x) {
  100 * (x[3L] - 10 * atan2(x[2L], x[1L]) / (2 * pi)) ^ 2 +
    (sqrt(x[1L] ^ 2 + x[2L] ^ 2) - 1) ^ 2 + x[3L] ^ 2
}

# Check whether bounds are defined for all controls
expect_error(nloptr(x0 = c(-1.2, 1.5, NA), eval_f = fphv, opts = ctlNM),
             "x0 contains NA", fixed = TRUE)

expect_error(nloptr(x0 = c(-1.2, 1.5, 3), eval_f = fphv, lb = c(-2, -2),
                    opts = ctlNM),
             "length(lb) != length(x0)", fixed = TRUE)

expect_error(nloptr(x0 = c(-1.2, 1.5, 3), eval_f = fphv, ub = c(-2, -2),
                    opts = ctlNM),
             "length(ub) != length(x0)", fixed = TRUE)

# Check whether the initial value is within the bounds
expect_error(nloptr(x0 = c(-1.2, 1.5, 3), eval_f = fphv, lb = c(-1, -1, -1),
                    opts = ctlNM),
             "at least one element in x0 < lb", fixed = TRUE)

expect_error(nloptr(x0 = c(-1.2, 1.5, 3), eval_f = fphv, ub = c(2, 2, 2),
                    opts = ctlNM),
             "at least one element in x0 > ub", fixed = TRUE)

# check if an existing algorithm was supplied
expect_error(nloptr(x0 = c(-1.2, 1.5, 3), eval_f = fphv,
                    opts = list(algorithm = "NLOPT_LN_NEDERMEAD",
                                xtol_rel = 1e-8)),
             "Incorrect algorithm supplied. Use one of the", fixed = TRUE)

# Check the whether we don't have NA's if we evaluate the objective function in x0
f0 <- function(x) 3 * x ^ 1.5 - 2 * x ^ 0.5

expect_error(suppressWarnings(nloptr(x0 = -1, eval_f = f0, opts = ctlNM)),
             "objective in x0 returns NA", fixed = TRUE)

f0 <- function(x) 3 * x ^ 4 - 12 * x ^ 3
g0 <- function(x) 4 * sqrt(x) # Yes it's not the gradient. This is a unit test!!
expect_error(suppressWarnings(nloptr(x0 = -1, f0, g0, opts = ctlLB)),
             "objective in x0 returns NA", fixed = TRUE)

g0 <- function(x) c(4, 2) # Yes it's not the gradient. This is a unit test!!
expect_error(suppressWarnings(nloptr(x0 = -1, f0, g0, opts = ctlLB)),
             "wrong number of elements in gradient of objective",
             fixed = TRUE)

# check whether algorithm needs a derivative
g0 <- function(x) 12 * x ^ 3 - 36 * x ^ 2 # Actual gradient
## Just checking...
expect_silent(nloptr(x0 = -1, f0, g0, opts = ctlLB))
expect_warning(nloptr(x0 = -1, f0, g0, opts = ctlNM),
             "a gradient was supplied for the objective function",
             fixed = TRUE)
expect_error(nloptr(x0 = -1, f0, opts = ctlLB),
             "A gradient for the objective function is needed", fixed = TRUE)

# Check the whether we don't have NA's if we evaluate the inequality constraints in x0
hin <- function(x) NA_real_
expect_error(nloptr(x0 = -1, f0, g0, eval_g_ineq = hin, opts = ctlLB),
             "inequality constraints in x0 returns NA", fixed = TRUE)

hin <- function(x) x
hinjac <- function(x) NA_real_
expect_error(nloptr(x0 = -1, f0, g0, eval_g_ineq = hin,
                    eval_jac_g_ineq = hinjac, opts = ctlLB),
             "jacobian of inequality constraints in x0 returns NA",
             fixed = TRUE)

hinjac <- function(x) c(2, 3)
expect_error(nloptr(x0 = -1, f0, g0, eval_g_ineq = hin,
                    eval_jac_g_ineq = hinjac, opts = ctlLB),
             "wrong number of elements in jacobian of inequality constraints",
             fixed = TRUE)
