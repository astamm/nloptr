# Copyright (C) 2023 Avraham Adler. All Rights Reserved.
# This code is published under the L-GPL.
#
# File:   test-wrapper-auglag
# Author: Avraham Adler
# Date:   6 February 2023
#
# Test wrapper calls to auglag algorithm
#
# Changelog:
#

ineqMess <- paste("For consistency with the rest of the package the inequality",
                  "sign may be switched from >= to <= in a future nloptr",
                  "version.")

# Taken from example
x0 <- c(1, 1)
fn <- function(x) (x[1L] - 2) ^ 2 + (x[2L] - 1) ^ 2
hin <- function(x) -0.25 * x[1L] ^ 2 - x[2L] ^ 2 + 1    # hin >= 0
heq <- function(x) x[1L] - 2 * x[2L] + 1                # heq == 0
gr <- function(x) nl.grad(x, fn)
hinjac <- function(x) nl.jacobian(x, hin)
heqjac <- function(x) nl.jacobian(x, heq)
hin2 <- function(x) -hin(x)                       # hin2 <= 0 needed for nloptr
hinjac2 <- function(x) nl.jacobian(x, hin2)

# Test errors
expect_error(auglag(x0, fn, ineq2local = TRUE),
             "Inequalities to local solver: feature not yet implemented.")
expect_error(auglag(x0, fn, localsolver = "NLOPT_LN_NELDERMEAD"),
             "Only local solvers allowed: BOBYQA, COBYLA, LBFGS, MMA, SLSQP.")

# Test messages
expect_message(auglag(x0, fn, gr = NULL, hin = hin, heq = heq), ineqMess)

# Test printout if nl.info passed. The word "Call:" should be in output if
# passed and not if not passed.
expect_output(suppressMessages(auglag(x0, fn, gr = NULL, hin = hin, heq = heq,
                                      nl.info = TRUE)), "Call:", fixed = TRUE)

expect_silent(suppressMessages(auglag(x0, fn, gr = NULL, hin = hin, heq = heq,
                                      nl.info = FALSE)))

# Test COBYLA version
augTest <- suppressMessages(auglag(x0, fn, gr = NULL, hin = hin, heq = heq))

augControl <- nloptr(x0 = x0,
                     eval_f = fn,
                     eval_g_ineq = hin2,
                     eval_g_eq = heq,
                     opts = list(algorithm = "NLOPT_LN_AUGLAG",
                                 xtol_rel = 1e-6,
                                 maxeval = 1000L,
                                 local_opts = list(algorithm = "NLOPT_LN_COBYLA",
                                                   xtol_rel = 1e-6)
                                 )
                     )

expect_identical(augTest$par, augControl$solution)
expect_identical(augTest$value, augControl$objective)
expect_identical(augTest$global_solver, augControl$options$algorithm)
expect_identical(augTest$local_solver, augControl$local_options$algorithm)
expect_identical(augTest$convergence, augControl$status)
expect_identical(augTest$message, augControl$message)

# Test BOBYQA version
augTest <- suppressMessages(auglag(x0, fn, gr = NULL, hin = hin, heq = heq,
                                   localsolver = "BOBYQA"))

augControl <- nloptr(x0 = x0,
                     eval_f = fn,
                     eval_g_ineq = hin2,
                     eval_g_eq = heq,
                     opts = list(algorithm = "NLOPT_LN_AUGLAG",
                                 xtol_rel = 1e-6,
                                 maxeval = 1000L,
                                 local_opts = list(algorithm = "NLOPT_LN_BOBYQA",
                                                   xtol_rel = 1e-6)
                     )
)

expect_identical(augTest$par, augControl$solution)
expect_identical(augTest$value, augControl$objective)
expect_identical(augTest$global_solver, augControl$options$algorithm)
expect_identical(augTest$local_solver, augControl$local_options$algorithm)
expect_identical(augTest$convergence, augControl$status)
expect_identical(augTest$message, augControl$message)

# Test SLSQP version
# No passed hin/heq Jacobian
augTest <- suppressMessages(auglag(x0, fn, gr = NULL, hin = hin, heq = heq,
                                   localsolver = "SLSQP"))
augControl <- nloptr(x0 = x0,
                     eval_f = fn,
                     eval_grad_f = gr,
                     eval_g_ineq = hin2,
                     eval_jac_g_ineq = hinjac2,
                     eval_g_eq = heq,
                     eval_jac_g_eq = heqjac,
                     opts = list(algorithm = "NLOPT_LD_AUGLAG",
                                 xtol_rel = 1e-6,
                                 maxeval = 1000L,
                                 local_opts = list(algorithm = "NLOPT_LD_SLSQP",
                                                   eval_grad_f = gr,
                                                   xtol_rel = 1e-6)
                                 )
                     )

expect_identical(augTest$par, augControl$solution)
expect_identical(augTest$value, augControl$objective)
expect_identical(augTest$global_solver, augControl$options$algorithm)
expect_identical(augTest$local_solver, augControl$local_options$algorithm)
expect_identical(augTest$convergence, augControl$status)
expect_identical(augTest$message, augControl$message)

# Passed hin/heq Jacobian
augTest <- suppressMessages(auglag(x0, fn, gr = NULL, hin = hin, heq = heq,
                                   hinjac = hinjac, heqjac = heqjac,
                                   localsolver = "SLSQP"))

expect_identical(augTest$par, augControl$solution)
expect_identical(augTest$value, augControl$objective)
expect_identical(augTest$global_solver, augControl$options$algorithm)
expect_identical(augTest$local_solver, augControl$local_options$algorithm)
expect_identical(augTest$convergence, augControl$status)
expect_identical(augTest$message, augControl$message)

# Test LBFGS version
augTest <- suppressMessages(auglag(x0, fn, gr = NULL, hin = hin, heq = heq,
                                   localsolver = "LBFGS"))
augControl <- nloptr(x0 = x0,
                     eval_f = fn,
                     eval_grad_f = gr,
                     eval_g_ineq = hin2,
                     eval_jac_g_ineq = hinjac2,
                     eval_g_eq = heq,
                     eval_jac_g_eq = heqjac,
                     opts = list(algorithm = "NLOPT_LD_AUGLAG",
                                 xtol_rel = 1e-6,
                                 maxeval = 1000L,
                                 local_opts = list(algorithm = "NLOPT_LD_LBFGS",
                                                   eval_grad_f = gr,
                                                   xtol_rel = 1e-6)
                     )
)

expect_identical(augTest$par, augControl$solution)
expect_identical(augTest$value, augControl$objective)
expect_identical(augTest$global_solver, augControl$options$algorithm)
expect_identical(augTest$local_solver, augControl$local_options$algorithm)
expect_identical(augTest$convergence, augControl$status)
expect_identical(augTest$message, augControl$message)

# Test MMA version
augTest <- suppressMessages(auglag(x0, fn, gr = NULL, hin = hin, heq = heq,
                                   localsolver = "MMA"))
augControl <- nloptr(x0 = x0,
                     eval_f = fn,
                     eval_grad_f = gr,
                     eval_g_ineq = hin2,
                     eval_jac_g_ineq = hinjac2,
                     eval_g_eq = heq,
                     eval_jac_g_eq = heqjac,
                     opts = list(algorithm = "NLOPT_LD_AUGLAG",
                                 xtol_rel = 1e-6,
                                 maxeval = 1000L,
                                 local_opts = list(algorithm = "NLOPT_LD_MMA",
                                                   eval_grad_f = gr,
                                                   xtol_rel = 1e-6)
                     )
)

expect_identical(augTest$par, augControl$solution)
expect_identical(augTest$value, augControl$objective)
expect_identical(augTest$global_solver, augControl$options$algorithm)
expect_identical(augTest$local_solver, augControl$local_options$algorithm)
expect_identical(augTest$convergence, augControl$status)
expect_identical(augTest$message, augControl$message)
