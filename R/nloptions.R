# Copyright (C) 2014 Hans W. Borchers. All Rights Reserved.
# This code is published under the L-GPL.
#
# File:   nloptions.R
# Author: Hans W. Borchers
# Date:   27 January 2014
#
# Function to define nloptr options list.

#' Setting NL Options
#'
#' Sets and changes the NLOPT options.
#'
#' The following options can be set (here with default values):
#'
#' \code{stopval = -Inf, # stop minimization at this value}\cr \code{xtol_rel =
#' 1e-6, # stop on small optimization step}\cr \code{maxeval = 1000, # stop on
#' this many function evaluations}\cr \code{ftol_rel = 0.0, # stop on change
#' times function value}\cr \code{ftol_abs = 0.0, # stop on small change of
#' function value}\cr \code{check_derivatives = FALSE}
#'
#' @param optlist list of options, see below.
#'
#' @return returns a list with default and changed options.
#'
#' @export
#'
#' @author Hans W. Borchers
#'
#' @note There are more options that can be set for solvers in NLOPT. These
#' cannot be set through their wrapper functions. To see the full list of
#' options and algorithms, type \code{nloptr.print.options()}.
#'
#' @examples
#'
#' nl.opts(list(xtol_rel = 1e-8, maxeval = 2000))
#'
nl.opts <- function(optlist = NULL) {
  opts <- list(
    stopval = -Inf,            # stop minimization at this value
    xtol_rel = 1e-6,           # stop on small optimization step
    maxeval = 1000,            # stop on this many function evaluations
    ftol_rel = 0.0,            # stop on change times function value
    ftol_abs = 0.0,            # stop on small change of function value
    check_derivatives = FALSE,
    algorithm = NULL           # will be filled by each single function
  )

  if (is.null(optlist)) return(opts)

  if (!is.list(optlist) || "" %in% names(optlist))
    stop("Argument `optlist` must be a named list.")

  for (option_name in names(optlist))
    opts[[option_name]] <- optlist[[option_name]]

  if ("algorithm" %in% names(opts)) {
    warning(
      "Option `algorithm` cannot be set here. It will be overwritten."
    )
    opts[["algorithm"]] <- NULL
  }

  opts
}
