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
# along with nloptr.  If not, see <http://www.gnu.org/licenses/>.

# TODO: If this plugin should also be available for C
# developers, we must add another one that includes
# 'nlopt.h' (Simon, @2013.10.23)

# When 'cxxfunction' from the 'inline' package is called, it
# searches in the package for an object called 'inlineCxxPlugin'.
# This is the hook packages use to register their plugins to 
# the 'cxxfunction'.
# 'nloptr:::nloptrLdFlags()' returns the path to the library
# in the /libs folder of the installed 'nloptr' package. 
inlineCxxPlugin <- Rcpp:::Rcpp.plugin.maker( include.before = "#include <nlopt.hpp>",
    libs = file.path( nloptr:::nloptrLdPath(), "libnlopt_cxx.a" ), package = "nloptr",
    Makevars = FALSE, Makevars.win = FALSE
)

