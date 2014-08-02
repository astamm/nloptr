# Copyright (C) 2014 Hans W. Borchers. All Rights Reserved.
# This code is published under the L-GPL.
#
# File:   global.R
# Author: Hans W. Borchers
# Date:   27 January 2014
#
# Wrapper to solve optimization problem using StoGo.

#-- Does not work: maybe C++ support missing? ---------------------- StoGo ---
stogo <-
function(x0, fn, gr = NULL, lower = NULL, upper = NULL,
            maxeval = 10000, xtol_rel = 1e-6, randomized = FALSE,
            nl.info = FALSE, ...)  # control = list()
{
    # opts <- nl.opts(control)
    opts <- list()
    opts$maxeval    <- maxeval
    opts$xtol_rel   <- xtol_rel
    if (randomized) opts["algorithm"] <- "NLOPT_GD_STOGO_RAND"
    else            opts["algorithm"] <- "NLOPT_GD_STOGO"

    fun <- match.fun(fn)
    fn  <- function(x) fun(x, ...)

    if (is.null(gr)) {
        gr <- function(x) nl.grad(x, fn)
    }

    S0 <- nloptr(x0,
                eval_f = fn,
                eval_grad_f = gr,
                lb = lower,
                ub = upper,
                opts = opts)

    if (nl.info) print(S0)
    S1 <- list(par = S0$solution, value = S0$objective, iter = S0$iterations,
                convergence = S0$status, message = S0$message)
    return(S1)
}


#-- Supports nonlinear constraints: quite inaccurate! -------------- ISRES ---
isres <-
function(x0, fn, lower, upper, hin = NULL, heq = NULL,
            maxeval = 10000, pop.size = 20*(length(x0)+1),
            xtol_rel = 1e-6, nl.info = FALSE, ...)
{
    #opts <- nl.opts(control)
    opts <- list()
    opts$maxeval    <- maxeval
    opts$xtol_rel   <- xtol_rel
    opts$population <- pop.size
    opts$algorithm  <- "NLOPT_GN_ISRES"

    fun <- match.fun(fn)
    fn  <- function(x) fun(x, ...)

    if (!is.null(hin)) {
        .hin <- match(hin)
        hin <- function(x) (-1) * .hin(x)   # change  hin >= 0  to  hin <= 0 !
    }

    if (!is.null(heq)) {
        .heq <- match.fun(heq)
        heq <- function(x) .heq(x)
    }

    S0 <- nloptr(x0 = x0,
                eval_f = fn,
                lb = lower,
                ub = upper,
                eval_g_ineq = hin,
                eval_g_eq = heq,
                opts = opts)

    if (nl.info) print(S0)
    S1 <- list(par = S0$solution, value = S0$objective, iter = S0$iterations,
                convergence = S0$status, message = S0$message)
    return(S1)
}


#-- ------------------------------------------------------------------ CRS ---
crs2lm <-
function(x0, fn, lower, upper,
            maxeval = 10000, pop.size = 10*(length(x0)+1), ranseed = NULL,
            xtol_rel = 1e-6, nl.info = FALSE, ...)
{
    #opts <- nl.opts(control)
    opts <- list()
    opts$maxeval    <- maxeval
    opts$xtol_rel   <- xtol_rel
    opts$population <- pop.size
    if (!is.null(ranseed)) 
       opts$ranseed <- as.integer(ranseed)
    opts$algorithm  <- "NLOPT_GN_CRS2_LM"

    fun <- match.fun(fn)
    fn  <- function(x) fun(x, ...)

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
