# Copyright (C) 2010 Jelmer Ypma. All Rights Reserved.
# This code is published under the L-GPL.
#
# File:   hs023.R
# Author: Jelmer Ypma
# Date:   16 August 2010
#
# Example problem, number 23 from the Hock-Schittkowsky test suite..
#
# \min_{x} x1^2 + x2^2
# s.t.
#   x1 + x2 >= 1
#   x1^2 + x2^2 >= 1
#   9*x1^2 + x2^2 >= 9
#   x1^2 - x2 >= 0
#   x2^2 - x1 >= 0
#
# with bounds on the variables
#   -50 <= x1, x2 <= 50
#
# we re-write the inequalities as
#   1 - x1 - x2 <= 0
#   1 - x1^2 - x2^2 <= 0
#   9 - 9*x1^2 - x2^2 <= 0
#   x2 - x1^2 <= 0
#   x1 - x2^2 <= 0 
#
# the initial value is
# x0 = (3, 1)
#
# optimal solution = (1, 1)


library('nloptr')

#
# f(x) = x1^2 + x2^2
#
eval_f <- function( x ) { 
    return( list( "objective" = x[1]^2 + x[2]^2,
                  "gradient" = c( 2*x[1],
                                  2*x[2] ) ) ) 
}

# constraint functions
# inequalities
eval_g_ineq <- function( x ) {
    constr <- c( 1 - x[1] - x[2],
                 1 - x[1]^2 - x[2]^2,
                 9 - 9*x[1]^2 - x[2]^2,
                 x[2] - x[1]^2,
                 x[1] - x[2]^2 )
                 
    grad   <- rbind( c( -1, -1 ),
                     c( -2*x[1], -2*x[2] ),
                     c( -18*x[1], -2*x[2] ),
                     c( -2*x[1], 1 ),
                     c( 1, -2*x[2] ) )
                     
    return( list( "constraints"=constr, "jacobian"=grad ) )
}

# initial values
x0 <- c( 3, 1 )

# lower and upper bounds of control
lb <- c( -50, -50 )
ub <- c(  50,  50 )

# solve with MMA
opts <- list( "algorithm"   = "NLOPT_LD_MMA",
              "xtol_rel"    = 1.0e-6, 
              "print_level" = 2 )
             
res <- nloptr( x0=x0, 
               eval_f=eval_f, 
               lb=lb, 
               ub=ub, 
               eval_g_ineq=eval_g_ineq, 
               opts=opts)               
print( res )


# check solution
#epsilon <- 1e-4
#objective <- eval_f( res$solution )
#constraints <- eval_g_ineq( res$solution )
#is.binding <- abs(constraints$constraints) < epsilon
#
#lagrange.multipliers <- solve( constraints$jacobian[is.binding,], objective$gradient )
## todo: calculate hessian
## do some checks on optimality, KKT, satisfied constraints? which constraints are binding?
#lagrangian <- function( x, lambda, is.binding ) {
#	return( eval_f(x)$objective - sum(lambda * eval_g_ineq(x)$constraints[is.binding]) )
#}
#lagrangian( res$solution, lagrange.multipliers, is.binding )
#
#lagrangian_grad <- function ( x ) {
#	return( finite.diff( lagrangian, .x=x, lambda=lagrange.multipliers, is.binding=is.binding ) )
#}
#
#finite.diff( lagrangian_grad, .x=res$solution )

