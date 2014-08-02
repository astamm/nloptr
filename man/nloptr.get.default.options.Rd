\name{nloptr.get.default.options}
\alias{nloptr.get.default.options}
\title{
Return a data.frame with all the options that can be supplied to nloptr.
}
\description{
This function returns a data.frame with all the options that can be supplied to \code{\link[nloptr:nloptr]{nloptr}}. The data.frame contains the default values of the options and an explanation. A user-friendly way to show these options is by using the function \code{\link[nloptr:nloptr.print.options]{nloptr.print.options}}.
}
\usage{
nloptr.get.default.options()
}
\value{
The return value contains a \code{data.frame} with the following elements
    \item{name}{name of the option}
	\item{type}{type (numeric, logical, integer, character)}
	\item{possible_values}{string explaining the values the option can take}
	\item{default}{default value of the option (as a string)}
	\item{is_termination_condition}{is this option part of the termination conditions?}
	\item{description}{description of the option (taken from NLopt website if it's an option that is passed on to NLopt).}
}
\author{
Jelmer Ypma
}
\seealso{
\code{\link[nloptr:nloptr]{nloptr}}
\code{\link[nloptr:nloptr.print.options]{nloptr.print.options}}
}
\keyword{ optimize }
\keyword{ interface }
