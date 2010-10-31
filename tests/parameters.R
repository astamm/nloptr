# Copyright (C) 2010 Jelmer Ypma. All Rights Reserved.
# This code is published under the L-GPL.
#
# File:   parameters.R
# Author: Jelmer Ypma
# Date:   17 August 2010
#
# Example shows how we can have an objective function 
# depend on parameters or data. The objective function 
# is a simple polynomial.

library('nloptr')

# objective function and gradient in terms of parameters
eval_f <- function(x, params) { 
    return( params[1]*x^2 + params[2]*x + params[3] ) 
}
eval_grad_f <- function(x, params) { 
    return( 2*params[1]*x + params[2] ) 
}

# define parameters that we want to use
params <- c(1,2,3)

# define initial value of the optimzation problem
x0 <- 0

# solve using nloptr adding params as an additional parameter
nloptr( x0          = x0, 
        eval_f      = eval_f, 
        eval_grad_f = eval_grad_f,
		opts        = list("algorithm"="NLOPT_LD_MMA"),
        params      = params )



# solve using algebra
cat( paste( "Minimizing f(x) = ax^2 + bx + c\n" ) )
cat( paste( "Optimal value of control is -b/(2a) = ", -params[2]/(2*params[1]), "\n" ) )
cat( paste( "With value of the objective function f(-b/(2a)) = ", eval_f( -params[2]/(2*params[1]), params ), "\n" ) )
