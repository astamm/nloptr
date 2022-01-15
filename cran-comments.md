## Resubmission
This is a resubmission. In this version I have:

* Corrected the bashism of sourcing a script with argument in both `configure` and `configure.win` files.
* Added the ability on Linux platforms to re-use an existing external build of NLopt instead of building from the included sources.

## Test environments
* local macOS R installation, R 4.1.2
* macOS latest release (via [R-CMD-check](https://github.com/r-lib/actions/blob/master/examples/check-standard.yaml) github action)
* windows latest release (via [R-CMD-check](https://github.com/r-lib/actions/blob/master/examples/check-standard.yaml) github action)
* ubuntu 20.04 latest both release and devel (via [R-CMD-check](https://github.com/r-lib/actions/blob/master/examples/check-standard.yaml) github action) using the *building nlopt from source* strategy
* ubuntu 20.04 latest release using the *reuse existing build of nlopt* strategy
* [win-builder](https://win-builder.r-project.org/) (release and devel)
* [R-hub](https://builder.r-hub.io)
  - Windows Server 2022, R-devel, 64 bit
  - Ubuntu Linux 20.04.1 LTS, R-release, GCC
  - Fedora Linux, R-devel, clang, gfortran
  - Debian Linux, R-devel, GCC ASAN/UBSAN

## R CMD check results
There was one ERROR on the winbuilder devel machine where `cmake` could be found.

There was no WARNINGs.

There were 3 NOTEs:

    * checking CRAN incoming feasibility ... NOTE
    Maintainer: ‘Aymeric Stamm <aymeric.stamm@math.cnrs.fr>’
    
    New maintainer:
      Aymeric Stamm <aymeric.stamm@math.cnrs.fr>
    Old maintainer(s):
      Jelmer Ypma <uctpjyy@ucl.ac.uk>
    
    Possibly mis-spelled words in DESCRIPTION:
      CMake (33:38, 35:29)

There is indeed a change of maintainer from Jelmer to myself.

    * checking installed package size ... NOTE
      installed size is  8.1Mb
      sub-directories of 1Mb or more:
        libs   7.6Mb

The size varies according to the system on which the package is installed.

    * checking line endings in C/C++/Fortran sources/headers ... NOTE
    Found the following sources/headers with CR or CRLF line endings:
      src/nlopt/x64/include/nlopt.f
      src/nlopt/x64/include/nlopt.hpp
      inst/include/nlopt.f
      inst/include/nlopt.hpp
    Some Unix compilers require LF line endings.

This NOTE appears only on Windows. These files are generated automatically upon compilation of NLopt.

## Downstream dependencies
I have also run R CMD check on downstream dependencies of [**nloptr**](https://astamm.github.io/nloptr/) using the [**revdepcheck**](https://r-lib.github.io/revdepcheck/) package. 
All 117 packages that I could install passed in the sense that either they install properly or they fail to install but already failed using the current released version of **nloptr**.
