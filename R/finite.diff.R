# Copyright (C) 2011 Jelmer Ypma. All Rights Reserved.
# SPDX-License-Identifier: LGPL-3.0-or-later
#
# File:   finite.diff.R
# Author: Jelmer Ypma
# Date:   24 July 2011
#
# CHANGELOG
#
#  2023-02-10: Tweaked for efficiency and clarity. Also switched to using vapply
#              which is both faster and type-safe. Not sure if we need to carry
#              both this and nl.grad/jacobian but not changing for now.
#              (Avraham Adler)
#
# Approximate the gradient of a function using finite differences.
#
# Input:
#        func : calculate finite difference approximation for the gradient of
#               this function
#        .x : evaluate at this point
#        indices : calculate finite difference approximation only for .x-indices
#                  in this vector (optional)
#        stepSize : relative size of the step between x and x + h (optional)
#       ... : arguments that are passed to the user-defined function (func)
#
# Output: matrix with finite difference approximations
#


# http://en.wikipedia.org/wiki/Numerical_differentiation
finite.diff <- function(func, .x, indices = seq_along(.x),
                        stepSize = sqrt(.Machine$double.eps), ...) {

  # if we evaluate at values close to 0, we need a different step size
  stepSizeVec <- pmax(abs(.x), 1) * stepSize

  fx <- func(.x, ...)
  approx.gradf.index <- function(i, .x, func, fx, stepSizeVec, ...) {
    x_prime <- .x
    x_prime[i] <- .x[i] + stepSizeVec[i]
    stepSizeVec[i] <- x_prime[i] - .x[i]
    fx_prime <- func(x_prime, ...)
    (fx_prime - fx) / stepSizeVec[i]
  }

  vapply(indices, approx.gradf.index, double(length(fx)), .x = .x, func = func,
         fx = fx, stepSizeVec = stepSizeVec, ...)
}
