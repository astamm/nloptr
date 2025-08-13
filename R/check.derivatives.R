# Copyright (C) 2011 Jelmer Ypma. All Rights Reserved.
# SPDX-License-Identifier: LGPL-3.0-or-later
#
# File:   check.derivatives.R
# Author: Jelmer Ypma
# Date:   24 July 2011
#
# Compare analytic derivatives wih finite difference approximations.
#
# Input:
#    .x : compare at this point
#    func : calculate finite difference approximation for the gradient of
#         this function
#    func_grad : function to calculate analytic gradients
#    check_derivatives_tol : show deviations larger than this value
#    (optional)
#    check_derivatives_print : print the values of the function (optional)
#    func_grad_name : name of function to show in output (optional)
#     ... : arguments that are passed to the user-defined function (func and
#       func_grad)
#
# Output: list with analytic gradients, finite difference approximations,
#     relative errors and a comparison of the relative errors to the
#     tolerance.
#
# CHANGELOG:
#   2013-10-27: Added relative_error and flag_derivative_warning to output list.
#   2014-05-05: Replaced cat by message, so messages can now be suppressed by
#         suppressMessages.
#   2023-02-09: Cleanup and tweaks for safety and efficiency (AA)

#' Check analytic gradients of a function using finite difference
#' approximations
#'
#' This function compares the analytic gradients of a function with a finite
#' difference approximation and prints the results of these checks.
#'
#' @param .x point at which the comparison is done.
#' @param func function to be evaluated.
#' @param func_grad function calculating the analytic gradients.
#' @param check_derivatives_tol option determining when differences between the
#' analytic gradient and its finite difference approximation are flagged as an
#' error.
#' @param check_derivatives_print option related to the amount of output. 'all'
#' means that all comparisons are shown, 'errors' only shows comparisons that
#' are flagged as an error, and 'none' shows the number of errors only.
#' @param func_grad_name option to change the name of the gradient function
#' that shows up in the output.
#' @param ...  further arguments passed to the functions func and func_grad.
#'
#' @return The return value contains a list with the analytic gradient, its
#' finite difference approximation, the relative errors, and vector comparing
#' the relative errors to the tolerance.
#'
#' @export
#'
#' @author Jelmer Ypma
#'
#' @seealso \code{\link[nloptr:nloptr]{nloptr}}
#'
#' @keywords optimize interface
#'
#' @examples
#'
#' library('nloptr')
#'
#' # example with correct gradient
#' f <- function(x, a) sum((x - a) ^ 2)
#'
#' f_grad <- function(x, a)  2 * (x - a)
#'
#' check.derivatives(.x = 1:10, func = f, func_grad = f_grad,
#'           check_derivatives_print = 'none', a = runif(10))
#'
#' # example with incorrect gradient
#' f_grad <- function(x, a)  2 * (x - a) + c(0, 0.1, rep(0, 8))
#'
#' check.derivatives(.x = 1:10, func = f, func_grad = f_grad,
#'           check_derivatives_print = 'errors', a = runif(10))
#'
#' # example with incorrect gradient of vector-valued function
#' g <- function(x, a) c(sum(x - a), sum((x - a) ^ 2))
#'
#' g_grad <- function(x, a) {
#'    rbind(rep(1, length(x)) + c(0, 0.01, rep(0, 8)),
#'    2 * (x - a) + c(0, 0.1, rep(0, 8)))
#' }
#'
#' check.derivatives(.x = 1:10, func = g, func_grad = g_grad,
#'           check_derivatives_print = 'all', a = runif(10))
#'
check.derivatives <- function(
  .x,
  func,
  func_grad,
  check_derivatives_tol = 1e-04,
  check_derivatives_print = "all",
  func_grad_name = "grad_f",
  ...
) {
  analytic_grad <- func_grad(.x, ...)

  finite_diff_grad <- finite.diff(func, .x, ...)

  relative_error <- ifelse(
    finite_diff_grad == 0,
    analytic_grad,
    abs(
      (analytic_grad - finite_diff_grad) /
        finite_diff_grad
    )
  )

  flag_derivative_warning <- relative_error > check_derivatives_tol

  if (!(check_derivatives_print %in% c("all", "errors", "none"))) {
    warning(
      "Value '",
      check_derivatives_print,
      "' for check_derivatives_print is unknown; use 'all' ",
      "(default), 'errors', or 'none'."
    )
    check_derivatives_print <- "none"
  }

  # determine indices of vector / matrix for printing
  # format indices with width, such that they are aligned vertically
  if (is.matrix(analytic_grad)) {
    indices <- paste(
      format(
        rep(seq_len(nrow(analytic_grad)), times = ncol(analytic_grad)),
        width = 1 + sum(nrow(analytic_grad) > 10^(1:10))
      ),
      format(
        rep(seq_len(ncol(analytic_grad)), each = nrow(analytic_grad)),
        width = 1 + sum(ncol(analytic_grad) > 10^(1:10))
      ),
      sep = ", "
    )
  } else {
    indices <- format(
      seq_along(analytic_grad),
      width = 1 + sum(length(analytic_grad)) > 10^(1:10)
    )
  }

  # Print results.
  message(
    "Derivative checker results: ",
    sum(flag_derivative_warning),
    " error(s) detected."
  )
  if (check_derivatives_print == "all") {
    message(
      "\n",
      paste0(
        ifelse(flag_derivative_warning, "*", " "),
        " ",
        func_grad_name,
        "[",
        indices,
        "] = ",
        format(analytic_grad, scientific = TRUE),
        " ~ ",
        format(finite_diff_grad, scientific = TRUE),
        "   [",
        format(relative_error, scientific = TRUE),
        "]",
        collapse = "\n"
      ),
      "\n\n"
    )
  } else if (check_derivatives_print == "errors") {
    if (sum(flag_derivative_warning) > 0) {
      message(
        "\n",
        paste0(
          ifelse(flag_derivative_warning[flag_derivative_warning], "*", " "),
          " ",
          func_grad_name,
          "[",
          indices[flag_derivative_warning],
          "] = ",
          format(analytic_grad[flag_derivative_warning], scientific = TRUE),
          " ~ ",
          format(finite_diff_grad[flag_derivative_warning], scientific = TRUE),
          "   [",
          format(relative_error[flag_derivative_warning], scientific = TRUE),
          "]",
          collapse = "\n"
        ),
        "\n\n"
      )
    }
  } else if (check_derivatives_print == "none") {}

  list(
    "analytic" = analytic_grad,
    "finite_difference" = finite_diff_grad,
    "relative_error" = relative_error,
    "flag_derivative_warning" = flag_derivative_warning
  )
}
