# Copyright (C) 2014 Hans W. Borchers. All Rights Reserved.
# SPDX-License-Identifier: LGPL-3.0-or-later
#
# File:   varmetric.R
# Author: Hans W. Borchers
# Date:   27 January 2014
#
# Wrapper to solve optimization problem using Varmetric.
#
# CHANGELOG
#   2023-02-08: Cleanup and tweaks for safety and efficiency (Avraham Adler)
#


#' Shifted Limited-memory Variable-metric
#'
#' Shifted limited-memory variable-metric algorithm.
#'
#' Variable-metric methods are a variant of the quasi-Newton methods,
#' especially adapted to large-scale unconstrained (or bound constrained)
#' minimization.
#'
#' @param x0 initial point for searching the optimum.
#' @param fn objective function to be minimized.
#' @param gr gradient of function \code{fn}; will be calculated numerically if
#' not specified.
#' @param rank2 logical; if true uses a rank-2 update method, else rank-1.
#' @param lower,upper lower and upper bound constraints.
#' @param nl.info logical; shall the original NLopt info been shown.
#' @param control list of control parameters, see \code{nl.opts} for help.
#' @param ... further arguments to be passed to the function.
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
#' @export varmetric
#'
#' @author Hans W. Borchers
#'
#' @note Based on L. Luksan's Fortran implementation of a shifted
#' limited-memory variable-metric algorithm.
#'
#' @seealso \code{\link{lbfgs}}
#'
#' @references J. Vlcek and L. Luksan, ``Shifted limited-memory variable metric
#' methods for large-scale unconstrained minimization,'' J. Computational Appl.
#' Math. 186, p. 365-390 (2006).
#'
#' @examples
#'
#' flb <- function(x) {
#'     p <- length(x)
#'     sum(c(1, rep(4, p-1)) * (x - c(1, x[-p])^2)^2)
#' }
#' # 25-dimensional box constrained: par[24] is *not* at the boundary
#' S <- varmetric(rep(3, 25), flb, lower=rep(2, 25), upper=rep(4, 25),
#'            nl.info = TRUE, control = list(xtol_rel=1e-8))
#' ## Optimal value of objective function:  368.105912874334
#' ## Optimal value of controls: 2  ...  2  2.109093  4
#'
varmetric <- function(x0, fn, gr = NULL, rank2 = TRUE, lower = NULL,
                      upper = NULL, nl.info = FALSE, control = list(), ...) {

    opts <- nl.opts(control)
    if (rank2)
        opts["algorithm"] <- "NLOPT_LD_VAR2"
    else
        opts["algorithm"] <- "NLOPT_LD_VAR1"

    fun <- match.fun(fn)
    fn <- function(x) fun(x, ...)

    if (is.null(gr)) {
        gr <- function(x) nl.grad(x, fn)
    } else {
        .gr <- match.fun(gr)
        gr <- function(x) .gr(x, ...)
    }

    S0 <- nloptr(x0,
                eval_f = fn,
                eval_grad_f = gr,
                lb = lower,
                ub = upper,
                opts = opts)

    if (nl.info) print(S0)
    list(par = S0$solution, value = S0$objective, iter = S0$iterations,
         convergence = S0$status, message = S0$message)
}
