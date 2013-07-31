# Copyright (C) 2011 Jelmer Ypma. All Rights Reserved.
# This code is published under the L-GPL.
#
# File:   banana_global.R
# Author: Jelmer Ypma
# Date:   8 August 2011
#
# Example showing how to solve the Rosenbrock Banana function
# using a global optimization algorithm.

library('nloptr')

## Rosenbrock Banana objective function
eval_f <- function(x) {
    return( 100 * (x[2] - x[1] * x[1])^2 + (1 - x[1])^2 )
}

eval_grad_f <- function(x) {
    return( c( -400 * x[1] * (x[2] - x[1] * x[1]) - 2 * (1 - x[1]),
                200 * (x[2] - x[1] * x[1])) )
}

# initial values
x0 <- c( -1.2, 1 )

# lower and upper bounds
lb <- c( -3, -3 )
ub <- c(  3,  3 )

local_opts <- list( "algorithm" = "NLOPT_LD_LBFGS",
                    "xtol_rel"  = 1e-4 )

opts <- list( "algorithm"   = "NLOPT_GD_MLSL",
              "maxeval"     = 10000,
			  "population"  = 4,
			  "local_opts"  = local_opts )
 
# solve Rosenbrock Banana function
res <- nloptr( x0=x0, 
               lb=lb,
			   ub=ub,
			   eval_f=eval_f,
			   eval_grad_f=eval_grad_f,
               opts=opts)
print( res )


opts <- list( "algorithm"   = "NLOPT_GN_ISRES",
              "maxeval"     = 10000,
			  "population"  = 100 )
 
# solve Rosenbrock Banana function
res <- nloptr( x0=x0, 
               lb=lb,
			   ub=ub,
			   eval_f=eval_f,
			   opts=opts)
print( res )


opts <- list( "algorithm"   = "NLOPT_GN_CRS2_LM",
              "maxeval"     = 10000,
			  "population"  = 100 )
 
# solve Rosenbrock Banana function
res1 <- nloptr( x0=x0, 
                lb=lb,
			    ub=ub,
			    eval_f=eval_f,
			    opts=opts)
print( res1 )


# this optimization uses a different seed for the
# random number generator (generated from system time)
# and gives a different result
opts <- list( "algorithm"   = "NLOPT_GN_CRS2_LM",
              "maxeval"     = 10000,
			  "population"  = 100 )
 
# solve Rosenbrock Banana function
res2 <- nloptr( x0=x0, 
                lb=lb,
		 	    ub=ub,
	 		    eval_f=eval_f,
 			    opts=opts)
print( res2 )

# this optimization uses a different seed for the
# random number generator and gives a different result
opts <- list( "algorithm"   = "NLOPT_GN_CRS2_LM",
              "maxeval"     = 10000,
			  "population"  = 100,
			  "ranseed"     = 3141 )
 
# solve Rosenbrock Banana function
res3 <- nloptr( x0=x0, 
                lb=lb,
			    ub=ub,
			    eval_f=eval_f,
			    opts=opts)
print( res3 )

# this optimization uses the same seed for the random
# number generator and gives the same results as res3
opts <- list( "algorithm"   = "NLOPT_GN_CRS2_LM",
              "maxeval"     = 10000,
			  "population"  = 100,
			  "ranseed"     = 3141 )
 
# solve Rosenbrock Banana function
res4 <- nloptr( x0=x0, 
                lb=lb,
			    ub=ub,
			    eval_f=eval_f,
			    opts=opts)
print( res4 )
