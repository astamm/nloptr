# Copyright (C) 2010 Jelmer Ypma. All Rights Reserved.
# This code is published under the L-GPL.
#
# File:   is.nloptr.R
# Author: Jelmer Ypma
# Date:   10 June 2010
#
# Input: object
# Output: bool telling whether the object is an nloptr or not
#
# CHANGELOG
#   16/06/2011: separated local optimzer check and equality constraints check
#   05/05/2014: Replaced cat by warning.

is.nloptr <- function( x ) {
    
    # Check whether the object exists and is a list
    if( is.null(x) ) { return( FALSE ) }
    if( !is.list(x) ) { return( FALSE ) }

    # Check whether the needed wrapper functions are supplied
    if ( !is.function(x$eval_f) ) { stop('eval_f is not a function') }
    if ( !is.null(x$eval_g_ineq) ) {
        if ( !is.function(x$eval_g_ineq) ) { stop('eval_g_ineq is not a function') }
    }
    if ( !is.null(x$eval_g_eq) ) {
        if ( !is.function(x$eval_g_eq) ) { stop('eval_g_eq is not a function') }
    }
    
    # Check whether bounds are defined for all controls
    if ( any( is.na( x$x0 ) ) ) { stop('x0 contains NA') }
    if ( length( x$x0 ) != length( x$lower_bounds ) ) { stop('length(lb) != length(x0)') }
    if ( length( x$x0 ) != length( x$upper_bounds ) ) { stop('length(ub) != length(x0)') }
    
    # Check whether the initial value is within the bounds
    if ( any( x$x0 < x$lower_bounds ) ) { stop('at least one element in x0 < lb') }
    if ( any( x$x0 > x$upper_bounds ) ) { stop('at least one element in x0 > ub') }
    
    
    # define list with all algorithms
    list_algorithms <- c( "NLOPT_GN_DIRECT", "NLOPT_GN_DIRECT_L", "NLOPT_GN_DIRECT_L_RAND", 
                          "NLOPT_GN_DIRECT_NOSCAL", "NLOPT_GN_DIRECT_L_NOSCAL", 
                          "NLOPT_GN_DIRECT_L_RAND_NOSCAL", "NLOPT_GN_ORIG_DIRECT", 
                          "NLOPT_GN_ORIG_DIRECT_L", "NLOPT_GD_STOGO", "NLOPT_GD_STOGO_RAND", 
                          "NLOPT_LD_SLSQP", "NLOPT_LD_LBFGS_NOCEDAL", "NLOPT_LD_LBFGS", "NLOPT_LN_PRAXIS", 
                          "NLOPT_LD_VAR1", "NLOPT_LD_VAR2", "NLOPT_LD_TNEWTON", 
                          "NLOPT_LD_TNEWTON_RESTART", "NLOPT_LD_TNEWTON_PRECOND", 
                          "NLOPT_LD_TNEWTON_PRECOND_RESTART", "NLOPT_GN_CRS2_LM", 
                          "NLOPT_GN_MLSL", "NLOPT_GD_MLSL", "NLOPT_GN_MLSL_LDS", 
                          "NLOPT_GD_MLSL_LDS", "NLOPT_LD_MMA", "NLOPT_LN_COBYLA", 
                          "NLOPT_LN_NEWUOA", "NLOPT_LN_NEWUOA_BOUND", "NLOPT_LN_NELDERMEAD", 
                          "NLOPT_LN_SBPLX", "NLOPT_LN_AUGLAG", "NLOPT_LD_AUGLAG", 
                          "NLOPT_LN_AUGLAG_EQ", "NLOPT_LD_AUGLAG_EQ", "NLOPT_LN_BOBYQA", 
                          "NLOPT_GN_ISRES" )

    # check if an existing algorithm was supplied
    if ( !( x$options$algorithm %in% list_algorithms ) ) {
        stop( paste('Incorrect algorithm supplied. Use one of the following:\n', paste( list_algorithms, collapse='\n' ) ) )
    }
    
    # determine subset of algorithms that need a derivative
    list_algorithmsD <- list_algorithms[ grep( "NLOPT_[G,L]D", list_algorithms ) ]
    list_algorithmsN <- list_algorithms[ grep( "NLOPT_[G,L]N", list_algorithms ) ]
    
    # Check the whether we don't have NA's if we evaluate the objective function in x0
    f0 <- x$eval_f( x$x0 )
    if ( is.list( f0 ) ) {
        if ( is.na( f0$objective ) ) { stop('objective in x0 returns NA') }
        if ( any( is.na( f0$gradient ) ) ) { stop('gradient of objective in x0 returns NA') }
        if ( length( f0$gradient ) != length( x$x0 ) ) { stop('wrong number of elements in gradient of objective') }
        
        # check whether algorihtm needs a derivative
        if ( x$options$algorithm %in% list_algorithmsN ) {
            warning( 'a gradient was supplied for the objective function, but algorithm ', 
                      x$options$algorithm, ' does not use gradients.' )
        }
        
    } else {
        if ( is.na( f0 ) ) { stop('objective in x0 returns NA') }
        
        # check whether algorihtm needs a derivative
        if ( x$options$algorithm %in% list_algorithmsD ) {
            stop( paste( 'A gradient for the objective function is needed by algorithm', 
                         x$options$algorithm, 'but was not supplied.\n' ) )
        }
    }
    
    
    # Check the whether we don't have NA's if we evaluate the inequality constraints in x0
    if ( !is.null( x$eval_g_ineq ) ) {
        g0_ineq <- x$eval_g_ineq( x$x0 )
        if ( is.list( g0_ineq ) ) {
            if ( any( is.na( g0_ineq$constraints ) ) ) { stop('inequality constraints in x0 returns NA') }
            if ( any( is.na( g0_ineq$jacobian ) ) ) { stop('jacobian of inequality constraints in x0 returns NA') }
        
            if ( length( g0_ineq$jacobian ) != length( g0_ineq$constraints )*length( x$x0 ) ) { 
                stop(paste('wrong number of elements in jacobian of inequality constraints (is ', 
                           length( g0_ineq$jacobian ), 
                           ', but should be ', 
                           length( g0_ineq$constraints ), ' x ',
                           length( x$x0 ), ' = ',
                           length( g0_ineq$constraints )*length( x$x0 ), ')', sep=''))
            }
            
            # check whether algorihtm needs a derivative
            if ( x$options$algorithm %in% list_algorithmsN ) {
                warning( 'a gradient was supplied for the inequality constraints, but algorithm ', 
                         x$options$algorithm, ' does not use gradients.' )
            }
            
        } else {
            if ( any( is.na( g0_ineq ) ) ) { stop('inequality constraints in x0 returns NA') }
            
            # check whether algorihtm needs a derivative
            if ( x$options$algorithm %in% list_algorithmsD ) {
                stop( paste( 'A gradient for the inequality constraints is needed by algorithm', 
                             x$options$algorithm, 'but was not supplied.\n' ) )
            }
        }
    }
    
    # Check the whether we don't have NA's if we evaluate the equality constraints in x0
    if ( !is.null( x$eval_g_eq ) ) {
        g0_eq <- x$eval_g_eq( x$x0 )
        if ( is.list( g0_eq ) ) {
            if ( any( is.na( g0_eq$constraints ) ) ) { stop('equality constraints in x0 returns NA') }
            if ( any( is.na( g0_eq$jacobian ) ) ) { stop('jacobian of equality constraints in x0 returns NA') }
            
            if ( length( g0_eq$jacobian ) != length( g0_eq$constraints )*length( x$x0 ) ) { 
                stop(paste('wrong number of elements in jacobian of equality constraints (is ', 
                           length( g0_eq$jacobian ), 
                           ', but should be ', 
                           length( g0_eq$constraints ), ' x ',
                           length( x$x0 ), ' = ',
                           length( g0_eq$constraints )*length( x$x0 ), ')', sep=''))
            }
            
            # check whether algorihtm needs a derivative
            if ( x$options$algorithm %in% list_algorithmsN ) {
                warning( 'a gradient was supplied for the equality constraints, but algorithm ', 
                         x$options$algorithm, ' does not use gradients.' )
            }
            
        } else {
            if ( any( is.na( g0_eq ) ) ) { stop('equality constraints in x0 returns NA') }
            
            # check whether algorihtm needs a derivative
            if ( x$options$algorithm %in% list_algorithmsD ) {
                stop( paste( 'A gradient for the equality constraints is needed by algorithm', 
                             x$options$algorithm, 'but was not supplied.\n' ) )
            }
        }
    }
    
    
    
    # check if we have a correct algorithm for the equality constraints
    if ( x$num_constraints_eq > 0 ) {
        eq_algorithms <- c("NLOPT_LD_AUGLAG", 
                           "NLOPT_LN_AUGLAG",
                           "NLOPT_LD_AUGLAG_EQ",
                           "NLOPT_LN_AUGLAG_EQ",
                           "NLOPT_GN_ISRES",
                           "NLOPT_LD_SLSQP")
        if( !( x$options$algorithm %in% eq_algorithms ) ) {
            stop(paste('If you want to use equality constraints, then you should use one of these algorithms', paste(eq_algorithms, collapse=', ')))
        }
    }
    
    # check if a local optimizer was supplied, which is needed by some algorithms
    if ( x$options$algorithm %in% 
            c("NLOPT_LD_AUGLAG", 
              "NLOPT_LN_AUGLAG",
              "NLOPT_LD_AUGLAG_EQ",
              "NLOPT_LN_AUGLAG_EQ",
              "NLOPT_GN_MLSL", 
              "NLOPT_GD_MLSL", 
              "NLOPT_GN_MLSL_LDS", 
              "NLOPT_GD_MLSL_LDS") ) {
        if ( is.null( x$local_options ) ) {
            stop(paste('The algorithm', x$options$algorithm, 'needs a local optimizer; specify an algorithm and termination condition in local_opts'))
        }
    }
    
    return( TRUE )
}
