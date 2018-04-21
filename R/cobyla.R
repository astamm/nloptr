# Copyright (C) 2014 Hans W. Borchers. All Rights Reserved.
# This code is published under the L-GPL.
#
# File:   cobyla.R
# Author: Hans W. Borchers
# Date:   27 January 2014
#
# Wrapper to solve optimization problem using COBYLA, BOBYQA, and NEWUOA.



#' Constrained Optimization by Linear Approximations
#'
#' COBYLA is an algorithm for derivative-free optimization with nonlinear
#' inequality and equality constraints (but see below).
#'
#' It constructs successive linear approximations of the objective function and
#' constraints via a simplex of n+1 points (in n dimensions), and optimizes
#' these approximations in a trust region at each step.
#'
#' COBYLA supports equality constraints by transforming them into two
#' inequality constraints. As this does not give full satisfaction with the
#' implementation in NLOPT, it has not been made available here.
#'
#' @param x0 starting point for searching the optimum.
#' @param fn objective function that is to be minimized.
#' @param lower,upper lower and upper bound constraints.
#' @param hin function defining the inequality constraints, that is
#' \code{hin>=0} for all components.
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
#' @author Hans W. Borchers
#'
#' @note The original code, written in Fortran by Powell, was converted in C
#' for the Scipy project.
#'
#' @seealso \code{\link{bobyqa}}, \code{\link{newuoa}}
#'
#' @references M. J. D. Powell, ``A direct search optimization method that
#' models the objective and constraint functions by linear interpolation,'' in
#' Advances in Optimization and Numerical Analysis, eds. S. Gomez and J.-P.
#' Hennart (Kluwer Academic: Dordrecht, 1994), p. 51-67.
#'
#' @examples
#'
#' ### Solve Hock-Schittkowski no. 100
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
#' S <- cobyla(x0.hs100, fn.hs100, hin = hin.hs100,
#'             nl.info = TRUE, control = list(xtol_rel = 1e-8, maxeval = 2000))
#' ## Optimal value of objective function:  680.630057374431
#'
#' @export cobyla
cobyla <-
function(x0, fn, lower = NULL, upper = NULL, hin = NULL,
            nl.info = FALSE, control = list(), ...)
{
    opts <- nl.opts(control)
    opts["algorithm"] <- "NLOPT_LN_COBYLA"

    f1 <- match.fun(fn)
    fn <- function(x) f1(x, ...)

    if (!is.null(hin)) {
        if ( getOption('nloptr.show.inequality.warning') ) {
            message('For consistency with the rest of the package the inequality sign will be switched from >= to <= in the next nloptr version.')
        }

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




#' Bound Optimization by Quadratic Approximation
#'
#' BOBYQA performs derivative-free bound-constrained optimization using an
#' iteratively constructed quadratic approximation for the objective function.
#'
#' This is an algorithm derived from the BOBYQA Fortran subroutine of Powell,
#' converted to C and modified for the NLOPT stopping criteria.
#'
#' @param x0 starting point for searching the optimum.
#' @param fn objective function that is to be minimized.
#' @param lower,upper lower and upper bound constraints.
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
#' @export bobyqa
#'
#' @note Because BOBYQA constructs a quadratic approximation of the objective,
#' it may perform poorly for objective functions that are not
#' twice-differentiable.
#'
#' @seealso \code{\link{cobyla}}, \code{\link{newuoa}}
#'
#' @references M. J. D. Powell. ``The BOBYQA algorithm for bound constrained
#' optimization without derivatives,'' Department of Applied Mathematics and
#' Theoretical Physics, Cambridge England, technical reportNA2009/06 (2009).
#'
#' @examples
#'
#' fr <- function(x) {   ## Rosenbrock Banana function
#'     100 * (x[2] - x[1]^2)^2 + (1 - x[1])^2
#' }
#' (S <- bobyqa(c(0, 0, 0), fr, lower = c(0, 0, 0), upper = c(0.5, 0.5, 0.5)))
#'
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




#' New Unconstrained Optimization with quadratic Approximation
#'
#' NEWUOA solves quadratic subproblems in a spherical trust regionvia a
#' truncated conjugate-gradient algorithm. For bound-constrained problems,
#' BOBYQA shold be used instead, as Powell developed it as an enhancement
#' thereof for bound constraints.
#'
#' This is an algorithm derived from the NEWUOA Fortran subroutine of Powell,
#' converted to C and modified for the NLOPT stopping criteria.
#'
#' @param x0 starting point for searching the optimum.
#' @param fn objective function that is to be minimized.
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
#' @export newuoa
#'
#' @author Hans W. Borchers
#'
#' @note NEWUOA may be largely superseded by BOBYQA.
#'
#' @seealso \code{\link{bobyqa}}, \code{\link{cobyla}}
#'
#' @references M. J. D. Powell. ``The BOBYQA algorithm for bound constrained
#' optimization without derivatives,'' Department of Applied Mathematics and
#' Theoretical Physics, Cambridge England, technical reportNA2009/06 (2009).
#'
#' @examples
#'
#' fr <- function(x) {   ## Rosenbrock Banana function
#'     100 * (x[2] - x[1]^2)^2 + (1 - x[1])^2
#' }
#' (S <- newuoa(c(1, 2), fr))
#'
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
