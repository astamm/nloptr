## Test environments
* local macOS R installation, R 4.1.1
* macOS latest release (via [R-CMD-check](https://github.com/r-lib/actions/blob/master/examples/check-standard.yaml) github action)
* windows latest release (via [R-CMD-check](https://github.com/r-lib/actions/blob/master/examples/check-standard.yaml) github action)
* ubuntu 20.04 latest both release and devel (via [R-CMD-check](https://github.com/r-lib/actions/blob/master/examples/check-standard.yaml) github action)
* [win-builder](https://win-builder.r-project.org/) (release and devel)
* [R-hub](https://builder.r-hub.io)
  - Windows Server 2008 R2 SP1, R-devel, 32/64 bit
  - Ubuntu Linux 20.04.1 LTS, R-release, GCC
  - Fedora Linux, R-devel, clang, gfortran
  - Debian Linux, R-devel, GCC ASAN/UBSAN

## R CMD check results
There were no ERRORs or WARNINGs.

There were 4 NOTEs:

    * checking CRAN incoming feasibility ... NOTE
    Maintainer: ‘Aymeric Stamm <aymeric.stamm@math.cnrs.fr>’
    
    New maintainer:
      Aymeric Stamm <aymeric.stamm@math.cnrs.fr>
    Old maintainer(s):
      Jelmer Ypma <uctpjyy@ucl.ac.uk>

Jelmer asked me to become maintainer of his package.

    * checking installed package size ... NOTE
      installed size is  8.1Mb
      sub-directories of 1Mb or more:
        libs   7.6Mb

The size varies according to the system on which the package is installed.

    * checking top-level files ... NOTE
      possible bashism in configure line 13 (sourced script with arguments):
      . ./scripts/r_config.sh ""

Despite this bashism, it seems to work on all platforms.

    * checking line endings in C/C++/Fortran sources/headers ... NOTE
    Found the following sources/headers with CR or CRLF line endings:
      src/nlopt/x64/include/nlopt.f
      src/nlopt/x64/include/nlopt.hpp
      inst/include/nlopt.f
      inst/include/nlopt.hpp
    Some Unix compilers require LF line endings.

These files are generated automatically upon compilation of NLopt.

## Downstream dependencies
I have also run R CMD check on downstream dependencies of [**nloptr**](https://astamm.github.io/nloptr/) using the [**revdepcheck**](https://r-lib.github.io/revdepcheck/) package. 
All 117 packages that I could install passed: (https://github.com/wch/checkresults/blob/master/nloptr/r-release).
