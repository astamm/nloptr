# Copyright (C) 2010 Jelmer Ypma. All Rights Reserved.
# SPDX-License-Identifier: LGPL-3.0-or-later
#
# File:   test-parameters.R
# Author: Jelmer Ypma
# Date:   17 August 2010
#
# Maintenance assumed by Avraham Adler (AA) on 2023-02-10
#
# Example shows how we can have an objective function
# depend on parameters or data. The objective function
# is a simple polynomial.
#
# CHANGELOG:
#   2014-05-05: Changed example to use unit testing framework testthat.
#   2019-12-12: Corrected warnings and using updated testtthat framework (AA)
#   2023-02-07: Remove wrapping tests in "test_that" to reduce duplication. (AA)
#

library(nloptr)

# Test simple polyonmial where parameters are supplied as additional data.

# Objective function and gradient in terms of parameters.
eval_f <- function(x, params) {
  params[1] * x ^ 2 + params[2] * x + params[3]
}

eval_grad_f <- function(x, params) {
  2 * params[1] * x + params[2]
}

# Define parameters that we want to use.
params <- c(1, 2, 3)

# Define initial value of the optimization problem.
x0 <- 0

# Solve using nloptr adding params as an additional parameter
res <- nloptr(
  x0          = x0,
  eval_f      = eval_f,
  eval_grad_f = eval_grad_f,
  opts        = list("algorithm" = "NLOPT_LD_MMA", "xtol_rel" = 1e-6),
  params      = params
)

# Solve using algebra
# Minimize f(x) = ax^2 + bx + c.
# Optimal value for control is -b/(2a).
expect_equal(res$solution, -params[2] / (2 * params[1]), tolerance = 1e-7)

# With value of the objective function f(-b/(2a)).
expect_equivalent(res$objective, eval_f(-params[2] / (2 * params[1]), params))
