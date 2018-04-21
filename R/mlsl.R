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



#' Multi-level Single-linkage
#'
#' The ``Multi-Level Single-Linkage'' (MLSL) algorithm for global optimization
#' searches by a sequence of local optimizations from random starting points.
#' A modification of MLSL is included using a low-discrepancy sequence (LDS)
#' instead of pseudorandom numbers.
#'
#' MLSL is a `multistart' algorithm: it works by doing a sequence of local
#' optimizations (using some other local optimization algorithm) from random or
#' low-discrepancy starting points.  MLSL is distinguished, however by a
#' `clustering' heuristic that helps it to avoid repeated searches of the same
#' local optima, and has some theoretical guarantees of finding all local
#' optima in a finite number of local minimizations.
#'
#' The local-search portion of MLSL can use any of the other algorithms in
#' NLopt, and in particular can use either gradient-based or derivative-free
#' algorithms.  For this wrapper only gradient-based \code{L-BFGS} is available
#' as local method.
#'
#' @param x0 initial point for searching the optimum.
#' @param fn objective function that is to be minimized.
#' @param gr gradient of function \code{fn}; will be calculated numerically if
#' not specified.
#' @param lower,upper lower and upper bound constraints.
#' @param local.method only \code{BFGS} for the moment.
#' @param low.discrepancy logical; shall a low discrepancy variation be used.
#' @param nl.info logical; shall the original NLopt info been shown.
#' @param control list of options, see \code{nl.opts} for help.
#' @param ... additional arguments passed to the function.
#'
#' @return List with components:
#'   \item{par}{the optimal solution found so far.}
#'   \item{value}{the function value corresponding to \code{par}.}
#'   \item{iter}{number of (outer) iterations, see \code{maxeval}.}
#'   \item{convergence}{integer code indicating successful completion (> 0)
#'     or a possible error number (< 0).}
#'   \item{message}{character string produced by NLopt and giving additional
#'     information.}
#'
#' @export mlsl
#'
#' @author Hans W. Borchers
#'
#' @note If you don't set a stopping tolerance for your local-optimization
#' algorithm, MLSL defaults to \code{ftol_rel=1e-15} and \code{xtol_rel=1e-7}
#' for the local searches.
#'
#' @seealso \code{\link{direct}}
#'
#' @references A. H. G. Rinnooy Kan and G. T. Timmer, ``Stochastic global
#' optimization methods'' Mathematical Programming, vol. 39, p. 27-78 (1987).
#'
#' Sergei Kucherenko and Yury Sytsko, ``Application of deterministic
#' low-discrepancy sequences in global optimization,'' Computational
#' Optimization and Applications, vol. 30, p. 297-318 (2005).
#'
#' @examples
#'
#' ### Minimize the Hartmann6 function
#' hartmann6 <- function(x) {
#'     n <- length(x)
#'     a <- c(1.0, 1.2, 3.0, 3.2)
#'     A <- matrix(c(10.0,  0.05, 3.0, 17.0,
#'                    3.0, 10.0,  3.5,  8.0,
#'                   17.0, 17.0,  1.7,  0.05,
#'                    3.5,  0.1, 10.0, 10.0,
#'                    1.7,  8.0, 17.0,  0.1,
#'                    8.0, 14.0,  8.0, 14.0), nrow=4, ncol=6)
#'     B  <- matrix(c(.1312,.2329,.2348,.4047,
#'                    .1696,.4135,.1451,.8828,
#'                    .5569,.8307,.3522,.8732,
#'                    .0124,.3736,.2883,.5743,
#'                    .8283,.1004,.3047,.1091,
#'                    .5886,.9991,.6650,.0381), nrow=4, ncol=6)
#'     fun <- 0.0
#'     for (i in 1:4) {
#'         fun <- fun - a[i] * exp(-sum(A[i,]*(x-B[i,])^2))
#'     }
#'     return(fun)
#' }
#' S <- mlsl(x0 = rep(0, 6), hartmann6, lower = rep(0,6), upper = rep(1,6),
#'             nl.info = TRUE, control=list(xtol_rel=1e-8, maxeval=1000))
#' ## Number of Iterations....: 1000
#' ## Termination conditions:
#' ##   stopval: -Inf, xtol_rel: 1e-08, maxeval: 1000, ftol_rel: 0, ftol_abs: 0
#' ## Number of inequality constraints:  0
#' ## Number of equality constraints:    0
#' ## Current value of objective function:  -3.32236801141552
#' ## Current value of controls:
#' ##   0.2016895 0.1500107 0.476874 0.2753324 0.3116516 0.6573005
#'
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
