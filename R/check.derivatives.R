# Copyright (C) 2011 Jelmer Ypma. All Rights Reserved.
# This code is published under the L-GPL.
#
# File:   check.derivatives.R
# Author: Jelmer Ypma
# Date:   24 July 2011
#
# Compare analytic derivatives wih finite difference approximations.
#
# Input: 
#        .x : compare at this point
#        func : calculate finite difference approximation for the gradient of this function
#        func_grad : function to calculate analytic gradients
#        check_derivatives_tol : show deviations larger than this value (optional)
#        check_derivatives_print : print the values of the function (optional)
#        func_grad_name : name of function to show in output (optional)
#       ... : arguments that are passed to the user-defined function (func and func_grad)
#
# Output: list with analytic gradients, finite difference approximations, relative errors
#         and a comparison of the relative errors to the tolerance.
#
# CHANGELOG:
#   27/10/2013: Added relative_error and flag_derivative_warning to output list.
#   05/05/2014: Replaced cat by message, so messages can now be suppressed by suppressMessages.

check.derivatives <- 
    function( 
        .x, 
        func, 
        func_grad, 
        check_derivatives_tol = 1e-04, 
        check_derivatives_print = 'all', 
        func_grad_name = 'grad_f', 
        ... 
    ) 
{

    analytic_grad <- func_grad( .x, ... )
    
    finite_diff_grad <- finite.diff( func, .x, ... )
    
    relative_error <- ifelse( 
                        finite_diff_grad == 0, 
                        analytic_grad, 
                        abs( ( analytic_grad - finite_diff_grad ) / finite_diff_grad )
                      )
    
    flag_derivative_warning <- relative_error > check_derivatives_tol
    
    if ( ! ( check_derivatives_print %in% c('all','errors','none') ) ) {
        warning( paste( "Value '", check_derivatives_print, "' for check_derivatives_print is unknown; use 'all' (default), 'errors', or 'none'.", sep='' ) )
        check_derivatives_print <- 'none'
    }
    
    # determine indices of vector / matrix for printing
    # format indices with width, such that they are aligned vertically
    if ( is.matrix( analytic_grad ) ) {
        indices <- paste( 
                    format( rep( 1:nrow(analytic_grad), times=ncol(analytic_grad) ), width=1 + sum( nrow(analytic_grad) > 10^(1:10) ) ), 
                    format( rep( 1:ncol(analytic_grad), each=nrow(analytic_grad) ), width=1 + sum( ncol(analytic_grad) > 10^(1:10) ) ), 
                    sep=', '
                   )
    }
    else {
        indices <- format( 1:length(analytic_grad), width=1 + sum( length(analytic_grad) > 10^(1:10) ) )
    }
        
    # Print results.
    message( "Derivative checker results: ", sum( flag_derivative_warning ), " error(s) detected." )
    if ( check_derivatives_print == 'all' ) {
        
        message( "\n",
            paste( 
                ifelse( flag_derivative_warning, "*"," "), 
                " ", func_grad_name, "[ ", indices, " ] = ", 
                format(analytic_grad, scientific=TRUE), 
                " ~ ", 
                format(finite_diff_grad, scientific=TRUE), 
                "   [", 
                format( relative_error, scientific=TRUE), 
                "]", sep='', collapse="\n"
            ), 
            "\n\n"
        )
    }
    else if ( check_derivatives_print == 'errors' ) {
        if ( sum( flag_derivative_warning ) > 0 ) {
            message( "\n",
                paste( 
                    ifelse( flag_derivative_warning[ flag_derivative_warning ], "*"," "), 
                    " ", func_grad_name, "[ ", indices[ flag_derivative_warning ], " ] = ", 
                    format(analytic_grad[ flag_derivative_warning ], scientific=TRUE), 
                    " ~ ", 
                    format(finite_diff_grad[ flag_derivative_warning ], scientific=TRUE), 
                    "   [", 
                    format( relative_error[ flag_derivative_warning ], scientific=TRUE), 
                    "]", sep='', collapse="\n"
                ), 
                "\n\n"
            )
        }
    }
    else if ( check_derivatives_print == 'none' ) {
        
    }
    

    return( 
        list( 
            "analytic"                = analytic_grad,
            "finite_difference"       = finite_diff_grad,
            "relative_error"          = relative_error,
            "flag_derivative_warning" = flag_derivative_warning
        ) 
    )
}
