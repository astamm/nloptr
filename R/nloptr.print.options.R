# Copyright (C) 2011 Jelmer Ypma. All Rights Reserved.
# This code is published under the L-GPL.
#
# File:   nloptr.print.options.R
# Author: Jelmer Ypma
# Date:   8 August 2011
#
# Print list of all options with description.
#
# Input:     
#    opts.show:    the description of the options in this list are shown (optional, default is to show all options)
#    opts.user:    list with user defined options (optional)
# Output:     options, default values, user values if supplied) 
#             and description printed to screen. No return value.
#
# 08/08/2011: Added opts.show argument to only show a subset of all options.

nloptr.print.options <- 
function(
    opts.show=NULL,
    opts.user=NULL ) 
{
    # show all options if no list of options is supplied
    if ( is.null( opts.show ) ) {
        nloptr.show.options <- nloptr.get.default.options()
    } else {
        nloptr.show.options <- nloptr.get.default.options()
        nloptr.show.options <- nloptr.show.options[ nloptr.show.options$name %in% opts.show, ]
    }
    
    # loop over all options and print values
    for( row.cnt in 1:nrow( nloptr.show.options ) ) {
        opt <- nloptr.show.options[row.cnt,]
        
        value.current <- ifelse( 
                                is.null(opts.user[[opt$name]]), 
                                "(default)", 
                                opts.user[[opt$name]] 
                            )
        cat( opt$name, "\n", sep='' )
        cat( "\tpossible values: ", paste(strwrap(opt$possible_values, width=50), collapse="\n\t                 "), "\n", sep='' )
        cat( "\tdefault value:   ", opt$default, "\n", sep='' )
        if ( !is.null( opts.user ) ) {
            cat( "\tcurrent value:   ", value.current, "\n", sep='' )
        }
        cat( "\n\t", paste(strwrap(opt$description, width=70), collapse="\n\t"), "\n", sep='' )
        cat( "\n")
    }
}
