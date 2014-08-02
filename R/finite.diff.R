# Copyright (C) 2011 Jelmer Ypma. All Rights Reserved.
# This code is published under the L-GPL.
#
# File:   finite.diff.R
# Author: Jelmer Ypma
# Date:   24 July 2011
#
# Approximate the gradient of a function using finite differences.
#
# Input: 
#        func : calculate finite difference approximation for the gradient of this function
#        .x : evaluate at this point
#        indices : calculate finite difference approcximation only for .x-indices in this vector (optional)
#        stepSize : relative size of the step between x and x+h (optional)
#       ... : arguments that are passed to the user-defined function (func)
#
# Output: matrix with finite difference approximations


# http://en.wikipedia.org/wiki/Numerical_differentiation
finite.diff <- function( func, .x, indices=1:length(.x), stepSize=sqrt( .Machine$double.eps ), ... ) {
    
    # if we evaluate at values close to 0, we need a different step size
    stepSizeVec <- pmax( abs(.x), 1 ) * stepSize 
    
    fx <- func( .x, ... )
    approx.gradf.index <- function(i, .x, func, fx, stepSizeVec, ...) {
        x_prime <- .x
        x_prime[i] <- .x[i] + stepSizeVec[i]
        stepSizeVec[i] <- x_prime[i] - .x[i]
        fx_prime <- func( x_prime, ... )
        return( ( fx_prime - fx )/stepSizeVec[i] )
    }
    grad_fx <- sapply (indices, approx.gradf.index, .x=.x, func=func, fx=fx, stepSizeVec=stepSizeVec, ... )
    
    return( grad_fx )
}
