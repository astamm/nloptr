# Copyright (C) 2013 Jelmer Ypma and Lars Simon Zehnder
#
# This file is part of nloptr.
#
# nloptr is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.
#
# nloptr is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with nloptr. If not, see <http://www.gnu.org/licenses/>.

# We follow in our settings the CRAN 'Rcpp' package from the authors
# Dirk Eddelbuettel and Romain Francois.

# Make sure system.file returns an absolute path.
nloptr.system.file <- function( ... ){
    tools::file_path_as_absolute( base::system.file( ..., package = "nloptr" ) )
}

# Identifies if the default linking on the platform should be static
# or dynamic. Currently only LINUX uses dynamic linking by default
# although it works fine on MAC OSX as well.
staticLinking <- function() {
    !grepl( "^linux", R.version$os )
}

## Use R's internal knowledge of path settings to find the nloptr/lib/ directory
## plus optionally an arch-specific directory on system building multi-arch.
nloptrLdPath <- function() {
    if ( nzchar( .Platform$r_arch ) ) {	## eg amd64, ia64, mips
        path <- nloptr.system.file( "lib",.Platform$r_arch )
    } else {
        path <- nloptr.system.file( "lib" )
    }
    path
}

# Provide linker flags -- i.e. -L/path/to/libnloptcxx -- as well as an
# optional rpath call needed to tell the LINUX dynamic linker about the
# location. We default to static linking but allow the use of rpath on 
# LINUX if static==FALSE has been chosen.
# Note that this is probably being called from LdFlags()
nloptrLdFlags <- function( static = staticLinking() ) {
    nloptrdir <- nloptrLdPath()
    if ( static ) {                               # static is default on WINDOWS and OS X
        flags <- paste( nloptrdir, "/libnlopt_cxx.a", sep = "" )
        if ( .Platform$OS.type == "windows" ) {
            flags <- Rcpp:::asBuildPath( flags )
        }
    } else {					# else for dynamic linking
        flags <- paste( "-L", nloptrdir, " -lnlopt_cxx", sep = "" ) # baseline setting
        if ( ( .Platform$OS.type == "unix" ) &&    # on LINUX, we can use rpath to encode path
            ( length( grep( "^linux", R.version$os ) ) ) ) {
            flags <- paste( flags, " -Wl,-rpath,", nloptrdir, sep = "" )
        }
    }
    invisible( flags )
}

# TODO: Do we even need these. I would delete this function
# (Simon, @2013.10.28) 
# Provide compiler flags -- i.e. -I/path/to/nloptr.hpp
nloptrCxxFlags <- function() {
    # path <- nloptrLdPath()
    path <- nloptr.system.file( "include" )
    if ( .Platform$OS.type == "windows" ) {
        path <- asBuildPath( path )
    }
    paste( "-I", path, sep = "" )
}

# LdFlags defaults to static linking on the non-LINUX platforms WINDOWS 
# and OS X
LdFlags <- function( static = staticLinking() ) {
    cat(nloptrLdFlags(static = static ) )
}
