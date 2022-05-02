## Test environments
* local macOS R installation, R 4.1.3
* continuous integration via GH actions:
  * macOS latest release
  * windows latest release
  * windows latest release with Rtools42
  * ubuntu 20.04 latest release and devel using the *building nlopt from source* strategy
  * ubuntu 20.04 latest release using the *reuse existing build of nlopt* strategy
* [win-builder](https://win-builder.r-project.org/) (release and devel)
* [macOS-builder](https://mac.r-project.org/macbuilder/submit.html)
* [R-hub](https://builder.r-hub.io)
  - Windows Server 2022, R-devel, 64 bit
  - Ubuntu Linux 20.04.1 LTS, R-release, GCC
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

    * checking for detritus in the temp directory ... NOTE
    Found the following files/directories:
      'lastMiKTeXException'

This NOTE appears only on Windows.

## Downstream dependencies
I have also run R CMD check on downstream dependencies of [**nloptr**](https://astamm.github.io/nloptr/) using the [**revdepcheck**](https://r-lib.github.io/revdepcheck/) package. 
Out of the 114 packages that had a hard dependency on `nloptr`, only three of them failed to install, namely `missSBM`, `mssm` and `PLNmodels`. Package maintainers have been contacted and I contributed the fix to all 3 of them. You should receive new submissions from them soon.
