## Test environments
* local macOS R installation, R 4.4.0
* continuous integration via GH actions:
  * macOS latest release
  * windows latest release
  * windows latest release with Rtools42
  * ubuntu 22.04 latest release and devel using the *building nlopt from source*
  strategy
  * ubuntu 22.04 latest release using the *reuse existing build of nlopt*
  strategy
* [win-builder](https://win-builder.r-project.org/) (release and devel)
* [macOS-builder](https://mac.r-project.org/macbuilder/submit.html) NOTHING TO DO
* [R-hub](https://builder.r-hub.io)
  - Windows Server 2022, R-devel, 64 bit
  - Ubuntu Linux 22.04.1 LTS, R-release, GCC
  - Fedora Linux, R-devel, clang, gfortran
  - Debian Linux, R-devel, GCC ASAN/UBSAN

## R CMD check results
There was no ERROR and no WARNINGs.

There were 2 NOTEs:

    * checking installed package size ... NOTE
      installed size is 12.2Mb
      sub-directories of 1Mb or more:
        libs  11.8Mb

The size varies according to the system on which the package is installed.

    * New maintainer:
        Aymeric Stamm <aymeric.stamm@cnrs.fr>
      Old maintainer(s):
        Aymeric Stamm <aymeric.stamm@math.cnrs.fr>

This is a change of email address. The maintainer is the same person.

    * checking for detritus in the temp directory ... NOTE
    Found the following files/directories:
      'lastMiKTeXException'

This NOTE appears only on Windows.

## Downstream dependencies
We checked 118 reverse dependencies (111 from CRAN + 7 from Bioconductor),
comparing R CMD check results across CRAN and dev versions of this package.

 * We saw 0 new problems
 * We failed to check 0 packages
