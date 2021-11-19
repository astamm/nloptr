# Copyright (C) 2011 Jelmer Ypma. All Rights Reserved.
# This code is published under the L-GPL.
#
# File:   nloptr.add.default.options.R
# Author: Jelmer Ypma
# Date:   17 August 2016
#
# Add default options to a user supplied list of options.
#
# Input:
#    opts.user:                list with user defined options
#    x0:                       initial value for control variables
#    num_constraints_ineq:     number of inequality constraints
#    num_constraints_eq:       number of equality constraints
#
# Output:
#    opts.user with default options added for those options
#              that were not part of the original opts.user.
#
# Changelog:
#   17-08-2016: Fixed bug that sometimes caused segmentation faults
#               due to uninitialized tolerances for the (in)equality
#               constraints (thanks to Florian Schwendiger).

nloptr.add.default.options <-
function(
    opts.user,
    x0=0,
    num_constraints_ineq=0,
    num_constraints_eq=0 )
{
    nloptr.default.options <- nloptr.get.default.options()
    rownames(nloptr.default.options) <- nloptr.default.options[,"name"]

    # get names of options that define a termination condition
    termination.opts <-
        nloptr.default.options[ nloptr.default.options$is_termination_condition==TRUE, "name" ]

    if ( sum(termination.opts %in% names( opts.user )) == 0 ) {
        # get default xtol_rel
        xtol_rel_default <-
            as.numeric( nloptr.default.options[ nloptr.default.options$name=="xtol_rel", "default" ] )
        warning( paste("No termination criterium specified, using default (relative x-tolerance = ", xtol_rel_default, ")", sep='') )
        termination_conditions <- paste("relative x-tolerance = ", xtol_rel_default, " (DEFAULT)", sep='')
    } else {
        conv_options <- unlist(opts.user[names(opts.user) %in% termination.opts])
        termination_conditions <- paste( paste( names(conv_options) ), ": ", paste( conv_options ), sep='', collapse='\t' )
    }

    # determine list with names of options that contain character values.
    # we need to add quotes around these options below.
    nloptr.list.character.options <-
        nloptr.default.options[ nloptr.default.options$type=="character", "name" ]

    opts <- vector(mode="list", nrow(nloptr.default.options))
    names(opts) <- nloptr.default.options[,"name"]

    for ( name in names(opts) ) {
        if ( !is.null(opts.user[[name]]) ) {
            opts[[name]] <- opts.user[[name]]
        } else if ( name %in% nloptr.list.character.options ) {
            opts[[name]] <- nloptr.default.options[name, "default"]
        } else {
            opts[[name]] <- eval(parse(text=nloptr.default.options[name, "default"]))
        }
    }

    return(
        list( "opts.user" = opts,
              "termination_conditions" = termination_conditions
        )
    )
}
