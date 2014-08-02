# Copyright (C) 2014 Hans W. Borchers. All Rights Reserved.
# This code is published under the L-GPL.
#
# File:   direct.R
# Author: Hans W. Borchers
# Date:   27 January 2014
#
# Wrapper to solve optimization problem using Direct.

direct <-
function(fn, lower, upper, scaled = TRUE, original = FALSE,
            nl.info = FALSE, control = list(), ...)
{
    opts <- nl.opts(control)
    if (scaled) {
        opts["algorithm"] <- "NLOPT_GN_DIRECT"
    } else {
        opts["algorithm"] <- "NLOPT_GN_DIRECT_NOSCAL"
    }
    if (original)
        opts["algorithm"] <- "NLOPT_GN_ORIG_DIRECT"

    fun <- match.fun(fn)
    fn  <- function(x) fun(x, ...)

    x0 <- (lower + upper) / 2

    S0 <- nloptr(x0,
                eval_f = fn,
                lb = lower,
                ub = upper,
                opts = opts)

    if (nl.info) print(S0)
    S1 <- list(par = S0$solution, value = S0$objective, iter = S0$iterations,
                convergence = S0$status, message = S0$message)
    return(S1)
}


directL <-
function(fn, lower, upper, randomized = FALSE, original = FALSE,
            nl.info = FALSE, control = list(), ...)
{
    opts <- nl.opts(control)
    if (randomized) {
        opts["algorithm"] <- "NLOPT_GN_DIRECT_L_RAND"
    } else {
        opts["algorithm"] <- "NLOPT_GN_DIRECT_L"
    }
    if (original)
        opts["algorithm"] <- "NLOPT_GN_ORIG_DIRECT_L"
    

    fun <- match.fun(fn)
    fn  <- function(x) fun(x, ...)

    x0 <- (lower + upper) / 2

    S0 <- nloptr(x0,
                eval_f = fn,
                lb = lower,
                ub = upper,
                opts = opts)

    if (nl.info) print(S0)
    S1 <- list(par = S0$solution, value = S0$objective, iter = S0$iterations,
                convergence = S0$status, message = S0$message)
    return(S1)
}
