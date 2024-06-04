# Copyright (C) 2014 Hans W. Borchers. All Rights Reserved.
# SPDX-License-Identifier: LGPL-3.0-or-later
#
# File:   auglag.R
# Author: Hans W. Borchers
# Date:   27 January 2014
#
# Wrapper to solve optimization problem using Augmented Lagrangian.
#
# CHANGELOG
#
# 2017-09-26: Fixed bug, BOBYQA is allowed as local solver
#   (thanks to Leo Belzile).
# 2023-02-08: Tweaks for efficiency and readability (Avraham Adler)
# 2024-06-04: Switched desired direction of the hin/hinjac inequalities, leaving
#       the old behavior as the default for now (Avraham Adler).
#

#' Augmented Lagrangian Algorithm
#'
#' The Augmented Lagrangian method adds additional terms to the unconstrained
#' objective function, designed to emulate a Lagrangian multiplier.
#'
#' This method combines the objective function and the nonlinear
#' inequality/equality constraints (if any) in to a single function:
#' essentially, the objective plus a `penalty' for any violated constraints.
#'
#' This modified objective function is then passed to another optimization
#' algorithm with no nonlinear constraints. If the constraints are violated by
#' the solution of this sub-problem, then the size of the penalties is
#' increased and the process is repeated; eventually, the process must converge
#' to the desired solution (if it exists).
#'
#' Since all of the actual optimization is performed in this subsidiary
#' optimizer, the subsidiary algorithm that you specify determines whether the
#' optimization is gradient-based or derivative-free.
#'
#' The local solvers available at the moment are ``COBYLA'' (for the
#' derivative-free approach) and ``LBFGS'', ``MMA'', or ``SLSQP'' (for smooth
#' functions). The tolerance for the local solver has to be provided.
#'
#' There is a variant that only uses penalty functions for equality constraints
#' while inequality constraints are passed through to the subsidiary algorithm
#' to be handled directly; in this case, the subsidiary algorithm must handle
#' inequality constraints.  (At the moment, this variant has been turned off
#' because of problems with the NLOPT library.)
#'
#' @param x0 starting point for searching the optimum.
#' @param fn objective function that is to be minimized.
#' @param gr gradient of the objective function; will be provided provided is
#' \code{NULL} and the solver requires derivatives.
#' @param lower,upper lower and upper bound constraints.
#' @param hin,hinjac defines the inequality constraints, \code{hin(x) >= 0}
#' @param heq,heqjac defines the equality constraints, \code{heq(x) = 0}.
#' @param localsolver available local solvers: COBYLA, LBFGS, MMA, or SLSQP.
#' @param localtol tolerance applied in the selected local solver.
#' @param ineq2local logical; shall the inequality constraints be treated by
#' the local solver?; not possible at the moment.
#' @param nl.info logical; shall the original NLopt info been shown.
#' @param control list of options, see \code{nl.opts} for help.
#' @param deprecatedBehavior logical; if \code{TRUE} (default for now), the old
#' behavior of the Jacobian function is used, where the equality is \eqn{\ge 0}
#' instead of \eqn{\le 0}. This will be reversed in a future release and
#' eventually removed.
#' @param ... additional arguments passed to the function.
#'
#' @return List with components:
#'   \item{par}{the optimal solution found so far.}
#'   \item{value}{the function value corresponding to \code{par}.}
#'   \item{iter}{number of (outer) iterations, see \code{maxeval}.}
#'   \item{global_solver}{the global NLOPT solver used.}
#'   \item{local_solver}{the local NLOPT solver used, LBFGS or COBYLA.}
#'   \item{convergence}{integer code indicating successful completion
#'   (> 0) or a possible error number (< 0).}
#'   \item{message}{character string produced by NLopt and giving additional
#'    information.}
#'
#' @export
#'
#' @author Hans W. Borchers
#'
#' @note Birgin and Martinez provide their own free implementation of the
#' method as part of the TANGO project; other implementations can be found in
#' semi-free packages like LANCELOT.
#'
#' @seealso \code{alabama::auglag}, \code{Rsolnp::solnp}
#'
#' @references Andrew R. Conn, Nicholas I. M. Gould, and Philippe L. Toint, ``A
#' globally convergent augmented Lagrangian algorithm for optimization with
#' general constraints and simple bounds,'' SIAM J. Numer. Anal. vol. 28, no.
#' 2, p. 545-572 (1991).
#'
#' E. G. Birgin and J. M. Martinez, ``Improving ultimate convergence of an
#' augmented Lagrangian method," Optimization Methods and Software vol. 23, no.
#' 2, p. 177-195 (2008).
#'
#' @examples
#'
#' x0 <- c(1, 1)
#' fn <- function(x) (x[1] - 2) ^ 2 + (x[2] - 1) ^ 2
#' hin <- function(x) 0.25 * x[1]^2 + x[2] ^ 2 - 1  # hin <= 0
#' heq <- function(x) x[1] - 2 * x[2] + 1           # heq = 0
#' gr <- function(x) nl.grad(x, fn)
#' hinjac <- function(x) nl.jacobian(x, hin)
#' heqjac <- function(x) nl.jacobian(x, heq)
#'
#' # with COBYLA
#' auglag(x0, fn, gr = NULL, hin = hin, heq = heq, deprecatedBehavior = FALSE)
#'
#' # $par:   0.8228761 0.9114382
#' # $value:   1.393464
#' # $iter:  1001
#'
#' auglag(x0, fn, gr = NULL, hin = hin, heq = heq, localsolver = "SLSQP",
#'        deprecatedBehavior = FALSE)
#'
#' # $par:   0.8228757 0.9114378
#' # $value:   1.393465
#' # $iter   184
#'
#' ##  Example from the alabama::auglag help page
#' ##  Parameters should be roughly (0, 0, 1) with an objective value of 1.
#'
#' fn <- function(x) (x[1] + 3 * x[2] + x[3]) ^ 2 + 4 * (x[1] - x[2]) ^ 2
#' heq <- function(x) x[1] + x[2] + x[3] - 1
#' # hin restated from alabama example to be <= 0.
#' hin <- function(x) c(-6 * x[2] - 4 * x[3] + x[1] ^ 3 + 3, -x[1], -x[2], -x[3])
#'
#' set.seed(12)
#' auglag(runif(3), fn, hin = hin, heq = heq, localsolver= "lbfgs",
#'        deprecatedBehavior = FALSE)
#'
#' # $par:   4.861756e-08 4.732373e-08 9.999999e-01
#' # $value:   1
#' # $iter:  145
#'
#' ##  Powell problem from the Rsolnp::solnp help page
#' ##  Parameters should be roughly (-1.7171, 1.5957, 1.8272, -0.7636, -0.7636)
#' ##  with an objective value of 0.0539498478.
#'
#' x0 <- c(-2, 2, 2, -1, -1)
#' fn1  <- function(x) exp(x[1] * x[2] * x[3] * x[4] * x[5])
#' eqn1 <-function(x)
#' 	c(x[1] * x[1] + x[2] * x[2] + x[3] * x[3] + x[4] * x[4] + x[5] * x[5] - 10,
#' 	  x[2] * x[3] - 5 * x[4] * x[5],
#' 	  x[1] * x[1] * x[1] + x[2] * x[2] * x[2] + 1)
#'
#' auglag(x0, fn1, heq = eqn1, localsolver = "mma", deprecatedBehavior = FALSE)
#'
#' # $par: -1.7173645  1.5959655  1.8268352 -0.7636185 -0.7636185
#' # $value:   0.05394987
#' # $iter:  916
#'
auglag <- function(x0, fn, gr = NULL, lower = NULL, upper = NULL, hin = NULL,
                   hinjac = NULL, heq = NULL, heqjac = NULL,
                   localsolver = "COBYLA", localtol = 1e-6, ineq2local = FALSE,
                   nl.info = FALSE, control = list(), deprecatedBehavior = TRUE,
                   ...) {
  if (ineq2local) {
    # gsolver <- "NLOPT_LN_AUGLAG_EQ"
    stop("Inequalities to local solver: feature not yet implemented.")
  }

  localsolver <- toupper(localsolver)
  if (localsolver %in% c("COBYLA", "BOBYQA")) {   # derivative-free
    dfree <- TRUE
    gsolver <- "NLOPT_LN_AUGLAG"
    lsolver <- paste0("NLOPT_LN_", localsolver)
  } else if (localsolver %in% c("LBFGS", "MMA", "SLSQP")) { # with derivatives
    dfree <- FALSE
    gsolver <- "NLOPT_LD_AUGLAG"
    lsolver <- paste0("NLOPT_LD_", localsolver)
  } else {
    stop("Only local solvers allowed: BOBYQA, COBYLA, LBFGS, MMA, SLSQP.")
  }

  # Function and gradient, if needed
  .fn <- match.fun(fn)
  fn  <- function(x) .fn(x, ...)

  if (!dfree && is.null(gr)) {gr <- function(x) nl.grad(x, fn)}

  # Global and local options
  opts <- nl.opts(control)
  opts$algorithm <- gsolver
  local_opts <- list(algorithm = lsolver,
                     xtol_rel = localtol,
                     eval_grad_f = if (!dfree) gr else NULL)
  opts$local_opts <- local_opts

  # Inequality constraints
  if (!is.null(hin)) {
    if (deprecatedBehavior) {
      message("The old behavior for hin >= 0 has been deprecated. Please ",
              "restate the inequality to be <=0. The ability to use the old ",
              "behavior will be removed in a future release.")
      .hin <- match.fun(hin)
      hin <- function(x) -.hin(x)      # change  hin >= 0  to  hin <= 0 !
    }
  }
  if (!dfree) {
    if (is.null(hinjac)) {
      hinjac <- function(x) nl.jacobian(x, hin)
    } else if (deprecatedBehavior) {
      message("The old behavior for hin >= 0 has been deprecated. Please ",
              "restate the inequality to be <=0. The ability to use the old",
              "behavior will be removed in a future release.")
      .hinjac <- match.fun(hinjac)
      hinjac <- function(x) -.hinjac(x)
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
  list(par = S0$solution, value = S0$objective, iter = S0$iterations,
       global_solver = gsolver, local_solver = lsolver, convergence = S0$status,
       message = S0$message)
}
