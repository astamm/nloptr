# Copyright (C) 2014 Hans W. Borchers. All Rights Reserved.
# SPDX-License-Identifier: LGPL-3.0-or-later
#
# File:   lbfgs.R
# Author: Hans W. Borchers
# Date:   27 January 2014
#
# Wrapper to solve optimization problem using Low-storage BFGS.
#
# CHANGELOG
#
# 2023-02-09: Cleanup and tweaks for safety and efficiency (Avraham Adler)
#


#' Low-storage BFGS
#'
#' Low-storage version of the Broyden-Fletcher-Goldfarb-Shanno (BFGS) method.
#'
#' The low-storage (or limited-memory) algorithm is a member of the class of
#' quasi-Newton optimization methods. It is well suited for optimization
#' problems with a large number of variables.
#'
#' One parameter of this algorithm is the number \code{m} of gradients to
#' remember from previous optimization steps. NLopt sets \code{m} to a
#' heuristic value by default. It can be changed by the NLopt function
#' \code{set_vector_storage}.
#'
#' @param x0 initial point for searching the optimum.
#' @param fn objective function to be minimized.
#' @param gr gradient of function \code{fn}; will be calculated numerically if
#' not specified.
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
#'   or a possible error number (< 0).}
#'   \item{message}{character string produced by NLopt and giving additional
#'   information.}
#'
#' @export lbfgs
#'
#' @author Hans W. Borchers
#'
#' @note Based on a Fortran implementation of the low-storage BFGS algorithm
#' written by L. Luksan, and posted under the GNU LGPL license.
#'
#' @seealso \code{\link{optim}}
#'
#' @references J. Nocedal, ``Updating quasi-Newton matrices with limited
#' storage,'' Math. Comput. 35, 773-782 (1980).
#'
#' D. C. Liu and J. Nocedal, ``On the limited memory BFGS method for large
#' scale optimization,'' Math. Programming 45, p. 503-528 (1989).
#'
#' @examples
#'
#' flb <- function(x) {
#'   p <- length(x)
#'   sum(c(1, rep(4, p-1)) * (x - c(1, x[-p])^2)^2)
#' }
#' # 25-dimensional box constrained: par[24] is *not* at the boundary
#' S <- lbfgs(rep(3, 25), flb, lower=rep(2, 25), upper=rep(4, 25),
#'      nl.info = TRUE, control = list(xtol_rel=1e-8))
#' ## Optimal value of objective function:  368.105912874334
#' ## Optimal value of controls: 2  ...  2  2.109093  4
#'
lbfgs <- function(x0, fn, gr = NULL, lower = NULL, upper = NULL,
                  nl.info = FALSE, control = list(), ...) {

  opts <- nl.opts(control)
  opts["algorithm"] <- "NLOPT_LD_LBFGS"

  fun <- match.fun(fn)
  fn  <- function(x) fun(x, ...)

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
