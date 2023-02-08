# Copyright (C) 2014 Hans W. Borchers. All Rights Reserved.
# SPDX-License-Identifier: LGPL-3.0-or-later
#
# File:   mma.R
# Author: Hans W. Borchers
# Date:   27 January 2014
#
# Wrapper to solve optimization problem using MMA.



#' Method of Moving Asymptotes
#'
#' Globally-convergent method-of-moving-asymptotes (MMA) algorithm for
#' gradient-based local optimization, including nonlinear inequality
#' constraints (but not equality constraints).
#'
#' This is an improved CCSA ("conservative convex separable approximation")
#' variant of the original MMA algorithm published by Svanberg in 1987, which
#' has become popular for topology optimization. Note:
#'
#' @param x0 starting point for searching the optimum.
#' @param fn objective function that is to be minimized.
#' @param gr gradient of function \code{fn}; will be calculated numerically if
#' not specified.
#' @param lower,upper lower and upper bound constraints.
#' @param hin function defining the inequality constraints, that is
#' \code{hin>=0} for all components.
#' @param hinjac Jacobian of function \code{hin}; will be calculated
#' numerically if not specified.
#' @param nl.info logical; shall the original NLopt info been shown.
#' @param control list of options, see \code{nl.opts} for help.
#' @param ... additional arguments passed to the function.
#'
#' @return List with components:
#'   \item{par}{the optimal solution found so far.}
#'   \item{value}{the function value corresponding to \code{par}.}
#'   \item{iter}{number of (outer) iterations, see \code{maxeval}.}
#'   \item{convergence}{integer code indicating successful completion (> 1)
#'     or a possible error number (< 0).}
#'   \item{message}{character string produced by NLopt and giving additional
#'     information.}
#'
#' @export mma
#'
#' @author Hans W. Borchers
#'
#' @note ``Globally convergent'' does not mean that this algorithm converges to
#' the global optimum; it means that it is guaranteed to converge to some local
#' minimum from any feasible starting point.
#'
#' @seealso \code{\link{slsqp}}
#'
#' @references Krister Svanberg, ``A class of globally convergent optimization
#' methods based on conservative convex separable approximations,'' SIAM J.
#' Optim. 12 (2), p. 555-573 (2002).
#'
#' @examples
#'
#' ##  Solve the Hock-Schittkowski problem no. 100 with analytic gradients
#' x0.hs100 <- c(1, 2, 0, 4, 0, 1, 1)
#' fn.hs100 <- function(x) {
#'     (x[1]-10)^2 + 5*(x[2]-12)^2 + x[3]^4 + 3*(x[4]-11)^2 + 10*x[5]^6 +
#'                   7*x[6]^2 + x[7]^4 - 4*x[6]*x[7] - 10*x[6] - 8*x[7]
#' }
#' hin.hs100 <- function(x) {
#'     h <- numeric(4)
#'     h[1] <- 127 - 2*x[1]^2 - 3*x[2]^4 - x[3] - 4*x[4]^2 - 5*x[5]
#'     h[2] <- 282 - 7*x[1] - 3*x[2] - 10*x[3]^2 - x[4] + x[5]
#'     h[3] <- 196 - 23*x[1] - x[2]^2 - 6*x[6]^2 + 8*x[7]
#'     h[4] <- -4*x[1]^2 - x[2]^2 + 3*x[1]*x[2] -2*x[3]^2 - 5*x[6]	+11*x[7]
#'     return(h)
#' }
#' gr.hs100 <- function(x) {
#'    c(  2 * x[1] -  20,
#'       10 * x[2] - 120,
#'        4 * x[3]^3,
#'        6 * x[4] - 66,
#'       60 * x[5]^5,
#'       14 * x[6]   - 4 * x[7] - 10,
#'        4 * x[7]^3 - 4 * x[6] -  8 )}
#' hinjac.hs100 <- function(x) {
#'     matrix(c(4*x[1], 12*x[2]^3, 1, 8*x[4], 5, 0, 0,
#'         7, 3, 20*x[3], 1, -1, 0, 0,
#'         23, 2*x[2], 0, 0, 0, 12*x[6], -8,
#'         8*x[1]-3*x[2], 2*x[2]-3*x[1], 4*x[3], 0, 0, 5, -11), 4, 7, byrow=TRUE)
#' }
#'
#' # incorrect result with exact jacobian
#' S <- mma(x0.hs100, fn.hs100, gr = gr.hs100,
#'             hin = hin.hs100, hinjac = hinjac.hs100,
#'             nl.info = TRUE, control = list(xtol_rel = 1e-8))
#'
#' \donttest{
#' # This example is put in donttest because it runs for more than
#' # 40 seconds under 32-bit Windows. The difference in time needed
#' # to execute the code between 32-bit Windows and 64-bit Windows
#' # can probably be explained by differences in rounding/truncation
#' # on the different systems. On Windows 32-bit more iterations
#' # are needed resulting in a longer runtime.
#' # correct result with inexact jacobian
#' S <- mma(x0.hs100, fn.hs100, hin = hin.hs100,
#'             nl.info = TRUE, control = list(xtol_rel = 1e-8))
#' }
#'
mma <- function(x0, fn, gr = NULL, lower = NULL, upper = NULL,
                    hin = NULL, hinjac = NULL,
                    nl.info = FALSE, control = list(), ...) {

    opts <- nl.opts(control)
    opts["algorithm"] <- "NLOPT_LD_MMA"

    fun <- match.fun(fn)
    fn  <- function(x) fun(x, ...)

    if (is.null(gr)) {
        gr <- function(x) nl.grad(x, fn)
    } else {
        .gr <- match.fun(gr)
        gr <- function(x) .gr(x, ...)
    }


    if (!is.null(hin)) {
        if ( getOption('nloptr.show.inequality.warning') ) {
            message('For consistency with the rest of the package the inequality sign may be switched from >= to <= in a future nloptr version.')
        }

        .hin <- match.fun(hin)
        hin <- function(x) (-1) * .hin(x)   # change  hin >= 0  to  hin <= 0 !
        if (is.null(hinjac)) {
            hinjac <- function(x) nl.jacobian(x, hin)
        } else {
            .hinjac <- match.fun(hinjac)
            hinjac <- function(x) (-1) * .hinjac(x)
        }
    }

    S0 <- nloptr(x0,
                eval_f = fn,
                eval_grad_f = gr,
                lb = lower,
                ub = upper,
                eval_g_ineq = hin,
                eval_jac_g_ineq = hinjac,
                opts = opts)

    if (nl.info) print(S0)
    S1 <- list(par = S0$solution, value = S0$objective, iter = S0$iterations,
                convergence = S0$status, message = S0$message)
    return(S1)
}
