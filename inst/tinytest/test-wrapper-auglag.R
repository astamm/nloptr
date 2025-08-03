# Copyright (C) 2023 Avraham Adler. All Rights Reserved.
# SPDX-License-Identifier: LGPL-3.0-or-later
#
# File:   test-wrapper-auglag
# Author: Avraham Adler
# Date:   6 February 2023
#
# Test wrapper calls to auglag algorithm
#
# Changelog:
#   2023-08-23: Change _output to _stdout
#

library(nloptr)

depMess <- paste("The old behavior for hin >= 0 has been deprecated. Please",
                 "restate the inequality to be <=0. The ability to use the old",
                 "behavior will be removed in a future release.")

# Taken from example
x0 <- c(1, 1)
fn <- function(x) (x[1L] - 2) ^ 2 + (x[2L] - 1) ^ 2
hin <- function(x) 0.25 * x[1L] ^ 2 + x[2L] ^ 2 - 1     # hin <= 0
heq <- function(x) x[1L] - 2 * x[2L] + 1                # heq = 0
gr <- function(x) nl.grad(x, fn)
hinjac <- function(x) nl.jacobian(x, hin)
heqjac <- function(x) nl.jacobian(x, heq)
hin2 <- function(x) -hin(x)                       # Needed to test old behavior
hinjac2 <- function(x) nl.jacobian(x, hin2)       # Needed to test old behavior

# Test silence on proper behavior
expect_silent(auglag(x0, fn))
expect_silent(auglag(x0, fn, hin = hin, deprecatedBehavior = FALSE))

# Test errors
expect_error(auglag(x0, fn, ineq2local = TRUE),
             "Inequalities to local solver: feature not yet implemented.")
expect_error(auglag(x0, fn, localsolver = "NLOPT_LN_NELDERMEAD"),
             "Only local solvers allowed: BOBYQA, COBYLA, LBFGS, MMA, SLSQP.")

# Test printout if nl.info passed. The word "Call:" should be in output if
# passed and not if not passed.
expect_stdout(auglag(x0, fn, nl.info = TRUE), "Call:", fixed = TRUE)

# Test COBYLA version
augTest <- auglag(x0, fn, hin = hin, heq = heq, deprecatedBehavior = FALSE)

augControl <- nloptr(x0 = x0,
                     eval_f = fn,
                     eval_g_ineq = hin,
                     eval_g_eq = heq,
                     opts = list(algorithm = "NLOPT_LN_AUGLAG",
                                 xtol_rel = 1e-6,
                                 maxeval = 1000L,
                                 local_opts = list(
                                   algorithm = "NLOPT_LN_COBYLA",
                                   xtol_rel = 1e-6
                                 )))

expect_identical(augTest$par, augControl$solution)
expect_identical(augTest$value, augControl$objective)
expect_identical(augTest$global_solver, augControl$options$algorithm)
expect_identical(augTest$local_solver, augControl$local_options$algorithm)
expect_identical(augTest$convergence, augControl$status)
expect_identical(augTest$message, augControl$message)

# Test BOBYQA version
augTest <- auglag(x0, fn, hin = hin, heq = heq, localsolver = "BOBYQA",
                  deprecatedBehavior = FALSE)

augControl <- nloptr(x0 = x0,
                     eval_f = fn,
                     eval_g_ineq = hin,
                     eval_g_eq = heq,
                     opts = list(algorithm = "NLOPT_LN_AUGLAG",
                                 xtol_rel = 1e-6,
                                 maxeval = 1000L,
                                 local_opts = list(
                                   algorithm = "NLOPT_LN_BOBYQA",
                                   xtol_rel = 1e-6
                                 )))

expect_identical(augTest$par, augControl$solution)
expect_identical(augTest$value, augControl$objective)
expect_identical(augTest$global_solver, augControl$options$algorithm)
expect_identical(augTest$local_solver, augControl$local_options$algorithm)
expect_identical(augTest$convergence, augControl$status)
expect_identical(augTest$message, augControl$message)

# Test SLSQP version
# No passed hin/heq Jacobian
augTest <- auglag(x0, fn, hin = hin, heq = heq, localsolver = "SLSQP",
                  deprecatedBehavior = FALSE)

augControl <- nloptr(x0 = x0,
                     eval_f = fn,
                     eval_grad_f = gr,
                     eval_g_ineq = hin,
                     eval_jac_g_ineq = hinjac,
                     eval_g_eq = heq,
                     eval_jac_g_eq = heqjac,
                     opts = list(algorithm = "NLOPT_LD_AUGLAG",
                                 xtol_rel = 1e-6,
                                 maxeval = 1000L,
                                 local_opts = list(algorithm = "NLOPT_LD_SLSQP",
                                                   eval_grad_f = gr,
                                                   xtol_rel = 1e-6)))

expect_identical(augTest$par, augControl$solution)
expect_identical(augTest$value, augControl$objective)
expect_identical(augTest$global_solver, augControl$options$algorithm)
expect_identical(augTest$local_solver, augControl$local_options$algorithm)
expect_identical(augTest$convergence, augControl$status)
expect_identical(augTest$message, augControl$message)

# Passed hin/heq Jacobian
augTest <- auglag(x0, fn, hin = hin, heq = heq, hinjac = hinjac,
                  heqjac = heqjac, localsolver = "SLSQP",
                  deprecatedBehavior = FALSE)

expect_identical(augTest$par, augControl$solution)
expect_identical(augTest$value, augControl$objective)
expect_identical(augTest$global_solver, augControl$options$algorithm)
expect_identical(augTest$local_solver, augControl$local_options$algorithm)
expect_identical(augTest$convergence, augControl$status)
expect_identical(augTest$message, augControl$message)

# Test LBFGS version
augTest <- auglag(x0, fn, hin = hin, heq = heq, localsolver = "LBFGS",
                  deprecatedBehavior = FALSE)

augControl <- nloptr(x0 = x0,
                     eval_f = fn,
                     eval_grad_f = gr,
                     eval_g_ineq = hin,
                     eval_jac_g_ineq = hinjac,
                     eval_g_eq = heq,
                     eval_jac_g_eq = heqjac,
                     opts = list(algorithm = "NLOPT_LD_AUGLAG",
                                 xtol_rel = 1e-6,
                                 maxeval = 1000L,
                                 local_opts = list(algorithm = "NLOPT_LD_LBFGS",
                                                   eval_grad_f = gr,
                                                   xtol_rel = 1e-6)))

expect_identical(augTest$par, augControl$solution)
expect_identical(augTest$value, augControl$objective)
expect_identical(augTest$global_solver, augControl$options$algorithm)
expect_identical(augTest$local_solver, augControl$local_options$algorithm)
expect_identical(augTest$convergence, augControl$status)
expect_identical(augTest$message, augControl$message)

# Test MMA version
augTest <- auglag(x0, fn, hin = hin, heq = heq, localsolver = "MMA",
                  deprecatedBehavior = FALSE)

augControl <- nloptr(x0 = x0,
                     eval_f = fn,
                     eval_grad_f = gr,
                     eval_g_ineq = hin,
                     eval_jac_g_ineq = hinjac,
                     eval_g_eq = heq,
                     eval_jac_g_eq = heqjac,
                     opts = list(algorithm = "NLOPT_LD_AUGLAG",
                                 xtol_rel = 1e-6,
                                 maxeval = 1000L,
                                 local_opts = list(algorithm = "NLOPT_LD_MMA",
                                                   eval_grad_f = gr,
                                                   xtol_rel = 1e-6)))

expect_identical(augTest$par, augControl$solution)
expect_identical(augTest$value, augControl$objective)
expect_identical(augTest$global_solver, augControl$options$algorithm)
expect_identical(augTest$local_solver, augControl$local_options$algorithm)
expect_identical(augTest$convergence, augControl$status)
expect_identical(augTest$message, augControl$message)

# Test deprecated message
expect_warning(auglag(x0, fn, hin = hin2), depMess)

# Test old behavior still works
augTest <- suppressWarnings(auglag(x0, fn, hin = hin2, hinjac = hinjac2,
                                   heq = heq, localsolver = "MMA"))

expect_identical(augTest$par, augControl$solution)
expect_identical(augTest$value, augControl$objective)
expect_identical(augTest$global_solver, augControl$options$algorithm)
expect_identical(augTest$local_solver, augControl$local_options$algorithm)
expect_identical(augTest$convergence, augControl$status)
expect_identical(augTest$message, augControl$message)
