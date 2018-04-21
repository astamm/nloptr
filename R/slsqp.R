# Copyright (C) 2014 Hans W. Borchers. All Rights Reserved.
# This code is published under the L-GPL.
#
# File:   slsqp.R
# Author: Hans W. Borchers
# Date:   27 January 2014
#
# Wrapper to solve optimization problem using Sequential Quadratic Programming.



#' Sequential Quadratic Programming (SQP)
#'
#' Sequential (least-squares) quadratic programming (SQP) algorithm for
#' nonlinearly constrained, gradient-based optimization, supporting both
#' equality and inequality constraints.
#'
#' The algorithm optimizes successive second-order (quadratic/least-squares)
#' approximations of the objective function (via BFGS updates), with
#' first-order (affine) approximations of the constraints.
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
#' @param heq function defining the equality constraints, that is \code{heq==0}
#' for all components.
#' @param heqjac Jacobian of function \code{heq}; will be calculated
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
#' @export slsqp
#'
#' @author Hans W. Borchers
#'
#' @note See more infos at
#' \url{http://ab-initio.mit.edu/wiki/index.php/NLopt_Algorithms}.
#'
#' @seealso \code{alabama::auglag}, \code{Rsolnp::solnp},
#' \code{Rdonlp2::donlp2}
#'
#' @references Dieter Kraft, ``A software package for sequential quadratic
#' programming'', Technical Report DFVLR-FB 88-28, Institut fuer Dynamik der
#' Flugsysteme, Oberpfaffenhofen, July 1988.
#'
#' @examples
#'
#' ##  Solve the Hock-Schittkowski problem no. 100
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
#'
#' S <- slsqp(x0.hs100, fn = fn.hs100,     # no gradients and jacobians provided
#'            hin = hin.hs100,
#'            control = list(xtol_rel = 1e-8, check_derivatives = TRUE))
#' S
#' ## Optimal value of objective function:  690.622270249131   *** WRONG ***
#'
#' # Even the numerical derivatives seem to be too tight.
#' # Let's try with a less accurate jacobian.
#'
#' hinjac.hs100 <- function(x) nl.jacobian(x, hin.hs100, heps = 1e-2)
#' S <- slsqp(x0.hs100, fn = fn.hs100,
#'            hin = hin.hs100, hinjac = hinjac.hs100,
#'            control = list(xtol_rel = 1e-8))
#' S
#' ## Optimal value of objective function:  680.630057392593   *** CORRECT ***
#'
slsqp <- function(x0, fn, gr = NULL, lower = NULL, upper = NULL,
                     hin = NULL, hinjac = NULL, heq = NULL, heqjac = NULL,
                     nl.info = FALSE, control = list(), ...) {

    opts <- nl.opts(control)
    opts["algorithm"] <- "NLOPT_LD_SLSQP"

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
            message('For consistency with the rest of the package the inequality sign will be switched from >= to <= in the next nloptr version.')
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

    if (!is.null(heq)) {
        .heq <- match.fun(heq)
        heq <- function(x) .heq(x)
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
    S1 <- list(par = S0$solution, value = S0$objective, iter = S0$iterations,
                convergence = S0$status, message = S0$message)
    return(S1)
}
