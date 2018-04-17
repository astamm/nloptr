# Build against mingw-w64 build of nlopt
if(!file.exists("../windows/nlopt-2.4.2/include/nlopt.hpp")){
    if(getRversion() < "3.3.0") setInternet2()
    download.file("https://github.com/rwinlib/nlopt/archive/v2.4.2.zip", "lib.zip", quiet = TRUE)
    dir.create("../windows", showWarnings = FALSE)
    unzip("lib.zip", exdir = "../windows")
    unlink("lib.zip")
}
