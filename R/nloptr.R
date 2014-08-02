# Copyright (C) 2010 Jelmer Ypma. All Rights Reserved.
# This code is published under the L-GPL.
#
# File:   nloptr.R
# Author: Jelmer Ypma
# Date:   9 June 2010
#
# Input: 
#        x0 : vector with initial values
#        eval_f : function to evaluate objective function (and optionally its gradient)
#        eval_grad_f : function evaluate the gradient of the objective function (optional)
#        lb : lower bounds of the control (optional)
#        ub : upper bounds of the control (optional)
#        eval_g_ineq : function to evaluate (non-)linear inequality constraints that should 
#                      hold in the solution and its jacobian (optional)
#        eval_jac_g_ineq : function to evaluate jacobian of the (non-)linear inequality constraints (optional)
#        eval_g_eq : function to evaluate (non-)linear equality constraints that should hold 
#                    in the solution and its jacobian (optional)
#        eval_jac_g_eq : function to evaluate jacobian of the (non-)linear equality constraints (optional)
#        opts : list with options that are passed to Ipopt
#        ... : arguments that are passed to user-defined functions
#
# Output: structure with inputs and
#        call : the call that was made to solve
#        status : integer value with the status of the optimization (0 is success)
#        message : more informative message with the status of the optimization
#        iterations : number of iterations that were executed
#        objective : value if the objective function in the solution
#        solution : optimal value of the controls
#
# CHANGELOG:
#   13/01/2011: added print_level option
#   24/07/2011: added finite difference gradient checker
#   07/08/2011: moved addition of default options to separate function
#               show documentation of options if print_options_doc == TRUE
#   05/05/2014: Replaced cat by message, so messages can now be suppressed by suppressMessages.

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

    # internal function to check the arguments of the functions
    .checkfunargs = function( fun, arglist, funname ) {
        if( !is.function(fun) ) stop(paste(funname, " must be a function\n", sep = ""))
        flist = formals(fun)
        if ( length(flist) > 1 ) {
            fnms  = names(flist)[2:length(flist)]    # remove first argument, which is x
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
        res.opts.add <- nloptr.add.default.options( 
                        opts.user                 = opts$local_opts,
                        x0                         = x0,
                        num_constraints_ineq     = num_constraints_ineq, 
                        num_constraints_eq         = num_constraints_eq )
        local_opts   <- res.opts.add$opts.user
        opts$local_opts <- NULL
    } else {
        local_opts <- NULL
    }
    
    # add defaults to list of options
    res.opts.add <- nloptr.add.default.options( 
                opts.user                 = opts,
                x0                         = x0,
                num_constraints_ineq     = num_constraints_ineq, 
                num_constraints_eq         = num_constraints_eq )
    opts <- res.opts.add$opts.user
    
    # add the termination criteria to the list
    termination_conditions <- res.opts.add$termination_conditions
    
    # print description of options if requested
    if (opts$print_options_doc) {
        nloptr.print.options( opts.user = opts )
    }    
    
    # define list with all algorithms
    # nloptr.options.description is a data.frame with options
    # that is loaded when nloptr is loaded.
    nloptr.default.options <- nloptr.get.default.options()
    list_algorithms <-  unlist(
                            strsplit(
                                nloptr.default.options[ nloptr.default.options$name=="algorithm", "possible_values" ],
                                ", "
                            )
                        )
    
    # run derivative checker
    if ( opts$check_derivatives ) {
    
        if ( opts$algorithm %in% list_algorithms[ grep( "NLOPT_[G,L]N", list_algorithms ) ] ) {
            warning( paste("Skipping derivative checker because algorithm '", opts$algorithm, "' does not use gradients.", sep='') )
        }
        else {
            # check derivatives of objective function
            message( "Checking gradients of objective function." )
            check.derivatives(
                .x = x0, 
                func = function( x ) { eval_f_wrapper( x )$objective }, 
                func_grad = function( x ) { eval_f_wrapper( x )$gradient }, 
                check_derivatives_tol = opts$check_derivatives_tol, 
                check_derivatives_print = opts$check_derivatives_print, 
                func_grad_name = 'eval_grad_f'
            )
            
            if ( num_constraints_ineq > 0 ) {
                # check derivatives of inequality constraints
                message( "Checking gradients of inequality constraints.\n" )
                check.derivatives(
                    .x = x0, 
                    func = function( x ) { eval_g_ineq_wrapper( x )$constraints }, 
                    func_grad = function( x ) { eval_g_ineq_wrapper( x )$jacobian }, 
                    check_derivatives_tol = opts$check_derivatives_tol, 
                    check_derivatives_print = opts$check_derivatives_print, 
                    func_grad_name = 'eval_jac_g_ineq'
                )
            }
            
            if ( num_constraints_eq > 0 ) {
                # check derivatives of equality constraints
                message( "Checking gradients of equality constraints.\n" )
                check.derivatives(
                    .x = x0, 
                    func = function( x ) { eval_g_eq_wrapper( x )$constraints }, 
                    func_grad = function( x ) { eval_g_eq_wrapper( x )$jacobian }, 
                    check_derivatives_tol = opts$check_derivatives_tol, 
                    check_derivatives_print = opts$check_derivatives_print, 
                    func_grad_name = 'eval_jac_g_eq'
                )
            }
        }

    }
    
    ret <- list( "x0"                   = x0, 
                 "eval_f"               = eval_f_wrapper, 
                 "lower_bounds"         = lb, 
                 "upper_bounds"         = ub, 
                 "num_constraints_ineq" = num_constraints_ineq,
                 "eval_g_ineq"          = eval_g_ineq_wrapper, 
                 "num_constraints_eq"   = num_constraints_eq,
                 "eval_g_eq"            = eval_g_eq_wrapper, 
                 "options"              = opts,
                 "local_options"        = local_opts,
                 "nloptr_environment"   = new.env() )
    
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
    ret$status     <- solution$status
    ret$message    <- solution$message
    ret$iterations <- solution$iterations
    ret$objective  <- solution$objective
    ret$solution   <- solution$solution
    ret$version    <- paste( c(solution$version_major, solution$version_minor, solution$version_bugfix), collapse='.' )
    
    return( ret )
}
