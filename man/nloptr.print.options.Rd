\name{nloptr.print.options}
\alias{nloptr.print.options}
\title{
Print list of all options with description
}
\description{
This function prints a list of all the options that can be set when solving a minimization problem using \code{nloptr}.
}
\usage{
nloptr.print.options( 
	opts.user=NULL ) 
}
\arguments{
  \item{opts.user}{
    object containing user supplied options. This argument is optional. It is used when \code{nloptr.print.options} is called from \code{nloptr}. In that case options are listed if \code{print_options_doc} is set to \code{TRUE} when passing a minimization problem to \code{nloptr}.
  }
}
\author{
Jelmer Ypma
}
\seealso{
\code{\link[nloptr:nloptr]{nloptr}}
}
\examples{
library('nloptr')
nloptr.print.options()

opts <- list("algorithm"="NLOPT_LD_LBFGS",
             "xtol_rel"=1.0e-8)
nloptr.print.options( opts )
}
\keyword{ optimize }
\keyword{ interface }
