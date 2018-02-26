#' translateVTT
#'
#' Translation function for vtt files. Function will be able to send your vtt
#' file for translation in Google Translate API and return proper strucuture of
#' the file back. Note: Google Tranlation with API is paid service, however
#' 300USD is given for free for 12 month.
#'
#' To do: use http://r-pkgs.had.co.nz/tests.html to write test for this package
#'
#' @param fileName Path to the file you want to translate. Only one file name is
#'   accepted at the time
#' @param sourceLang Source language code, 'en' is default value.
#' @param destLang Destination language for translator function. Only one at the
#'   time
#' @param apikey Google Translate API key
#' @return Function does not return value. It is generating new file adding
#'   language code before .vtt
#' @export
#'
#'
#'
#' @examples
#'
#' ## Not run:
#' # send one vtt file for translation
#' translateVTT(fileName = "L0.vtt",
#'              sourceLang = "en",
#'              destLang = "es",
#'              apikey = google.api.key)
#'
#' ## send multiple files for translations
#'
#' # create list of files to translate
#' filesToTranslate <-list.files("~Files/Downloads/", pattern="*.vtt", full.names=TRUE)
#'
#' # make a list of languages
#' languages <- c("fr", "tr", "it", "id", "pt", "es", "ms", "de")
#'
#' # for loop (note translation takes a while 100 translations ~ 1 hour)
#' for (FILE in filesToTranslate) {
#'  # for loop for languages
#'   for (LANG in languages) {
#'    # translation
#'    translateVTT(fileName = FILE, sourceLang = "en", destLang = LANG, apikey = api_key)
#'   }
#' }
#'
#' ## End(Not run)
#'
translateVTT <- function(fileName, sourceLang = "en", destLang, apikey){

  # check if the required packages are installed
  if (!requireNamespace(c("tibble", "tidyverse", "translateR", "readr", "utils"), quietly = TRUE)) {
    stop("Pkg needed for this function to work. Please install it.",
         call. = FALSE)
  }


  require(tidyverse)
  require(translateR)

  # read file -> it will be a dataframe
  t <- read_delim(fileName, delim = "\t", col_types = "c") %>% as.data.frame.data.frame()

  # extract logical vector indicating which rows containing timestamps
  x <- t %>%
    # detect rows with date time (those for not translate)
    apply(MARGIN = 1, str_detect, pattern = "-->")

  # extract only rows containing text (e.g. not containing timestamps)
  txt <- subset.data.frame(t, !x)
  # extract only time stamps
  tst <- subset.data.frame(t,  x)

  ## translate this file using translate API paid service in Google

  # translate object txt or file in R
  # Google, translate column in dataset
  google.dataset.out <- translateR::translate(dataset = txt,
                                  content.field = 'WEBVTT',
                                  google.api.key = apikey,
                                  source.lang = sourceLang,
                                  target.lang = destLang)

  # extract only new column
  trsltd <- google.dataset.out %>% dplyr::select(translatedContent)

  # give original name
  colnames(trsltd) <- "WEBVTT"


  # bind rows with original timestamps
  abc <- rbind(tst, trsltd)

  # order this file back again
  bcd <-  abc[ order(as.numeric(row.names(abc))), ] %>% as.character %>% as.data.frame()

  # return original name
  colnames(bcd) <- "WEBVTT"

  # adding one row in the beginning
  bcd <- tibble::as.tibble(bcd)
  # add one row
  bcd2 <- tibble::add_row(bcd, WEBVTT  = "", .before = 1)

  # write this file back :_)
  #fileName <- "C:/Users/fxtrams/Downloads/L1.vtt"
  #destLang <- "de"
  readr::write_delim(bcd2, paste0(fileName, destLang, ".vtt"), delim = "\t")

}

