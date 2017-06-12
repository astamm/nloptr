## Provide compiler flags.
CFlags <- function( print = TRUE ) {
    if (.Platform$OS.type=="windows") {
        flags <- '-I"$(NLOPT_HOME)$(R_ARCH)/include"' 
    } else {
        flags <- '  -I/home/foranw/src/world/R/nloptr/nlopt-2.4.2/include'
    }
    if ( print ) {
        cat( flags )
    } else {
        return( flags )
    }
}

## Provide linker flags.
LdFlags <- function( print = TRUE ) {
    if (.Platform$OS.type=="windows") {
        flags <- '-L"$(NLOPT_HOME)$(R_ARCH)/lib" -lnlopt_cxx'
    } else {
        flags <- '  -lm /home/foranw/src/world/R/nloptr/nlopt-2.4.2/lib/libnlopt_cxx.a'
    }
    if ( print ) {
        cat( flags )
    } else {
        return( flags )
    }
}
