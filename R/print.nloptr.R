# Copyright (C) 2010 Jelmer Ypma. All Rights Reserved.
# SPDX-License-Identifier: LGPL-3.0-or-later
#
# File:   print.nloptr.R
# Author: Jelmer Ypma
# Date:   10 June 2010
#
# This function prints some basic output of a nloptr
# ojbect. The information is only available after it
# has been solved.
#
# show.controls is TRUE, FALSE or a vector of indices.
# Use this option to show none, or only a subset of
# the controls.
#
# 2011-01-13: added show.controls option
# 2011-08-07: show 'optimal value' instead of 'current value'
#             if status == 1, 2, 3, or 4
# 2023-02-09: Cleanup and tweaks for safety and efficiency (Avraham Adler)


#' Print results after running nloptr
#'
#' This function prints the nloptr object that holds the results from a
#' minimization using \code{nloptr}.
#'
#' @param x object containing result from minimization.
#' @param show.controls Logical or vector with indices. Should we show the value
#'   of the control variables in the solution? If \code{show.controls} is a
#'   vector with indices, it is used to select which control variables should be
#'   shown. This can be useful if the model contains a set of parameters of
#'   interest and a set of nuisance parameters that are not of immediate
#'   interest.
#' @param ...  further arguments passed to or from other methods.
#'
#' @method print nloptr
#' @export
#'
#' @author Jelmer Ypma
#'
#' @seealso \code{\link[nloptr:nloptr]{nloptr}}
#'
#' @keywords optimize interface
#'
print.nloptr <- function(x, show.controls = TRUE, ...) {
    cat("\nCall:\n", deparse(x$call), "\n\n", sep = "", fill = TRUE)
    cat(paste("Minimization using NLopt version", x$version, "\n"), fill = TRUE)
    cat(unlist(strsplit(paste("NLopt solver status:", x$status, "(",
                              x$message, ")\n"),
                        " ", fixed = TRUE)), fill = TRUE)
    cat(paste("Number of Iterations....:", x$iterations, "\n"))
    cat(paste("Termination conditions: ", x$termination_conditions, "\n"))
    cat(paste("Number of inequality constraints: ", x$num_constraints_ineq, "\n"))
    cat(paste("Number of equality constraints:   ", x$num_constraints_eq, "\n"))

    # if show.controls is TRUE or FALSE, show all or none of the controls
    if (is.logical(show.controls)) {
        # show all control variables
        if (show.controls) controls.indices <- seq_along(x$solution)
    }

    # if show.controls is a vector with indices, rename this vector
    # and define show.controls as TRUE
    if (is.numeric(show.controls)) {
        controls.indices <- show.controls
        show.controls <- TRUE
    }

    # if solved successfully
    if (x$status >= 1 && x$status <= 4) {
        cat(paste("Optimal value of objective function: ", x$objective, "\n"))
        if (show.controls) {
            if (length(controls.indices) < length(x$solution)) {
                cat("Optimal value of user-defined subset of controls: ")
            } else {
                cat("Optimal value of controls: ")
            }
            cat(x$solution[controls.indices], fill = TRUE)
            cat("\n")
        }
    } else {
        cat(paste("Current value of objective function: ", x$objective, "\n"))
        if (show.controls) {
            if (length(controls.indices) < length(x$solution)) {
                cat("Current value of user-defined subset of controls: ")
            } else {
                cat("Current value of controls: ")
            }
            cat(x$solution[controls.indices], fill = TRUE)
            cat("\n")
        }
    }
    cat("\n")
}
