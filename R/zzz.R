.onLoad <- function(libname, pkgname) { #nocov start
  # Set the option to TRUE if it has not been set before.
  if (is.null(getOption('nloptr.show.inequality.warning')))
    options('nloptr.show.inequality.warning' = TRUE)
}

.onUnLoad <- function(libpath) {
  library.dynam.unload("nloptr", libpath)
} #nocov end
