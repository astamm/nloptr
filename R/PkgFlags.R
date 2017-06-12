## Provide compiler flags.
CFlags <- function( print = TRUE ) {
    if (.Platform$OS.type=="windows") {
        flags <- '-I"$(NLOPT_HOME)$(R_ARCH)/include"' 
    } else {
        flags <- '@PKG_CFLAGS@'
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
        flags <- '@PKG_LIBS@'
    }
    if ( print ) {
        cat( flags )
    } else {
        return( flags )
    }
}
