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

print.nloptr <- function(x, ...) {
	cat( "\nCall:\n", deparse(x$call), "\n\n", sep = "", fill=TRUE )
	cat( paste( "Minimization using NLopt version", x$version, "\n" ), fill=TRUE )
	cat( unlist(strsplit(paste( "NLopt solver status:", x$status, "(", x$message, ")\n" ),' ')), fill=TRUE )
	cat( paste( "Number of Iterations....:", x$iterations, "\n" ) )
	cat( paste( "Termination conditions: ", x$termination_conditions, "\n" ) )
    cat( paste( "Number of inequality constraints: ", x$num_constraints_ineq, "\n" ) )
    cat( paste( "Number of equality constraints:   ", x$num_constraints_eq, "\n" ) )
    
	# if solved successfully
	if ( x$status<=0 ) {
		cat( paste( "Optimal value of objective function: ", x$objective, "\n" ) )
		cat( "Optimal value of controls: " )
        cat( x$solution, fill=TRUE )
        cat("\n")
	} else {
		cat( paste( "Current value of objective function: ", x$objective, "\n" ) )
		cat( "Current value of controls: " )
        cat( x$solution, fill=TRUE )
        cat("\n")
    }
	cat("\n")
}
