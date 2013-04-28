\name{print.nloptr}
\alias{print.nloptr}
\title{
Print results after running nloptr
}
\description{
This function prints the nloptr object that holds the results from a minimization using \code{nloptr}.
}
\usage{
\method{print}{nloptr}( x, show.controls=TRUE, \dots )
}
\arguments{
  \item{x}{
    object containing result from minimization.
  }
  \item{show.controls}{
    Logical or vector with indices. Should we show the value of the control variables in the solution? If \code{show.controls} is a vector with indices, it is used to select which control variables should be shown. This can be useful if the model contains a set of parameters of interest and a set of nuisance parameters that are not of immediate interest.
  }
  \item{...}{
    further arguments passed to or from other methods.
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
