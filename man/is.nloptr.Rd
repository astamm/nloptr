\name{is.nloptr}
\alias{is.nloptr}
\title{
R interface to NLopt
}
\description{
is.nloptr preforms checks to see if a fully specified problem is supplied to nloptr. Mostly for internal use.
}
\usage{
is.nloptr( x )
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{x}{
object to be tested.
  }
}
\value{
    Logical. Return TRUE if all tests were passed, otherwise return FALSE or exit with Error.
}
\author{
Jelmer Ypma
}
\seealso{
\code{\link[nloptr:nloptr]{nloptr}}
}

% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ optimize }
\keyword{ interface }
