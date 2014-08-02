# Copyright (C) 2014 Hans W. Borchers. All Rights Reserved.
# This code is published under the L-GPL.
#
# File:   mlsl.R
# Author: Hans W. Borchers
# Date:   27 January 2014
#
# Wrapper to solve optimization problem using Multi-Level Single-Linkage.
#
# CHANGELOG:
#   05/05/2014: Replaced cat by warning.

mlsl <-
function(x0, fn, gr = NULL, lower, upper,
            local.method = "LBFGS", low.discrepancy = TRUE,
            nl.info = FALSE, control = list(), ...)
{
    local_opts <- list(algorithm = "NLOPT_LD_LBFGS",
                       xtol_rel  = 1e-4)
    opts <- nl.opts(control)
    if (low.discrepancy) {
        opts["algorithm"] <- "NLOPT_GD_MLSL_LDS"
    } else {
        opts["algorithm"] <- "NLOPT_GD_MLSL"
    }
    opts[["local_opts"]] <- local_opts

    fun <- match.fun(fn)
    fn  <- function(x) fun(x, ...)

    if (local.method == "LBFGS") {
        if (is.null(gr)) {
            gr <- function(x) nl.grad(x, fn)
        } else {
            .gr <- match.fun(gr)
            gr <- function(x) .gr(x, ...)
        }
    } else {
        warning("Only gradient-based LBFGS available as local method.")
        gr <- NULL
    }

    S0 <- nloptr(x0 = x0,
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
