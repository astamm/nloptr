## Resubmission

We now cast `print_level` in `nloptr.c` as `int` instead of `unsigned int`
as some packages like **pgcs** use negative print levels. This fixes newly
broken **pgsc** package. See PR[#185](https://github.com/astamm/nloptr/pull/185)
and related issues [#184](https://github.com/astamm/nloptr/issues/184) and
[#2](https://github.com/philipbarrett/pgsc/issues/2).

## Test environments
* local macOS R installation, R 4.4.3
* continuous integration via GH actions:
  * macOS latest release
  * windows latest release
  * windows latest release with Rtools42
  * Ubuntu 24.04.2 LTS latest release and devel using the *building nlopt from source*
  strategy
  * Ubuntu 24.04.2 LTS latest release using the *reuse existing build of nlopt*
  strategy
  * Ubuntu 24.04.2 LTS against all versions of nlopt since `2.7.0`.
* [win-builder](https://win-builder.r-project.org/) (release and devel) NOTHING TO DO
* [macOS-builder](https://mac.r-project.org/macbuilder/submit.html) CHECKER BROKEN
* [R-hub](https://builder.r-hub.io)
  - All R versions on GitHub Actions ubuntu-latest
  - All R versions on GitHub Actions macos-13
  - All R versions on GitHub Actions macos-latest
  - All R versions on GitHub Actions windows-latest
  - R Under development (unstable) (2024-06-14 r86747) on Ubuntu 22.04.4 LTS
   ghcr.io/r-hub/containers/clang-asan:latest

## R CMD check results
There was no ERROR, no WARNING and no NOTE.

## Downstream dependencies

We checked 160 reverse dependencies (151 from CRAN + 9 from Bioconductor), comparing R CMD check results across CRAN and dev versions of this package.

 * We saw 4 new problems: **PLNmodels**, **missSBM**, **rkriging** and
 **garma**. All package maintainers have been informed and will soon submit a
 release to CRAN with a fix.
 
 * We failed to check 3 packages

Issues with CRAN packages are summarised below.

### Failed to check

* smam      (NA)
* spaMM     (NA)
* surveyvoi (NA)
