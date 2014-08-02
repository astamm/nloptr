# nloptr

[![Build Status](https://travis-ci.org/jyypma/nloptr.svg?branch=master)](https://travis-ci.org/jyypma/nloptr)

`nloptr` is an R interface to [NLopt](http://ab-initio.mit.edu/wiki/index.php/NLopt). NLopt is a free/open-source library for nonlinear optimization started by Steven G. Johnson, providing a common interface for a number of different free optimization routines available online as well as original implementations of various other algorithms. It can be used to solve general nonlinear programming problems with nonlinear constraints and lower and upper bounds for the controls, such as

```
                             min      f(x)
                           x in R^n
                           
                           s.t.       g(x) <= 0
                                      h(x)  = 0
                                lb <=   x  <= ub
```

The NLopt library is available under the GNU Lesser General Public License (LGPL), and the copyrights are owned by a variety of authors. See the [website](http://ab-initio.mit.edu/wiki/index.php/Citing_NLopt) for information on how to cite NLopt and the algorithms you use. The R interface to NLopt, also under LGPL, can be downloaded from [CRAN](http://cran.r-project.org/web/packages/nloptr/index.html) or [GitHub](https://github.com/jyypma/nloptr) (development version).

## Installation
For most versions of R `nloptr` can be installed from R with 
```
install.packages('nloptr')
```

### Development version
The most recent (experimental) version can be installed from source from GitHub
```
library('devtools')
install_github("jyypma/nloptr")
```
For this to work on Windows, you need to have Rtools and NLopt installed, and set an environment variable NLOPT_HOME with the location of the NLopt library.

## Disclaimer
This package is distributed in the hope that it may be useful to some. The usual disclaimers apply (downloading and installing this software is at your own risk, and no support or guarantee is provided, I don't take liability and so on), but please let me know if you have any problems, suggestions, comments, etc.

## Files

* [NLopt-2.4-win-build.zip](http://www.ucl.ac.uk/~uctpjyy/downloads/NLopt-2.4-win-build.zip) - static libraries of NLopt 2.4 compiled for Windows 32-bit and 64-bit.
* [nloptr.pdf](http://cran.r-project.org/web/packages/nloptr/vignettes/nloptr.pdf) - an R vignette describing how to use the R interface to NLopt.
* [INSTALL.windows](https://github.com/jyypma/nloptr/blob/master/INSTALL.windows) - description of how to install `nloptr` from source for Windows.

## Changelog 
A full version of the changelog can be found on [CRAN](http://cran.r-project.org/web/packages/nloptr/ChangeLog)

| Date       | Description |
| :---------- | :----------- |
| 27/01/2014 | Version 1.0.0 merged wrappers from the 'nloptwrap' package. |
| 19/11/2013 | Version 0.9.6 Added a line in Makevars to replace some code in NLopt to fix compilation on Solaris as requested by Brian Ripley. |
| 12/11/2013 | Version 0.9.5 Updated references from NLopt version 2.3 to NLopt version 2.4 in installation instructions. | in INSTALL.windows. Added a line in Makevars that replaces some code related to type-casting in NLopt-2.4/isres/isres.c. Changed encoding of src/nloptr.c from CP1252 to UTF-8. |
| 09/11/2013 | Version 0.9.4 updated NLopt to version 2.4. |
| 31/07/2013 | Version 0.9.3 was a maintainance release. |
| 11/07/2013 | Version 0.9.2 was a maintainance release. |
| 31/04/2013 | Version 0.9.0 has a new `print_level = 3`, and is compiled with NLopt version 2.3 with `--with-cxx option`. This makes the StoGo algorithm available. |
| 18/11/2011 | Version 0.8.9 removed some warnings from R CMD check and included some changes to the build process. |
| 28/09/2011 | Version 0.8.8 updated to compile on Solaris. |
| 03/09/2011 | Version 0.8.5 includes a working binary for MacOS. |
| 12/08/2011 | Version 0.8.4 includes a new function `nloptr.print.options`, and has new options (`print_options_doc`, and `population` and `ranseed` for stochastic global solvers). |
| 24/07/2011 | Version 0.8.3 has a finite difference derivative checker and includes checks to prevent adding constraints to a problem when the chosen algortihm does not allow for constraints. |
| 09/07/2011 | Version 0.8.2 is on CRAN with an updated build process and a newer version of NLopt. |
| 13/01/2011 | Version 0.8.1 contains an option print_level to control intermediate output. |

## Reference
Steven G. Johnson, The NLopt nonlinear-optimization package, [http://ab-initio.mit.edu/nlopt](http://ab-initio.mit.edu/nlopt)
