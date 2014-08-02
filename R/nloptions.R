# Copyright (C) 2014 Hans W. Borchers. All Rights Reserved.
# This code is published under the L-GPL.
#
# File:   nloptions.R
# Author: Hans W. Borchers
# Date:   27 January 2014
#
# Function to define nloptr options list.

nl.opts <-
function(optlist = NULL)
{
    opts <- list(stopval = -Inf,        # stop minimization at this value
                 xtol_rel = 1e-6,       # stop on small optimization step
                 maxeval = 1000,        # stop on this many function evaluations
                 ftol_rel = 0.0,        # stop on change times function value
                 ftol_abs = 0.0,        # stop on small change of function value
                 check_derivatives = FALSE,
                 algorithm = NULL       # will be filled by each single function
                )

    if (is.null(optlist))
        return(opts)

    if (!is.list(optlist) || "" %in% names(optlist))
        stop("Argument 'optlist' must be a list of named (character) objects.")

    namc <- match.arg(names(optlist), choices=names(opts), several.ok=TRUE)
    if (!all(names(optlist) %in% names(opts))) 
        warning("Unknown names in control: ", 
                names(optlist)[!(names(optlist) %in% names(opts))])

    if (!is.null(namc))
        opts[namc] <- optlist[namc]

    if ("algorithm" %in% namc) {
        warning("Option 'algorithm can not be set here; will be overwritten.")
        opts["algorithm"] <- NULL
    }

    return(opts)
}
