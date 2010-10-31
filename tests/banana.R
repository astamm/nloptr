# Copyright (C) 2010 Jelmer Ypma. All Rights Reserved.
# This code is published under the L-GPL.
#
# File:   banana.R
# Author: Jelmer Ypma
# Date:   10 June 2010
#
# Example showing how to solve the Rosenbrock Banana function.

library('nloptr')

## Rosenbrock Banana function and gradient in separate functions
eval_f <- function(x) {
    return( 100 * (x[2] - x[1] * x[1])^2 + (1 - x[1])^2 )
}

eval_grad_f <- function(x) {
    return( c( -400 * x[1] * (x[2] - x[1] * x[1]) - 2 * (1 - x[1]),
                200 * (x[2] - x[1] * x[1])) )
}


# initial values
x0 <- c( -1.2, 1 )

opts <- list("algorithm"="NLOPT_LD_LBFGS",
             "xtol_rel"=1.0e-8)
 
# solve Rosenbrock Banana function
res <- nloptr( x0=x0, 
               eval_f=eval_f, 
               eval_grad_f=eval_grad_f,
               opts=opts)
print( res )               

               
## Rosenbrock Banana function and gradient in one function
# this can be used to economize on calculations
eval_f_list <- function(x) {
    return( list( "objective" = 100 * (x[2] - x[1] * x[1])^2 + (1 - x[1])^2,
                  "gradient"  = c( -400 * x[1] * (x[2] - x[1] * x[1]) - 2 * (1 - x[1]),
                                    200 * (x[2] - x[1] * x[1])) ) )
}
               
# solve Rosenbrock Banana function using an objective function that
# returns a list with the objective value and its gradient               
res <- nloptr( x0=x0, 
               eval_f=eval_f_list,
               opts=opts)
print( res )
