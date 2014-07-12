## -*- mode: autoconf; autoconf-indentation: 4; -*-
##
##  nloptr configure.ac
##
##  nloptr -- R interface to NLopt
##
##  Copyright (C) 2014  Dirk Eddelbuettel 
##
##  To conform with the license of nloptr, this file is licensed under LGPL-3

# require at least autoconf 2.61
AC_PREREQ(2.61)

# Process this file with autoconf to produce a configure script.
AC_INIT([nloptr], [1.0.1])

# We are using C++
AC_LANG(C++)
AC_REQUIRE_CPP
AC_PROG_CXX

## check for pkg-config
AC_DEFUN([AC_PROG_PKGCONFIG], [AC_CHECK_PROG(PKGCONFIG,pkg-config,yes)])
AC_PROG_PKGCONFIG

## use pkg-config for NLopt
##
if test x"${PKGCONFIG}" == x"yes"; then
    ## check via pkg-config for hiredis
    if pkg-config --exists nlopt; then
        ## obtain cflags and obtain libs
        nlopt_cflags=`pkg-config --cflags nlopt`
        nlopt_libs=`pkg-config --libs nlopt`
    else
        nlopt_cflags=""
        nlopt_libs=""
    fi
else
    ## Add a reasonable default of -lnlopt if we don't have pkg-config
    hiredis_cxxflags=""
    hiredis_libs="-lnlopt -lm"
fi

## And make sure these flags are used for the tests below.
CPPFLAGS="${nlopt_cflags} ${CPPFLAGS}"
CXXFLAGS="${nlopt_cflags} ${CXXFLAGS}"


## check for headers Debian has in libhiredis-dev
nlopt_header=nlopt.h
nlopt_header_cache_var=AS_TR_SH([ac_cv_header_$nlopt_header])
AC_CHECK_HEADER([$nlopt_header],,
                [       
		# If it didn't work, try adding /usr/local directly then trying again
		AC_MSG_WARN([NLopt headers not found with via default CXXFLAGS and CPPFLAGS, trying /usr/local/include])
		CPPFLAGS="${nlopt_cxxflags} ${CPPFLAGS} -I/usr/local/include"
		CXXFLAGS="${nlopt_cxxflags} ${CXXFLAGS} -I/usr/local/include -L/usr/local/lib"
		# unset the cache variable for this particular header check
		# so we can check again with different defaults specified.
		AC_MSG_WARN([Unsetting $nlopt_header_cache_var])
		AS_UNSET([$nlopt_header_cache_var])
		AC_CHECK_HEADER([$nlopt_header],,
		[AC_MSG_ERROR([ERROR: NLopt headers required; use '-Iincludedir' in CXXFLAGS for unusual locations.])])
		])

## could check for minimal suitable version here

## now use all these
AC_SUBST([PKG_CFLAGS],["${PKG_CFLAGS} $nlopt_cflags"])
AC_SUBST([PKG_LIBS],["${PKG_LIBS} $nlopt_libs"])
AC_CONFIG_FILES([src/Makevars])
AC_OUTPUT
echo "Completed configuration and ready to build."

