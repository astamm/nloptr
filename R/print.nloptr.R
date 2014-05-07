# Copyright (C) 2010 Jelmer Ypma. All Rights Reserved.
# This code is published under the L-GPL.
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
# 13/01/2011: added show.controls option
# 07/08/2011: show 'optimal value' instead of 'current value' if status == 1, 2, 3, or 4

print.nloptr <- function(x, show.controls=TRUE, ...) {
    cat( "\nCall:\n", deparse(x$call), "\n\n", sep = "", fill=TRUE )
    cat( paste( "Minimization using NLopt version", x$version, "\n" ), fill=TRUE )
    cat( unlist(strsplit(paste( "NLopt solver status:", x$status, "(", x$message, ")\n" ),' ')), fill=TRUE )
    cat( paste( "Number of Iterations....:", x$iterations, "\n" ) )
    cat( paste( "Termination conditions: ", x$termination_conditions, "\n" ) )
    cat( paste( "Number of inequality constraints: ", x$num_constraints_ineq, "\n" ) )
    cat( paste( "Number of equality constraints:   ", x$num_constraints_eq, "\n" ) )
    
    # if show.controls is TRUE or FALSE, show all or none of the controls
    if ( is.logical( show.controls ) ) {
        # show all control variables
        if ( show.controls ) {
            controls.indices = 1:length(x$solution)
        }
    }
    
    # if show.controls is a vector with indices, rename this vector
    # and define show.controls as TRUE
    if ( is.numeric( show.controls ) ) {
        controls.indices = show.controls
        show.controls = TRUE
    }
    
    # if solved successfully
    if ( x$status >= 1 & x$status <=4 ) {
        cat( paste( "Optimal value of objective function: ", x$objective, "\n" ) )
        if ( show.controls ) {
            if ( length( controls.indices ) < length(x$solution) ) {
                cat( "Optimal value of user-defined subset of controls: " )
            } else {
                cat( "Optimal value of controls: " )
            }
            cat( x$solution[ controls.indices ], fill=TRUE)
            cat("\n")
        }
    } else {
        cat( paste( "Current value of objective function: ", x$objective, "\n" ) )
        if ( show.controls ) {
            if ( length( controls.indices ) < length(x$solution) ) {
                cat( "Current value of user-defined subset of controls: " )
            } else {
                cat( "Current value of controls: " )
            }
            cat( x$solution[ controls.indices ], fill=TRUE )
            cat("\n")
        }
    }
    cat("\n")
}
