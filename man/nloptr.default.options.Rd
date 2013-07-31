\name{nloptr.default.options}
\docType{data}
\alias{nloptr.default.options}
\title{Description and default values of nloptr options}
\description{
  This \code{data.frame} gives shows the options that can be used when solving
  a minimization problem using \code{nloptr}. For internal use.
}
\usage{nloptr.default.options}
\format{
	\tabular{ll}{
		name						\tab name of the option \cr
		type						\tab type (numeric, logical, integer, character) \cr
		possible_values				\tab string explaining the values the option can take \cr
		default						\tab default value of the option (as a string) \cr
		is_termination_condition	\tab is this option part of the termination conditions? \cr
		description					\tab description of the option (taken from NLopt website if it's an option that is passed on to NLopt). \cr
    }
}
\author{
Jelmer Ypma
}
\seealso{
\code{\link[nloptr:nloptr]{nloptr}}
}	
\keyword{datasets}
