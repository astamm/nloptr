# Copyright (C) 2025 Aymeric Stamm. All Rights Reserved.
# SPDX-License-Identifier: LGPL-3.0-or-later
#
# File:   test-options-xweights.R
# Author: Aymeric Stamm
# Date:   08 August 2025
#
# Check whether the solver stops when maxtime
# (set in the options) is reached.

library(nloptr)
tol <- sqrt(.Machine$double.eps)

# Rosenbrock banana function (rbf)
rbf <- function(x) {
  (1 - x[1])^2 + 100 * (x[2] - x[1]^2)^2
}

# Analytic gradient for rbf
rbfgr <- function(x) {
  c(-2 * (1 - x[1]) - 400 * x[1] * (x[2] - x[1]^2), 200 * (x[2] - x[1]^2))
}

# Known optimium of 0 occurs at (1, 1)
rbfOptVal <- 0
rbfOptLoc <- c(1, 1)

# Initial values
x0 <- c(-1.2, 1.3)

# Solve problem.

opts <- list(
  algorithm = "NLOPT_LD_LBFGS",
  xtol_abs = 0,
  xtol_rel = 1e-1,
  ftol_rel = 0,
  ftol_abs = 0
)
res0 <- nloptr(
  x0 = x0,
  eval_f = rbf,
  eval_grad_f = rbfgr,
  opts = opts
)

expect_equal(round(res0$objective, digits = 3L), 0.027)

opts <- list(
  algorithm = "NLOPT_LD_LBFGS",
  xtol_abs = 0,
  xtol_rel = 1e-1,
  ftol_rel = 0,
  ftol_abs = 0,
  x_weights = c(1, 1)
)
res1 <- nloptr(
  x0 = x0,
  eval_f = rbf,
  eval_grad_f = rbfgr,
  opts = opts
)

# Check results.
expect_identical(res0$objective, res1$objective)

opts <- list(
  algorithm = "NLOPT_LD_LBFGS",
  xtol_abs = 0,
  xtol_rel = 1e-1,
  ftol_rel = 0,
  ftol_abs = 0,
  x_weights = 1
)
res2 <- nloptr(
  x0 = x0,
  eval_f = rbf,
  eval_grad_f = rbfgr,
  opts = opts
)

# Check results.
expect_identical(res0$objective, res2$objective)

opts <- list(
  algorithm = "NLOPT_LD_LBFGS",
  xtol_abs = 0,
  xtol_rel = 1e-1,
  ftol_rel = 0,
  ftol_abs = 0,
  x_weights = c(0.9, 0.1)
)
res3 <- nloptr(
  x0 = x0,
  eval_f = rbf,
  eval_grad_f = rbfgr,
  opts = opts
)

# Check results.
expect_equal(round(res3$objective, digits = 3L), 0.087)
