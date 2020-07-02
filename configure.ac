## -*- mode: autoconf; autoconf-indentation: 4; -*-
##
##  nloptr configure.ac
##
##  nloptr -- R interface to NLopt
##
##  Copyright (C) 2014  Dirk Eddelbuettel
##
## This file is licensed under the GPL-2 or later just like most of my
## Open Source code, and is granted an exemption (should it be needed)
## for inclusion into nloptr
##
## History:
##   2020-02-26 (JY): Removed references to CPPFLAGS.
##   2020-02-26 (JY): Changed CPP to $CC -E and CXXCPP to $CXX -E as support
##     for these flags in R CMD config is deprecated from R 3.6.2.

# require at least autoconf 2.61
AC_PREREQ(2.61)

# Process this file with autoconf to produce a configure script.
AC_INIT([nloptr], [1.0.1])

## consider command-line options if given
##
AC_ARG_WITH([nlopt-cflags],
            AC_HELP_STRING([--with-nlopt-cflags=CFLAGS],
                           [Supply compiler flags such as the location of NLopt header files]),
            [nlopt_cflags=$withval],
            [nlopt_cflags=""])
AC_ARG_WITH([nlopt-libs],
            AC_HELP_STRING([--with-nlopt-libs=LIBS],
                           [Supply the linker flags such as the location and name of NLopt libraries]),
            [nlopt_libs=$withval],
            [nlopt_libs=""])

## Set R_HOME, respecting an environment variable if set
: ${R_HOME=$(R RHOME)}
if test -z "${R_HOME}"; then
 AC_MSG_ERROR([Could not determine R_HOME.])
fi

## Get R compilers and flags.
## Add user-supplied flags to flags specified by R if they have been set.
CC=$("${R_HOME}/bin/R" CMD config CC)
CFLAGS="$("${R_HOME}/bin/R" CMD config CFLAGS) ${CFLAGS}"
CPP="$("${R_HOME}/bin/R" CMD config CC) -E"
CXX=$("${R_HOME}/bin/R" CMD config CXX)
CXXFLAGS="$("${R_HOME}/bin/R" CMD config CXXFLAGS) ${CXXFLAGS}"
CXXCPP="$("${R_HOME}/bin/R" CMD config CXX) -E"
AR=$("${R_HOME}/bin/R" CMD config AR)
RANLIB=$("${R_HOME}/bin/R" CMD config RANLIB)

# We are using C++
AC_LANG(C++)
AC_REQUIRE_CPP
AC_PROG_CXX

## check for pkg-config
AC_DEFUN([AC_PROG_PKGCONFIG], [AC_CHECK_PROG(PKGCONFIG,pkg-config,yes)])
AC_PROG_PKGCONFIG

## default to assuming no sufficient NLopt library has been found
nlopt_good="no"
nlopt_cflags=""
nlopt_libs=""

## also use pkg-config to check for NLopt
##
if test x"${nlopt_libs}" == x""; then
    if test x"${PKGCONFIG}" == x"yes"; then
        ## check via pkg-config for nlopt
        if pkg-config --exists nlopt; then
            ## obtain cflags and obtain libs
            nlopt_cflags=$(pkg-config --cflags nlopt)
            nlopt_libs=$(pkg-config --libs nlopt)
            nlopt_good="yes"
        fi
    fi
fi


## And make sure these flags are used for the test below.
CPPFLAGS="${nlopt_cflags}"
CXXFLAGS="${nlopt_cflags} ${CXXFLAGS}"

## check for headers Debian has in libhiredis-dev
AC_MSG_NOTICE([Now testing for NLopt header file.])
nlopt_header=nlopt.h
AC_CHECK_HEADER([$nlopt_header],
                [nlopt_good="yes"],  # may want to check for minimal version here too
                [nlopt_good="no"],
                [])

## Check for NLopt version number using pkg-config.
# Perform this check after the header check,
# because the correct header with the wrong
# version, does not work.
if test x"${nlopt_good}" = x"yes"; then
    AC_MSG_NOTICE([Now testing for NLopt version 2.4.0 or greater.])
    if test x"${PKGCONFIG}" == x"yes"; then
        ## check via pkg-config for version number of nlopt
        if pkg-config --exists nlopt; then
            ## obtain version number
            nlopt_version=$(pkg-config --modversion nlopt)

            case ${nlopt_version} in
                 1.*|2.0.*|2.1.*|2.2.*|2.3.*)
                    AC_MSG_WARN([Only NLopt version 2.4.0 or greater can be used with nloptr.])
                    nlopt_good="no"
                ;;
            esac
        fi
    else
        AC_MSG_WARN([Could not test version of NLopt because pkg-config is not installed. Make sure the version number of NLopt is 2.4.0 or greater. Otherwise nloptr can not be used.])
    fi
fi

## in case neither of the two methods above worked, build NLopt locally
## from included source files.
if test x"${nlopt_good}" = x"no"; then
   AC_MSG_NOTICE([Need to configure and build NLopt])

   ## Libraries necessary to link with NLopt
   NLOPTR_LIBS="-lm $(pwd)/src/nlopt_src/lib/libnlopt_cxx.a"

   ## Necessary Include dirs
   NLOPTR_INCL="-I$(pwd)/src/nlopt_src/include"

   ## Get flags that have been re-defined above
   ## to test whether NLopt headers are present.
   NLOPT_CXXFLAGS=$("${R_HOME}/bin/R" CMD config CXXFLAGS)

   ## Compile NLopt source code and clean up
   ## --prefix="`pwd`", which is the directory we want to
   ## install in, after we changed our current directory
   AC_MSG_NOTICE([Starting to install library to $(pwd)/src/nlopt_src])
   (cd src/nlopt_src; \
        ./configure --prefix="$(pwd)" --enable-shared --enable-static --without-octave \
                    --without-matlab --without-guile --without-python --with-cxx \
		    AR="${AR}" RANLIB="${RANLIB}" \
                    CC="${CC}" CFLAGS="${CFLAGS}" CPP="${CPP}" CXX="${CXX}" \
                    CXXFLAGS="${NLOPT_CXXFLAGS}" CXXCPP="${CXXCPP}" && \
        make && make install && rm -rf .libs) || exit 1
   AC_MSG_NOTICE([Done installing library to $(pwd)/src/nlopt_src])

   ## Copy header files to inst/include such that they are available from R.
   mkdir -p inst/include
   cp src/nlopt_src/include/* inst/include

   ## Store compiler and linker flags
   makevars_nlopt_cflags="${CFLAGS} ${NLOPTR_INCL}"
   makevars_nlopt_libs="${NLOPTR_LIBS}"
   nlopt_libs="-lm"

else
   AC_MSG_NOTICE([Suitable NLopt library found.])
fi

## could add a test of building a three-liner here

## now use all these
AC_SUBST([MAKEVARS_PKG_CFLAGS],["${PKG_CFLAGS} $nlopt_cflags $makevars_nlopt_cflags"])
AC_SUBST([MAKEVARS_PKG_LIBS],["${PKG_LIBS} $nlopt_libs $makevars_nlopt_libs"])
AC_SUBST([PKG_CFLAGS],["${PKG_CFLAGS} $nlopt_cflags"])
AC_SUBST([PKG_LIBS],["${PKG_LIBS} $nlopt_libs"])
AC_CONFIG_FILES([src/Makevars R/PkgFlags.R])
AC_OUTPUT
