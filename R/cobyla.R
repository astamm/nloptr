# Copyright (C) 2014 Hans W. Borchers. All Rights Reserved.
# This code is published under the L-GPL.
#
# File:   cobyla.R
# Author: Hans W. Borchers
# Date:   27 January 2014
#
# Wrapper to solve optimization problem using COBYLA, BOBYQA, and NEWUOA.

cobyla <-
function(x0, fn, lower = NULL, upper = NULL, hin = NULL,
            nl.info = FALSE, control = list(), ...)
{
    opts <- nl.opts(control)
    opts["algorithm"] <- "NLOPT_LN_COBYLA"

    f1 <- match.fun(fn)
    fn <- function(x) f1(x, ...)

    if (!is.null(hin)) {
        f2  <- match.fun(hin)
        hin <- function(x) (-1)*f2(x, ...)  # NLOPT expects hin <= 0
    }

    S0 <- nloptr(x0,
                eval_f = fn,
                lb = lower,
                ub = upper,
                eval_g_ineq = hin,
                opts = opts)

    if (nl.info) print(S0)
    S1 <- list(par = S0$solution, value = S0$objective, iter = S0$iterations,
                convergence = S0$status, message = S0$message)
    return(S1)
}


bobyqa <-
function(x0, fn, lower = NULL, upper = NULL,
                 nl.info = FALSE, control = list(), ...)
{
    opts <- nl.opts(control)
    opts["algorithm"] <- "NLOPT_LN_BOBYQA"

    fun <- match.fun(fn)
    fn <- function(x) fun(x, ...)

    S0 <- nloptr(x0, fn, lb = lower, ub = upper,
                opts = opts)

    if (nl.info) print(S0)
    S1 <- list(par = S0$solution, value = S0$objective, iter = S0$iterations,
                convergence = S0$status, message = S0$message)
    return(S1)
}


newuoa <-
function(x0, fn, nl.info = FALSE, control = list(), ...)
{
    opts <- nl.opts(control)
    opts["algorithm"] <- "NLOPT_LN_NEWUOA"

    fun <- match.fun(fn)
    fn <- function(x) fun(x, ...)

    S0 <- nloptr(x0, fn, opts = opts)

    if (nl.info) print(S0)
    S1 <- list(par = S0$solution, value = S0$objective, iter = S0$iterations,
                convergence = S0$status, message = S0$message)
    return(S1)
}
