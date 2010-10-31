# Copyright (C) 2010 Jelmer Ypma. All Rights Reserved.
# This code is published under the L-GPL.
#
# File:   simple.R
# Author: Jelmer Ypma
# Date:   20 June 2010
#
# Example showing how to solve a simple constrained problem.
#
# min x^2
# s.t. x >= 5
#
# re-formulate constraint to be of form g(x) <= 0
#      5 - x <= 0
# we could use a bound constraint as well here

library('nloptr')


# objective function
eval_f0 <- function(x) { 
    return( x^2 )
}

# gradient of objective function
eval_grad_f0 <- function(x) { 
    return( 2*x )
}

# inequality constraint function
eval_g0_ineq <- function( x ) {
    return( 5-x )
}

# jacobian of constraint
eval_jac_g0_ineq <- function( x ) {
    return( -1 )
}


# Solve using NLOPT_LD_MMA with gradient information supplied in separate function
res0 <- nloptr( x0=1, 
                eval_f=eval_f0, 
                eval_grad_f=eval_grad_f0,
                eval_g_ineq = eval_g0_ineq,
                eval_jac_g_ineq = eval_jac_g0_ineq,                
                opts = list("algorithm"="NLOPT_LD_MMA") )
print( res0 )
        
# Solve using NLOPT_LN_COBYLA without gradient information
res1 <- nloptr( x0=1, 
                eval_f=eval_f0,				
                eval_g_ineq = eval_g0_ineq, 
                opts = list("algorithm"="NLOPT_LN_COBYLA") )
print( res1 )
