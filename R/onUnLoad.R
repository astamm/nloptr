.onUnload <- function (libpath) {
    library.dynam.unload("nloptr", libpath)
}
