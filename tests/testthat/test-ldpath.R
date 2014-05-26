
require( "testthat" )
require( "nloptr" )
context( "LdPath Functions" )

test_that( "Test Ldpath functions", {

    # Absolute path to the nloptr library
    abs.path <- nloptr:::nloptr.system.file()
    abs.true <- file.path( base:::.libPaths()[1], "nloptr" )

    # Static linking 
    static.link <- nloptr:::staticLinking() 

    # Library path 
    nloptrld.path <- nloptr:::nloptrLdPath()
    nloptrld.true <- file.path( abs.true, "lib" )

    # Linker flags (Not testable return invisible())

    # Library path and name plus linker flags 
    # LdFlags() uses 'cat()' for output we have to 
    # redirect it to a temporary file and then use
    # readLines
    tmpf <- tempfile()
    sink( tmpf )
    nloptr:::LdFlags()
    sink()
    ld.flags <- readLines( tmpf, warn = FALSE )
    ld.true  <- file.path( nloptrld.true, "libnlopt_cxx.a" )

    # Check results
    # Absolute path
    expect_that( identical( abs.true, abs.path ), is_true() )

    # Static linking
    if ( ! grepl( "^linux", R.version$os ) ) {
        expect_that( static.link, is_true() )
    } else {
        expect_that( static.link, is_false() )
    }

    # Library path 
    if ( nzchar( .Platform$r_arch ) ) {
   
        nloptrld.true <- file.path(nloptrld.true, .Platform$r_arch)
        expect_that(identical(nloptrld.true, nloptrld.path), is_true())

    } else {
    
        expect_that(identical(nloptrld.true, nloptrld.path), is_true())
    
    }
    
    # Library oath and name plus linker flags
    if ( static.link ) {
        
        if ( .Platform$OS.type == "windows" ) {
            
            # Rcpp:::asBuildPath converts a path to
            # to the canonical form on Windows
            # (calls windows functions like utils::shortPathName()) 
            ld.true <- Rcpp:::asBuildPath( ld.true )                      
            expect_that( identical( ld.true, ld.flags ), is_true() )

        } else {
        
            expect_that( identical( ld.true, ld.flags ), is_true() )
                
        }
    
    } else {
        
        ld.true <- paste( "-L", nloptrld.true, " -lnlopt_cxx", sep = "" ) 
        if ( ( .Platform$OS.type == "unix" ) && 
            ( length( grep( "^linux", R.version$os ) ) ) ) {
            
            ld.true <- paste( ld.true, " -Wl,-rpath,", nloptrld.true, sep = "" )
       
        }
    
    }
    
    expect_that( identical( ld.true, ld.flags ), is_true() )

} )
