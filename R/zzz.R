.onLoad <- function(libname = find.package("translateVTT"), pkgname = "translateVTT") {

  #op <- options()
  #the_tempdir <- tempdir()

  # CRAN Note avoidance
  if(getRversion() >= "2.15.1")
    utils::globalVariables(
      # sample variable names and functions
      c("%>%", "add_row", "as_tibble", "encrypt_envelope", "read_delim", "str_detect",
        "translatedContent", "write_delim", "write_rds"
      )
    )




  invisible(NULL)
}
