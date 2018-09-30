# Copyright (C) 2014 Hans W. Borchers. All Rights Reserved.
# This code is published under the L-GPL.
#
# File:   gradients.R
# Author: Hans W. Borchers
# Date:   27 January 2014
#
# Functions to calculate numerical Gradient and Jacobian.


#' Numerical Gradients and Jacobians
#'
#' Provides numerical gradients and jacobians.
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
#'   fn1 <- function(x) sum(x^2)
#'   nl.grad(seq(0, 1, by = 0.2), fn1)
#'   ## [1] 0.0  0.4  0.8  1.2  1.6  2.0
#'   nl.grad(rep(1, 5), fn1)
#'   ## [1] 2  2  2  2  2
#'
#'   fn2 <- function(x) c(sin(x), cos(x))
#'   x <- (0:1)*2*pi
#'   nl.jacobian(x, fn2)
#'   ##      [,1] [,2]
#'   ## [1,]    1    0
#'   ## [2,]    0    1
#'   ## [3,]    0    0
#'   ## [4,]    0    0
#'
nl.grad <-
    function (x0, fn, heps = .Machine$double.eps^(1/3), ...)
    {
        if (!is.numeric(x0))
            stop("Argument 'x0' must be a numeric value.")

        fun <- match.fun(fn)
        fn  <- function(x) fun(x, ...)
        if (length(fn(x0)) != 1)
            stop("Function 'f' must be a univariate function of 2 variables.")

        n <- length(x0)
        hh <- rep(0, n)
        gr <- numeric(n)
        for (i in 1:n) {
            hh[i] <- heps
            gr[i] <- (fn(x0 + hh) - fn(x0 - hh)) / (2*heps)
            hh[i] <- 0
        }
        return(gr)
    }

#' @export
nl.jacobian <-
    function(x0, fn, heps = .Machine$double.eps^(1/3), ...)
    {
    if (!is.numeric(x0) || length(x0) == 0)
        stop("Argument 'x' must be a non-empty numeric vector.")

    fun <- match.fun(fn)
    fn  <- function(x) fun(x, ...)

    n <- length(x0)
    m <- length(fn(x0))
    jacob <- matrix(NA, m, n)
    hh <- numeric(n)
    for (i in 1:n) {
        hh[i] <- heps
        jacob[, i] <- (fn(x0 + hh) - fn(x0 - hh)) / (2*heps)
        hh[i] <- 0
    }
    return(jacob)
}
