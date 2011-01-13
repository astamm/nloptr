# Copyright (C) 2010 Jelmer Ypma. All Rights Reserved.
# This code is published under the L-GPL.
#
# File:   nloptr.R
# Author: Jelmer Ypma
# Date:   9 June 2010
#
# Input: 
#		x0 : vector with initial values
#		eval_f : function to evaluate objective function (and optionally its gradient)
#       eval_grad_f : function evaluate the gradient of the objective function (optional)
#		lb : lower bounds of the control (optional)
#		ub : upper bounds of the control (optional)
#		eval_g_ineq : function to evaluate (non-)linear inequality constraints that should 
#                     hold in the solution and its jacobian (optional)
#       eval_jac_g_ineq : function to evaluate jacobian of the (non-)linear inequality constraints (optional)
#		eval_g_eq : function to evaluate (non-)linear equality constraints that should hold 
#                   in the solution and its jacobian (optional)
#       eval_jac_g_eq : function to evaluate jacobian of the (non-)linear equality constraints (optional)
#		opts : list with options that are passed to Ipopt
#       ... : arguments that are passed to user-defined functions
#
# Output: structure with inputs and
#		call : the call that was made to solve
#		status : integer value with the status of the optimization (0 is success)
#		message : more informative message with the status of the optimization
#		iterations : number of iterations that were executed
#		objective : value if the objective function in the solution
#		solution : optimal value of the controls
#
# 13/01/2011: added print_level option

nloptr <-
function( x0, 
          eval_f, 
          eval_grad_f = NULL,
          lb = NULL, 
          ub = NULL, 
          eval_g_ineq = NULL, 
          eval_jac_g_ineq = NULL,
          eval_g_eq = NULL, 
          eval_jac_g_eq = NULL,
          opts = list(),
		  ... ) {
    

    addDefaults2Options <- function( opts ) {
    
        # add default options if needed
        if( !("algorithm" %in% names( opts )) ) {
			stop( 'algorithm missing in opts or local_opts' )
		}
        if ( sum(c( "stopval", "ftol_rel", "ftol_abs", "xtol_rel", "xtol_abs", "maxeval", "maxtime" ) %in% names( opts )) == 0 ) {
            print( "No termination criterium specified, using default (relative x-tolerance = 1e-4)" )
            opts$xtol_rel <- 1.0e-04
            opts$termination_conditions <- "relative x-tolerance = 1e-4 (DEFAULT)"
        } else {
            conv_options <- unlist( opts[ names(opts) != "algorithm" & 
                                          names(opts) != "tol_constraints_ineq" &
                                          names(opts) != "tol_constraints_eq" &
                                          names(opts) != "print_level"  ] )
            opts$termination_conditions <- paste( paste( names(conv_options) ), ": ", paste( conv_options ), sep='', collapse='\t' )
            if ( ! "xtol_rel" %in% names( opts ) ) {
                opts$xtol_rel <- 0.0
            }
        }
        if ( ! "stopval" %in% names( opts ) ) {
            opts$stopval <- -Inf
        }
        if ( ! "ftol_rel" %in% names( opts ) ) {
            opts$ftol_rel <- 0.0
        }
        if ( ! "ftol_abs" %in% names( opts ) ) {
            opts$ftol_abs <- 0.0
        }
        if ( ! "xtol_abs" %in% names( opts ) ) {
            opts$xtol_abs <- rep( 0.0, length(x0) )
        }
        if ( ! "maxeval" %in% names( opts ) ) {
            opts$maxeval <- 100
        }
        if ( ! "maxtime" %in% names( opts ) ) {
            opts$maxtime <- 0.0
        }
        if ( ! "tol_constraints_ineq" %in% names( opts ) ) {
            opts$tol_constraints_ineq <- rep( 1e-8, num_constraints_ineq )
        }
        if ( ! "tol_constraints_eq" %in% names( opts ) ) {
            opts$tol_constraints_eq <- rep( 1e-8, num_constraints_eq )
        }
        if ( ! "print_level" %in% names( opts ) ) {
            opts$print_level <- 0
        }
    
        return( opts )
    }
    
    
	# internal function to check the arguments of the functions
	.checkfunargs = function( fun, arglist, funname ) {
		if( !is.function(fun) ) stop(paste(funname, " must be a function\n", sep = ""))
		flist = formals(fun)
		if ( length(flist) > 1 ) {
			fnms  = names(flist)[2:length(flist)]	# remove first argument, which is x
			rnms  = names(arglist)
			m1 = match(fnms, rnms)
			if( any(is.na(m1)) ){
				mx1 = which( is.na(m1) )
				for( i in 1:length(mx1) ){
					stop(paste(funname, " requires argument '", fnms[mx1[i]], "' but this has not been passed to the 'nloptr' function.\n", sep = ""))
				}
			}
			m2 = match(rnms, fnms)
			if( any(is.na(m2)) ){
				mx2 = which( is.na(m2) )
				for( i in 1:length(mx2) ){
					stop(paste(rnms[mx2[i]], "' passed to (...) in 'nloptr' but this is not required in the ", funname, " function.\n", sep = ""))
				}
			}
		}
		return( 0 )
	}
    
	
	# extract list of additional arguments and check user-defined functions
	arglist = list(...)
	.checkfunargs( eval_f, arglist, 'eval_f' )
	if( !is.null( eval_grad_f ) ) { .checkfunargs( eval_grad_f, arglist, 'eval_grad_f' ) }
	if( !is.null( eval_g_ineq ) ) { .checkfunargs( eval_g_ineq, arglist, 'eval_g_ineq' ) }
	if( !is.null( eval_jac_g_ineq ) ) { .checkfunargs( eval_jac_g_ineq, arglist, 'eval_jac_g_ineq' ) }
	if( !is.null( eval_g_eq ) ) { .checkfunargs( eval_g_eq, arglist, 'eval_g_eq' ) }
	if( !is.null( eval_jac_g_eq ) ) { .checkfunargs( eval_jac_g_eq, arglist, 'eval_jac_g_eq' ) }
	
    # define 'infinite' lower and upper bounds of the control if they haven't been set
    if ( is.null( lb ) ) { lb <- rep( -Inf, length(x0) ) }
    if ( is.null( ub ) ) { ub <- rep(  Inf, length(x0) ) }
    
    # if eval_f does not return a list, write a wrapper function combining eval_f and eval_grad_f
    if ( is.list( eval_f( x0, ... ) ) | 
         is.null( eval_grad_f ) ) {
        
            eval_f_wrapper <- function(x) { eval_f(x, ...) }
        
    } else {
 
		eval_f_wrapper <- function( x ) {
            return( list( "objective" = eval_f( x, ... ),
                          "gradient"  = eval_grad_f( x, ... ) ) )
        }
    }
    
    # change the environment of the inequality constraint functions that we're calling
    num_constraints_ineq <- 0
    if ( !is.null( eval_g_ineq ) ) {
        
        # if eval_g_ineq does not return a list, write a wrapper function combining eval_g_ineq and eval_jac_g_ineq
        if ( is.list( eval_g_ineq( x0, ... ) ) | 
             is.null( eval_jac_g_ineq ) ) {
            
            eval_g_ineq_wrapper <- function(x) { eval_g_ineq(x, ...) }
            
        } else {
            
            eval_g_ineq_wrapper <- function( x ) {
                return( list( "constraints" = eval_g_ineq( x, ... ),
                              "jacobian"  = eval_jac_g_ineq( x, ... ) ) )
            }
        }
        
        # determine number of constraints
        tmp_constraints <- eval_g_ineq_wrapper( x0 )
        if ( is.list( tmp_constraints ) ) {
            num_constraints_ineq <- length( tmp_constraints$constraints )
        } else {
            num_constraints_ineq <- length( tmp_constraints )
        }
        
    } else {
        # define dummy function
        eval_g_ineq_wrapper <- NULL
    }
    
    
    # change the environment of the equality constraint functions that we're calling
    num_constraints_eq <- 0
    if ( !is.null( eval_g_eq ) ) {
        
        # if eval_g_eq does not return a list, write a wrapper function combining eval_g_eq and eval_jac_g_eq
        if ( is.list( eval_g_eq( x0, ... ) ) | 
             is.null( eval_jac_g_eq ) ) {
            
            eval_g_eq_wrapper <- function(x) { eval_g_eq(x, ...) }
            
        } else {
    
			eval_g_eq_wrapper <- function( x ) {
                return( list( "constraints" = eval_g_eq( x, ... ),
                              "jacobian"  = eval_jac_g_eq( x, ... ) ) )
            }
            
        }
        
        # determine number of constraints
        tmp_constraints <- eval_g_eq_wrapper( x0 )
        if ( is.list( tmp_constraints ) ) {
            num_constraints_eq <- length( tmp_constraints$constraints )
        } else {
            num_constraints_eq <- length( tmp_constraints )
        }
        
    } else {
        # define dummy function
        eval_g_eq_wrapper <- NULL
    }
    
    
    # extract local options from list of options if they exist
    if ( "local_opts" %in% names(opts) ) {
        local_opts <- addDefaults2Options( opts$local_opts )
        opts$local_opts <- NULL
    } else {
        local_opts <- NULL
    }
    
    # add defaults to list of options
    opts <- addDefaults2Options( opts )
    
    # add the termination criteria to the list (and remove it from the options)
    termination_conditions <- opts$termination_conditions
    opts$termination_conditions <- NULL    
    
    ret <- list( "x0"=x0, 
                 "eval_f"=eval_f_wrapper, 
                 "lower_bounds"=lb, 
                 "upper_bounds"=ub, 
                 "num_constraints_ineq"=num_constraints_ineq,
                 "eval_g_ineq"=eval_g_ineq_wrapper, 
                 "num_constraints_eq"=num_constraints_eq,
                 "eval_g_eq"=eval_g_eq_wrapper, 
                 "options"=opts,
                 "local_options"=local_opts,
				 "nloptr_environment"=new.env() )
    
    attr(ret, "class") <- "nloptr"
    
    # add the current call to the list
    ret$call <- match.call()

    # add the termination criteria to the list
    ret$termination_conditions <- termination_conditions
    
    # check whether we have a correctly formed ipoptr object
    is.nloptr( ret )
    
    # choose correct minimzation function based on wether constrained were supplied
    solution <- .Call( NLoptR_Optimize, ret )
    
    # remove the environment from the return object
    ret$environment <- NULL
    
    # add solution variables to object
    ret$status <- solution$status
    ret$message <- solution$message
    ret$iterations <- solution$iterations
    ret$objective <- solution$objective
    ret$solution <- solution$solution
    ret$version <- paste( c(solution$version_major, solution$version_minor, solution$version_bugfix), collapse='.' )
	
	return( ret )
}
