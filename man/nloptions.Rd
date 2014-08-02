\name{NLopt options}
\alias{nl.opts}
\title{
  Setting NL Options
}
\description{
  Sets and changes the NLOPT options.
}
\usage{
nl.opts(optlist = NULL)
}
\arguments{
  \item{optlist}{list of options, see below.}
}
\details{
  The following options can be set (here with default values):

  \code{stopval = -Inf,         # stop minimization at this value}\cr
  \code{xtol_rel = 1e-6,        # stop on small optimization step}\cr
  \code{maxeval = 1000,         # stop on this many function evaluations}\cr
  \code{ftol_rel = 0.0,         # stop on change times function value}\cr
  \code{ftol_abs = 0.0,         # stop on small change of function value}\cr
  \code{check_derivatives = FALSE}
}
\value{
  returns a list with default and changed options.
}
\note{
  There are more options that can be set for solvers in NLOPT. These cannot
  be set through their wrapper functions. To see the full list of options and
  algorithms, type \code{nloptr.print.options()}.
}
\examples{
nl.opts(list(xtol_rel = 1e-8, maxeval = 2000))
}
