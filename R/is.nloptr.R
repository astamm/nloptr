# Copyright (C) 2010 Jelmer Ypma. All Rights Reserved.
# SPDX-License-Identifier: LGPL-3.0-or-later
#
# File:   is.nloptr.R
# Author: Jelmer Ypma
# Date:   10 June 2010
#
# Input: object
# Output: bool telling whether the object is an nloptr or not
#
# CHANGELOG
#   2011-06-16: separated local optimizer check and equality constraints check
#   2014-05-05: Replaced cat by warning.
#   2023-02-08: Tweaks for efficiency and readability (Avraham Adler)
#


#' R interface to NLopt
#'
#' is.nloptr preforms checks to see if a fully specified problem is supplied to
#' nloptr. Mostly for internal use.
#'
#' @param x object to be tested.
#'
#' @return Logical. Return TRUE if all tests were passed, otherwise return
#' FALSE or exit with Error.
#'
#' @export is.nloptr
#'
#' @author Jelmer Ypma
#'
#' @seealso \code{\link[nloptr:nloptr]{nloptr}}
#'
#' @keywords optimize interface

is.nloptr <- function(x) {

  # Check whether the object exists and is a list
  if (is.null(x)) return(FALSE) # Proper use of return to break out early :)
  if (!is.list(x)) return(FALSE)

  # Helper values now that we are certain x is a list
  lx0 <- length(x$x0)

  # Check whether the needed wrapper functions are supplied
  if (!is.function(x$eval_f)) stop("eval_f is not a function")
  if (!is.null(x$eval_g_ineq) && !is.function(x$eval_g_ineq))
    stop("eval_g_ineq is not a function")

  if (!is.null(x$eval_g_eq) && !is.function(x$eval_g_eq))
    stop("eval_g_eq is not a function")


  # Check whether bounds are defined for all controls
  if (anyNA(x$x0)) stop("x0 contains NA")
  if (lx0  != length(x$lower_bounds)) stop("length(lb) != length(x0)")
  if (lx0  != length(x$upper_bounds)) stop("length(ub) != length(x0)")

  # Check whether the initial value is within the bounds
  if (any(x$x0 < x$lower_bounds)) {stop("at least one element in x0 < lb")}
  if (any(x$x0 > x$upper_bounds)) {stop("at least one element in x0 > ub")}


  # define list with all algorithms
  list_algorithms <- c(
    "NLOPT_GN_DIRECT", "NLOPT_GN_DIRECT_L", "NLOPT_GN_DIRECT_L_RAND",
    "NLOPT_GN_DIRECT_NOSCAL", "NLOPT_GN_DIRECT_L_NOSCAL",
    "NLOPT_GN_DIRECT_L_RAND_NOSCAL", "NLOPT_GN_ORIG_DIRECT",
    "NLOPT_GN_ORIG_DIRECT_L", "NLOPT_GD_STOGO", "NLOPT_GD_STOGO_RAND",
    "NLOPT_LD_SLSQP", "NLOPT_LD_LBFGS_NOCEDAL", "NLOPT_LD_LBFGS",
    "NLOPT_LN_PRAXIS", "NLOPT_LD_VAR1", "NLOPT_LD_VAR2", "NLOPT_LD_TNEWTON",
    "NLOPT_LD_TNEWTON_RESTART", "NLOPT_LD_TNEWTON_PRECOND",
    "NLOPT_LD_TNEWTON_PRECOND_RESTART", "NLOPT_GN_CRS2_LM", "NLOPT_GN_MLSL",
    "NLOPT_GD_MLSL", "NLOPT_GN_MLSL_LDS", "NLOPT_GD_MLSL_LDS", "NLOPT_LD_MMA",
    "NLOPT_LD_CCSAQ", "NLOPT_LN_COBYLA", "NLOPT_LN_NEWUOA",
    "NLOPT_LN_NEWUOA_BOUND", "NLOPT_LN_NELDERMEAD", "NLOPT_LN_SBPLX",
    "NLOPT_LN_AUGLAG", "NLOPT_LD_AUGLAG", "NLOPT_LN_AUGLAG_EQ",
    "NLOPT_LD_AUGLAG_EQ", "NLOPT_LN_BOBYQA", "NLOPT_GN_ISRES", "NLOPT_GN_ESCH"
  )

  # check if an existing algorithm was supplied
  if (!(x$options$algorithm %in% list_algorithms)) {
    stop("Incorrect algorithm supplied. Use one of the following:\n",
         paste(list_algorithms, collapse = "\n"))
  }

  # determine subset of algorithms that need a derivative
  list_algorithms_d <- list_algorithms[grep("NLOPT_[G,L]D", list_algorithms)]
  list_algorithms_n <- list_algorithms[grep("NLOPT_[G,L]N", list_algorithms)]

  # Check the whether we don't have NA's if we evaluate the objective function
  # in x0
  f0 <- x$eval_f(x$x0)
  if (is.list(f0)) {
    if (is.na(f0$objective)) stop("objective in x0 returns NA")
    if (anyNA(f0$gradient)) stop("gradient of objective in x0 returns NA")
    if (length(f0$gradient) != lx0) {
      stop("wrong number of elements in gradient of objective")
    }

    # check whether algorithm needs a derivative
    if (x$options$algorithm %in%   list_algorithms_n) {
      warning("a gradient was supplied for the objective function, ",
              "but algorithm ", x$options$algorithm, " does not use gradients.")
    }
  } else {
    if (anyNA(f0)) stop("objective in x0 returns NA")

    # check whether algorithm needs a derivative
    if (x$options$algorithm %in%   list_algorithms_d) {
      stop("A gradient for the objective function is needed by ",
           "algorithm ", x$options$algorithm, " but was not supplied.\n")
    }
  }

  # Check the whether we don't have NA's if we evaluate the inequality
  # constraints in x0
  if (!is.null(x$eval_g_ineq)) {
    g0_ineq <- x$eval_g_ineq(x$x0)
    if (is.list(g0_ineq)) {
      if (anyNA(g0_ineq$constraints)) {
        stop("inequality constraints in x0 returns NA")
      }
      if (anyNA(g0_ineq$jacobian)) {
        stop("jacobian of inequality constraints in x0 returns NA")
      }
      if (length(g0_ineq$jacobian) != length(g0_ineq$constraints) * lx0) {
        stop("wrong number of elements in jacobian of inequality ",
             "constraints (is ", length(g0_ineq$jacobian),
             ", but should be ", length(g0_ineq$constraints), " x ",
             lx0, " = ", length(g0_ineq$constraints) * lx0, ")")
      }

      # check whether algorithm needs a derivative
      if (x$options$algorithm %in%   list_algorithms_n) {
        warning("a gradient was supplied for the inequality ",
                "constraints, but algorithm ", x$options$algorithm,
                " does not use gradients.")
      }
    } else {
      if (anyNA(g0_ineq)) stop("inequality constraints in x0 returns NA")

      # check whether algorithm needs a derivative
      if (x$options$algorithm %in%   list_algorithms_d) {
        stop("A gradient for the inequality constraints is needed by ",
             "algorithm ", x$options$algorithm, " but was not supplied.\n")
      }
    }
  }

  # Check the whether we don"t have NA"s if we evaluate the equality
  # constraints in x0
  if (!is.null(x$eval_g_eq)) {
    g0_eq <- x$eval_g_eq(x$x0)
    if (is.list(g0_eq)) {
      if (anyNA(g0_eq$constraints)) {
        stop("equality constraints in x0 returns NA")
      }
      if (anyNA(g0_eq$jacobian)) {
        stop("jacobian of equality constraints in x0 returns NA")
      }
      if (length(g0_eq$jacobian) != length(g0_eq$constraints) * lx0) {
        stop("wrong number of elements in jacobian of equality ",
             "constraints (is ", length(g0_eq$jacobian),
             ", but should be ", length(g0_eq$constraints), " x ", lx0,
             " = ", length(g0_eq$constraints) * lx0, ")")
      }

      # check whether algorithm needs a derivative
      if (x$options$algorithm %in%   list_algorithms_n) {
        warning("a gradient was supplied for the equality ",
                "constraints, but algorithm ", x$options$algorithm,
                " does not use gradients.")
      }
    } else {
      if (anyNA(g0_eq)) stop("equality constraints in x0 returns NA")

      # check whether algorithm needs a derivative
      if (x$options$algorithm %in%   list_algorithms_d) {
        stop("A gradient for the equality constraints is needed by ",
             "algorithm ", x$options$algorithm, " but was not supplied.\n")
      }
    }
  }

  # check if we have a correct algorithm for the equality constraints
  if (x$num_constraints_eq > 0) {
    eq_algorithms <- c("NLOPT_LD_AUGLAG",
                       "NLOPT_LN_AUGLAG",
                       "NLOPT_LD_AUGLAG_EQ",
                       "NLOPT_LN_AUGLAG_EQ",
                       "NLOPT_GN_ISRES",
                       "NLOPT_LD_SLSQP")
    if (!(x$options$algorithm %in% eq_algorithms)) {
      stop("If you want to use equality constraints, ",
           "then you should use one of these algorithms ",
           toString(eq_algorithms))
    }
  }

  # check if a local optimizer was supplied, which is needed by some algorithms
  if (x$options$algorithm %in% c("NLOPT_LD_AUGLAG",
                                 "NLOPT_LN_AUGLAG",
                                 "NLOPT_LD_AUGLAG_EQ",
                                 "NLOPT_LN_AUGLAG_EQ",
                                 "NLOPT_GN_MLSL",
                                 "NLOPT_GD_MLSL",
                                 "NLOPT_GN_MLSL_LDS",
                                 "NLOPT_GD_MLSL_LDS") &&
        is.null(x$local_options)) {
    stop("The algorithm ", x$options$algorithm, " needs a local ",
         "optimizer; specify an algorithm and termination condition in ",
         "local_opts")
  }

  # Check if the vector with tolerances for the inequality constraints is of
  # the same size as the number of constraints.
  if (x$num_constraints_ineq != length(x$options$tol_constraints_ineq)) {
    stop("The vector tol_constraints_ineq in the options list has size ",
         length(x$options$tol_constraints_ineq),
         " which is unequal to the number of inequality constraints, ",
         x$num_constraints_ineq, ".")
  }

  # Check if the vector with tolerances for the equality constraints is of the
  # same size as the number of constraints.
  if (x$num_constraints_eq != length(x$options$tol_constraints_eq)) {
    stop("The vector tol_constraints_eq in the options list has size ",
         length(x$options$tol_constraints_eq),
         " which is unequal to the number of equality constraints, ",
         x$num_constraints_eq, ".")
  }

  TRUE
}
