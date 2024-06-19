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
There was no ERROR and no WARNINGs.

There was 1 NOTE:

    * New maintainer:
        Aymeric Stamm <aymeric.stamm@cnrs.fr>
      Old maintainer(s):
        Aymeric Stamm <aymeric.stamm@math.cnrs.fr>

This is a change of email address. The maintainer is the same person.

## Downstream dependencies

We checked 145 reverse dependencies (136 from CRAN + 9 from Bioconductor), comparing R CMD check results across CRAN and dev versions of this package.

 * We saw 0 new problems
 * We failed to check 3 packages

Issues with CRAN packages are summarised below.

### Failed to check

* smam      (NA)
* spaMM     (NA)
* surveyvoi (NA)
