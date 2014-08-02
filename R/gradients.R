# Copyright (C) 2014 Hans W. Borchers. All Rights Reserved.
# This code is published under the L-GPL.
#
# File:   gradients.R
# Author: Hans W. Borchers
# Date:   27 January 2014
#
# Functions to calculate numerical Gradient and Jacobian.

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
