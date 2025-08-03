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

library(nloptr)

ctlNM <- list(algorithm = "NLOPT_LN_NELDERMEAD", xtol_rel = 1e-8)
ctlLB <- list(algorithm = "NLOPT_LD_LBFGS", xtol_rel = 1e-8)

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

# Check that we don't have NA's if we evaluate the objective function in x0.
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

# Malformed objects solely intended to trigger tests:
## eval_f test
expect_error(is.nloptr(list(eval_f = "Hello")), "eval_f is not a function")

## eval_g_ineq test
expect_error(is.nloptr(list(eval_f = fphv, eval_g_ineq = "GoodBye")),
             "eval_g_ineq is not a function")

## eval_g_eq test
expect_error(is.nloptr(list(eval_f = fphv, eval_g_eq = 27)),
             "eval_g_eq is not a function")

## MULTIVARIATE FUNCTION WITH CONSTRAINTS
x0 <- c(2, 2)
ub <- c(5, 5)
lb <- c(-1, -1)
fn <- function(x) (x[1L] - 1) ^ 2 + (x[2L] - 1) ^ 2 + 1
gr <- function(x) c(2 * (x[1L] - 1), 2 * (x[2L] - 1))
fnl <- function(x) list("objective" = fn(x), "gradient" = gr(x))
fnlNA <- function(x) list("objective" = NA_real_, "gradient" = gr(x))
hin <- function(x) c(1.44 - x[1L] ^ 2, 2.197 - x[2L] ^ 3)
hinjac <- function(x) matrix(c(-2 * x[1L], 0, 0, -3 * x[2L] ^ 2), 2L, 2L)
hinl <- function(x) list("constraints" = hin(x), "jacobian" = hinjac(x))
hinlNA <- function(x) {
  list("constraints" = hin(NA_real_), "jacobian" = hinjac(x))
}
heq <- function(x) c(x[1L] * x[2L] - 2.55, x[1L] - x[2L] - 0.2)
heqjac <- function(x) matrix(c(x[2L], 1, x[1L], -1), 2L)
heql <- function(x) list("constraints" = heq(x), "jacobian" = heqjac(x))
heqlNA <- function(x) {
  list("constraints" = heq(NA_real_), "jacobian" = heqjac(x))
}

optSol <- c(1.7, 1.5)
optVal <- 1.74

# Test simple error messages first; roughly in their order in is.nloptr.R Many
# of these are testing the list versions of their functional parents. A list
# version is when a function and its gradient are returned in the same call.
expect_error(nloptr(x0, fnlNA,
                    opts = list(algorithm = "NLOPT_LN_COBYLA",
                                xtol_rel = 1e-8)),
             "objective in x0 returns NA", fixed = TRUE)

hinE <- function(x) c(4, NA_real_)
expect_error(nloptr(x0, fn, eval_g_ineq = hinE,
                    opts = list(algorithm = "NLOPT_LN_COBYLA",
                                xtol_rel = 1e-8)),
             "inequality constraints in x0 returns NA", fixed = TRUE)

expect_error(nloptr(x0, fnl, eval_g_ineq = hinlNA,
                    opts = list(algorithm = "NLOPT_LD_SLSQP", xtol_rel = 1e-8)),
             "inequality constraints in x0 returns NA", fixed = TRUE)

hinjacE <- function(x) c(-2 * x[1L], NA_real_)
expect_error(nloptr(x0, fn, gr, eval_g_ineq = hin, eval_jac_g_ineq = hinjacE,
                    opts = list(algorithm = "NLOPT_LD_SLSQP", xtol_rel = 1e-8)),
             "jacobian of inequality constraints in x0 returns NA",
             fixed = TRUE)

hinjacE <- function(x) c(-2 * x[1L], -3 * x[2L] ^ 2)
expect_error(nloptr(x0, fn, gr, eval_g_ineq = hin, eval_jac_g_ineq = hinjacE,
                    opts = list(algorithm = "NLOPT_LD_SLSQP", xtol_rel = 1e-8)),
             "wrong number of elements in jacobian of inequality", fixed = TRUE)

expect_warning(nloptr(x0, fn, eval_g_ineq = hin, eval_jac_g_ineq = hinjac,
                      opts = list(algorithm = "NLOPT_LN_COBYLA",
                                  xtol_rel = 1e-8)),
               "gradient was supplied for the inequality constraints",
               fixed = TRUE)

expect_error(nloptr(x0, fn, gr, eval_g_ineq = hin,
                    opts = list(algorithm = "NLOPT_LD_SLSQP", xtol_rel = 1e-8)),
             "gradient for the inequality constraints is needed", fixed = TRUE)

heqE <- function(x) c(x[1L] * x[2L] - 2.55, NA_real_)
expect_error(nloptr(x0, fn, eval_g_eq = heqE,
                    opts = list(algorithm = "NLOPT_LN_COBYLA",
                                xtol_rel = 1e-8)),
             "equality constraints in x0 returns NA", fixed = TRUE)

expect_error(nloptr(x0, fn, eval_g_eq = heqlNA,
                    opts = list(algorithm = "NLOPT_LN_COBYLA",
                                xtol_rel = 1e-8)),
             "equality constraints in x0 returns NA", fixed = TRUE)

heqjacE <- function(x) c(-2 * x[1L], NA_real_)
expect_error(nloptr(x0, fn, gr, eval_g_eq = heq, eval_jac_g_eq = heqjacE,
                    opts = list(algorithm = "NLOPT_LD_SLSQP", xtol_rel = 1e-8)),
             "jacobian of equality constraints in x0 returns NA",
             fixed = TRUE)

heqjacE <- function(x) c(-2 * x[1L], -3 * x[2L] ^ 2)
expect_error(nloptr(x0, fn, gr, eval_g_eq = heq, eval_jac_g_eq = heqjacE,
                    opts = list(algorithm = "NLOPT_LD_SLSQP", xtol_rel = 1e-8)),
             "wrong number of elements in jacobian of equality", fixed = TRUE)

expect_warning(nloptr(x0, fn, eval_g_eq = heq, eval_jac_g_eq = heqjac,
                      opts = list(algorithm = "NLOPT_GN_ISRES",
                                  xtol_rel = 1e-8)),
               "gradient was supplied for the equality constraints",
               fixed = TRUE)

expect_error(nloptr(x0, fn, gr, eval_g_eq = heq,
                    opts = list(algorithm = "NLOPT_LD_SLSQP", xtol_rel = 1e-8)),
             "gradient for the equality constraints is needed", fixed = TRUE)


expect_error(nloptr(x0, fn, gr, eval_g_eq = heq, eval_jac_g_eq = heqjac,
                    opts = list(algorithm = "NLOPT_LD_LBFGS", xtol_rel = 1e-8)),
             "If you want to use equality constraints, then you should use one",
             fixed = TRUE)

expect_error(nloptr(x0, fn, gr, eval_g_eq = heq, eval_jac_g_eq = heqjac,
                    opts = list(algorithm = "NLOPT_LD_AUGLAG",
                                xtol_rel = 1e-8)),
             "needs a local optimizer; specify an algorithm and termination",
             fixed = TRUE)

expect_error(nloptr(x0, fn, gr, eval_g_ineq = hin, eval_jac_g_ineq = hinjac,
                    opts = list(algorithm = "NLOPT_LD_SLSQP", xtol_rel = 1e-8,
                                tol_constraints_ineq = rep(0.1, 3L))),
             "The vector tol_constraints_ineq in the options list",
             fixed = TRUE)

expect_error(nloptr(x0, fn, gr, eval_g_eq = heq, eval_jac_g_eq = heqjac,
                    opts = list(algorithm = "NLOPT_LD_SLSQP", xtol_rel = 1e-8,
                                tol_constraints_eq = rep(0.1, 3L))),
             "The vector tol_constraints_eq in the options list", fixed = TRUE)
