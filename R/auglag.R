# Copyright (C) 2014 Hans W. Borchers. All Rights Reserved.
# This code is published under the L-GPL.
#
# File:   auglag.R
# Author: Hans W. Borchers
# Date:   27 January 2014
#
# Wrapper to solve optimization problem using Augmented Lagrangian.

auglag <-
function(x0, fn, gr = NULL, lower = NULL, upper = NULL,
            hin = NULL, hinjac = NULL, heq = NULL, heqjac = NULL,
            localsolver = c("COBYLA"), localtol = 1e-6, ineq2local = FALSE,
            nl.info = FALSE, control = list(), ...)
{
    if (ineq2local) {
        # gsolver <- "NLOPT_LN_AUGLAG_EQ"
        stop("Inequalities to local solver: feature not yet implemented.")
    }

    localsolver <- toupper(localsolver)
    if (localsolver %in% c("COBYLA")) {   # derivative-free
        dfree <- TRUE
        gsolver <- "NLOPT_LN_AUGLAG"
        lsolver <- paste("NLOPT_LN_", localsolver, sep = "")
    } else if (localsolver %in% c("LBFGS", "MMA", "SLSQP")) { # with derivatives
        dfree <- FALSE
        gsolver <- "NLOPT_LD_AUGLAG"
        lsolver <- paste("NLOPT_LD_", localsolver, sep = "")
    } else {
        stop("Only local solvers allowed: BOBYQA, COBYLA, LBFGS, MMA, SLSQP.")
    }

    # Function and gradient, if needed
    .fn <- match.fun(fn)
    fn  <- function(x) .fn(x, ...)
    
    if (!dfree && is.null(gr)) {
        gr <- function(x) nl.grad(x, fn)
    }

    # Global and local options
    opts <- nl.opts(control)
    opts$algorithm <- gsolver
    local_opts <- list(algorithm = lsolver,
                        xtol_rel = localtol,
                        eval_grad_f = if (!dfree) gr else NULL)
    opts$local_opts <- local_opts
        
    # Inequality constraints
    if (!is.null(hin)) {
        .hin <- match.fun(hin)
        hin <- function(x) (-1) * .hin(x)   # change  hin >= 0  to  hin <= 0 !
    }
    if (!dfree) {
        if (is.null(hinjac)) {
            hinjac <- function(x) nl.jacobian(x, hin)
        } else {
            .hinjac <- match.fun(hinjac)
            hinjac <- function(x) (-1) * .hinjac(x)
        }
    }

    # Equality constraints
    if (!is.null(heq)) {
        .heq <- match.fun(heq)
        heq <- function(x) .heq(x)
    }
    if (!dfree) {
        if (is.null(heqjac)) {
            heqjac <- function(x) nl.jacobian(x, heq)
        } else {
            .heqjac <- match.fun(heqjac)
            heqjac <- function(x) .heqjac(x)
        }
    }

    S0 <- nloptr(x0,
                eval_f = fn,
                eval_grad_f = gr,
                lb = lower,
                ub = upper,
                eval_g_ineq = hin,
                eval_jac_g_ineq = hinjac,
                eval_g_eq = heq,
                eval_jac_g_eq = heqjac,
                opts = opts)

    if (nl.info) print(S0)
    S1 <- list( par = S0$solution, value = S0$objective, iter = S0$iterations,
                global_solver = gsolver, local_solver = lsolver,
                convergence = S0$status, message = S0$message)
    return(S1)
}
