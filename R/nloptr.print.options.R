# Copyright (C) 2011 Jelmer Ypma. All Rights Reserved.
# This code is published under the L-GPL.
#
# File:   nloptr.print.options.R
# Author: Jelmer Ypma
# Date:   7 August 2011
#
# Print list of all options with description.
#
# Input: 	list with user defined options (optional)
# Output: 	options, default values, user values if supplied) 
# 			and description	printed to screen. No return value.

nloptr.print.options <- 
function( 
	opts.user=NULL ) 
{
	for( row.cnt in 1:nrow( nloptr.default.options ) ) {
		opt <- nloptr.default.options[row.cnt,]
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
