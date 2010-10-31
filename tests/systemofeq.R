# Copyright (C) 2010 Jelmer Ypma. All Rights Reserved.
# This code is published under the L-GPL.
#
# File:   systemofeq.R
# Author: Jelmer Ypma
# Date:   20 June 2010
#
# Example showing how to solve a system of equations.
#
# min 1
# s.t. x^2 + x - 1 = 0

library('nloptr')


# objective function
eval_f0 <- function( x, params ) { 
    return( 1 )
}

# gradient of objective function
eval_grad_f0 <- function( x, params ) { 
    return( 0 )
}

# equality constraint function
eval_g0_eq <- function( x, params ) {
    return( params[1]*x^2 + params[2]*x + params[3] )
}

# jacobian of constraint
eval_jac_g0_eq <- function( x, params ) {
    return( 2*params[1]*x + params[2] )
}

local_opts <- list( "algorithm" = "NLOPT_LD_MMA",
                    "xtol_rel"  = 1.0e-6 )
                    
opts <- list( "algorithm" = "NLOPT_LD_AUGLAG",
              "xtol_rel"  = 1.0e-6,
              "local_opts" = local_opts )
              
# Solve using NLOPT_LD_MMA with gradient information supplied in separate function
res0 <- nloptr( x0=-5, 
                eval_f=eval_f0, 
                eval_grad_f=eval_grad_f0,
                eval_g_eq = eval_g0_eq,
                eval_jac_g_eq = eval_jac_g0_eq,                
                opts = opts,
				params = c(1, 1, -1) )
print( res0 )
        
