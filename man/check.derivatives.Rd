\name{check.derivatives}
\alias{check.derivatives}
\title{
Check analytic gradients of a function using finite difference approximations
}
\description{
This function compares the analytic gradients of a function with a finite difference approximation and prints the results of these checks.
}
\usage{
check.derivatives( 
	.x, 
	func, 
	func_grad, 
	check_derivatives_tol = 1e-04, 
	check_derivatives_print = 'all', 
	func_grad_name = 'grad_f', 
	\ldots
)
}
\arguments{
  \item{.x}{
    point at which the comparison is done.
  }
  \item{func}{
    function to be evaluated.
  }
  \item{func_grad}{
	function calculating the analytic gradients.
  }
  \item{check_derivatives_tol}{
	option determining when differences between the analytic gradient and its finite difference approximation are flagged as an error.
  }
  \item{check_derivatives_print}{
	option related to the amount of output. 'all' means that all comparisons are shown, 'errors' only shows comparisons that are flagged as an error, and 'none' shows the number of errors only.
  }
  \item{func_grad_name}{
	option to change the name of the gradient function that shows up in the output.
  }
  \item{...}{
    further arguments passed to the functions func and func_grad.
  }
}
\author{
Jelmer Ypma
}
\seealso{
\code{\link[nloptr:nloptr]{nloptr}}
}
\keyword{ optimize }
\keyword{ interface }
