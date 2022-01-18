## Resubmission 2
This is a resubmission. In this version I have:

* Switched to only message (but not error) if a system NLopt was found, but is older than 2.7.0 (contributed by Dirk Eddelbuettel, #95).
* Updated the `DESCRIPTION` file to make it clearer about the various strategies for building NLopt (contributed by Dirk Eddelbuettel, #95).
* Switched to searching `cmake` first on the `PATH` and then at a macOS-specific location.

## Resubmission 1
This is a resubmission. In this version I have:

* Corrected the bashism of sourcing a script with argument in both `configure` and `configure.win` files.
* Used [CMake](https://cmake.org) to build `nlopt` from included sources only on macOS and or on Linux if no system build is found.
* Updated NLopt version to latest i.e. 2.7.1.
* Put back the ability on Linux platforms to re-use an existing external build of NLopt instead of building from the included sources (contributed by Dirk Eddelbuettel, #88).
* Added a new way of building on Windows using `rwinlib` (contributed by Jeroen Ooms, #92).

## Test environments
* local macOS R installation, R 4.1.2
* continuous integration via GH actions:
  * macOS latest release
  * windows latest release
  * windows 2022 devel
  * ubuntu 20.04 latest release and devel using the *building nlopt from source* strategy
  * ubuntu 20.04 latest release using the *reuse existing build of nlopt* strategy
* [win-builder](https://win-builder.r-project.org/) (release and devel)
* [R-hub](https://builder.r-hub.io)
  - Windows Server 2022, R-devel, 64 bit
  - Ubuntu Linux 20.04.1 LTS, R-release, GCC
  - Fedora Linux, R-devel, clang, gfortran
  - Debian Linux, R-devel, GCC ASAN/UBSAN

## R CMD check results
There was no ERROR and no WARNINGs.

There were 4 NOTEs:

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
      inst/include/nlopt.f
      inst/include/nlopt.hpp
    Some Unix compilers require LF line endings.

    * checking for detritus in the temp directory ... NOTE
    Found the following files/directories:
      'lastMiKTeXException'

These NOTEs appear only on Windows.

## Downstream dependencies
I have also run R CMD check on downstream dependencies of [**nloptr**](https://astamm.github.io/nloptr/) using the [**revdepcheck**](https://r-lib.github.io/revdepcheck/) package. 
All 115 packages that I could install passed in the sense that either they install properly or they fail to install but already failed using the current released version of **nloptr**.
