# Copyright (C) 2014 Hans W. Borchers. All Rights Reserved.
# SPDX-License-Identifier: LGPL-3.0-or-later
#
# File:   gradients.R
# Author: Hans W. Borchers
# Date:   27 January 2014
#
# Functions to calculate numerical Gradient and Jacobian.
#
# CHANGELOG
#
# 2023-02-09: Cleanup and tweaks for safety and efficiency. Also Changed
#       nl.grad error message to be more mathematically precise. The loop
#       construct is 4 times faster than full vectorization with apply and
#       around 25% faster than partial vectorization creating a heps using
#       diag and pulling vectors off row-by-row in nl.grad & nl.jacobian.
#       (Avraham Adler)
#

#' Numerical Gradients and Jacobians
#'
#' Provides numerical gradients and Jacobians.
#'
#' Both functions apply the ``central difference formula'' with step size as
#' recommended in the literature.
#'
#' @aliases nl.grad nl.jacobian
#'
#' @param x0 point as a vector where the gradient is to be calculated.
#' @param fn scalar function of one or several variables.
#' @param heps step size to be used.
#' @param \dots additional arguments passed to the function.
#'
#' @return \code{grad} returns the gradient as a vector; \code{jacobian}
#' returns the Jacobian as a matrix of usual dimensions.
#'
#' @export
#'
#' @author Hans W. Borchers
#'
#' @examples
#'
#'   fn1 <- function(x) sum(x ^ 2)
#'   nl.grad(seq(0, 1, by = 0.2), fn1)
#'   ## [1] 0.0  0.4  0.8  1.2  1.6  2.0
#'   nl.grad(rep(1, 5), fn1)
#'   ## [1] 2  2  2  2  2
#'
#'   fn2 <- function(x) c(sin(x), cos(x))
#'   x <- (0:1) * 2 * pi
#'   nl.jacobian(x, fn2)
#'   ##    [,1] [,2]
#'   ## [1,]  1  0
#'   ## [2,]  0  1
#'   ## [3,]  0  0
#'   ## [4,]  0  0
#'
nl.grad <- function(x0, fn, heps = .Machine$double.eps^(1 / 3), ...) {
  if (!is.numeric(x0)) {
    stop("Argument 'x0' must be a numeric value.")
  }

  fun <- match.fun(fn)
  fn <- function(x) fun(x, ...)
  if (length(fn(x0)) != 1) {
    stop("Function 'f' must be a scalar function (return a single value).")
  }

  n <- length(x0)
  hh <- gr <- rep(0, n)
  for (i in seq_len(n)) {
    hh[i] <- heps
    gr[i] <- (fn(x0 + hh) - fn(x0 - hh)) / (2 * heps)
    hh[i] <- 0
  }

  gr
}

#' @export
nl.jacobian <- function(x0, fn, heps = .Machine$double.eps^(1 / 3), ...) {
  n <- length(x0)
  if (!is.numeric(x0) || n == 0) {
    stop("Argument 'x' must be a non-empty numeric vector.")
  }

  fun <- match.fun(fn)
  fn <- function(x) fun(x, ...)

  jacob <- matrix(NA_real_, length(fn(x0)), n)
  hh <- rep(0, n)
  for (i in seq_len(n)) {
    hh[i] <- heps
    jacob[, i] <- (fn(x0 + hh) - fn(x0 - hh)) / (2 * heps)
    hh[i] <- 0
  }

  jacob
}
