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
#       diag and pulling vectors off row-by-row in nl.grad & nl.jacobian
#       (Avraham Adler).
# 2024-07-03: Allow for more accurate five-point central estimate to be used and
#       ensure the same function in both nl.grad and nl.jacobian to prevent
#       discrepancy (Avraham Adler).
#

#' Numerical Gradients and Jacobians
#'
#' Provides numerical gradients and Jacobians.
#'
#' Both functions apply a \dQuote{central difference formula} with the step size
#' selected as recommended in the literature depending on whether a three or
#' five point estimate is used.
#'
#' @aliases nl.grad nl.jacobian
#'
#' @param x0 Point as a vector where the gradient is to be calculated.
#' @param fn Scalar function of one or several variables.
#' @param heps Step size to be used. Defaults to \code{NULL} and is selected
#'   based on the number of points used in the estimation algorithm.
#' @param points Either a 3 or 5 point numerical estimate.
#' @param \dots Additional arguments passed to the function.
#'
#' @returns \code{grad} returns the gradient as a vector;
#'   \code{jacobian} returns the Jacobian as a matrix of the usual dimensions.
#'
#' @export
#'
#' @author Hans W. Borchers, Avraham Adler \email{Avraham.Adler@@gmail.com}
#'
#' @references Sauer, Timothy (2012) *Numerical Analysis* (2nd ed.).
#'  Addison-Wesley Publishing Company. ISBN 978-0321783677
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
#'   nl.jacobian(x, fn2, points = 5)
#'   ##    [,1] [,2]
#'   ## [1,]  1  0
#'   ## [2,]  0  1
#'   ## [3,]  0  0
#'   ## [4,]  0  0
#'

## (2024-07-03) TO DO: Change order of parameters to put points before heps at
## next breaking change (AA).
nl.grad <- function(x0, fn, heps = NULL, points = 3, ...) {

  if (!is.numeric(x0)) stop("Argument 'x0' must be a numeric value.")

  if (!(points %in% c(3, 5))) stop("Argument 'points' must be either 3 or 5.")
  gradCalc <- switch(as.character(points), "3" = grad.3pc, grad.5pc)
  if (is.null(heps)) heps <- .Machine$double.eps ^ (1 / points)

  fun <- match.fun(fn)
  fn  <- function(x) fun(x, ...)
  if (length(fn(x0)) != 1)
    stop("Function 'f' must be a scalar function (return a single value).")

  n <- length(x0)
  hh <- gr <- rep(0, n)
  for (i in seq_len(n)) {
    hh[i] <- heps
    gr[i] <- gradCalc(x0, fn, hh, heps, ...)
    hh[i] <- 0
  }

  gr
}

#' @export
nl.jacobian <- function(x0, fn, heps = NULL, points = 3, ...) {

  n <- length(x0)
  if (!is.numeric(x0) || n == 0)
    stop("Argument 'x' must be a non-empty numeric vector.")

  if (!(points %in% c(3, 5))) stop("Argument 'points' must be either 3 or 5.")
  gradCalc <- switch(as.character(points), "3" = grad.3pc, grad.5pc)
  if (is.null(heps)) heps <- .Machine$double.eps ^ (1 / points)

  fun <- match.fun(fn)
  fn  <- function(x) fun(x, ...)

  jacob <- matrix(NA_real_, length(fn(x0)), n)
  hh <- rep(0, n)
  for (i in seq_len(n)) {
    hh[i] <- heps
    jacob[, i] <- gradCalc(x0, fn, hh, heps, ...)
    hh[i] <- 0
  }

  jacob
}

# Three-point centered estimate (3pc).
grad.3pc <- function(x0, fn, hh, heps, ...) {
  (fn(x0 + hh) - fn(x0 - hh)) / (2 * heps)
}

# Five point centered estimate (5pc) also known as five-point stencil and has
# the same effect as one implementation of Richardson extrapolation on the
# three-point centered estimate. See Sauer p. 248 to justify heps = eps ^ 1/5.

grad.5pc <- function(x0, fn, hh, heps, ...) {
  (-fn(x0 + 2 * hh) + 8 * (fn(x0 + hh) - fn(x0 - hh)) + fn(x0 - 2 * hh)) /
    (12 * heps)
}
