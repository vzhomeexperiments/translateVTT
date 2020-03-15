#' Translation function for vtt files.
#'
#' @description Function will be able to send vtt file for translation
#' in Google Translate API and return proper strucuture of
#' the file back.
#'
#' @details Google Tranlation with API is paid service, however
#' 300USD is given for free for 12 month, check clould.google.com
#'
#' @param fileName String with a path to the file you want to translate.
#'   Only one file name is accepted at the time
#' @param sourceLang Source language code, 'en' is default value.
#' @param destLang Destination language for translator function. Only one at the
#'   time
#' @param apikey Google Translate API key
#' @return Function does not return value. It is generating new file adding
#'   language code before .vtt
#' @export
#'
#' @author (C) 2019 Vladimir Zhbanko
#'
#' @examples
#'
#' \donttest{
#'
#' library(openssl)
#' library(readr)
#' library(magrittr)
#' library(stringr)
#' library(translateVTT)
#' library(translateR)
#'
#' # retrieve filename
#' file_name <- system.file("extdata", "L0.vtt", package = "translateVTT")
#'
#' path_ssh <- normalizePath(tempdir(),winslash = "/")
#'
#' path_private_key <- file.path(path_ssh, "id_api")
#'
#' # decrypt the key
#' out <- read_rds(file.path(path_ssh, "api_key.enc.rds"))
#' google.api.key <- decrypt_envelope(out$data,
#'                                    out$iv,
#'                                    out$session,
#'                                    path_private_key,
#'                                    password = "") %>%
#'                   unserialize()
#'
#' # send one vtt file for translation
#' translateVTT(fileName = file_name,
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
#' }
#'
translateVTT <- function(fileName, sourceLang = "en", destLang, apikey){

  #fileName = file_name
  # check if the required packages are installed
  if (!requireNamespace(c("tibble", "magrittr", "openssl", "stringr",
                          "translateR", "readr", "utils"), quietly = TRUE)) {
    stop("Pkg needed for this function to work. Please install it.",
         call. = FALSE)
  }


  requireNamespace("magrittr", quietly = TRUE)
  requireNamespace("tibble", quietly = TRUE)
  requireNamespace("readr", quietly = TRUE)
  requireNamespace("stringr", quietly = TRUE)
  requireNamespace("translateR", quietly = TRUE)

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
  bcd <- as_tibble(bcd)
  # add one row
  bcd2 <- add_row(bcd, WEBVTT  = "", .before = 1)

  # write this file back :_)
  #fileName <- "~Files/Downloads/L1.vtt"
  #destLang <- "de"
  write_delim(bcd2, paste0(fileName, destLang, ".vtt"), delim = "\t")

}

