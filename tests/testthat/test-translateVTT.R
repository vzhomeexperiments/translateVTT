library(testthat)
library(readr)
library(magrittr)
library(stringr)

context('translateVTT')

test_that("text split works", {

  # retrieve filename
  file_name <- system.file("extdata", "L0.vtt", package = "translateVTT")

  # read file -> it will be a dataframe
  t <- read_delim(file_name, delim = "\t", col_types = "c") %>% as.data.frame.data.frame()

  # extract logical vector indicating which rows containing timestamps
  x <- t %>%
    # detect rows with date time (those for not translate)
    apply(MARGIN = 1, str_detect, pattern = "-->")

  # extract only rows containing text (e.g. not containing timestamps)
  txt <- subset.data.frame(t, !x)
  # extract only time stamps
  tst <- subset.data.frame(t,  x)

  expect_length(txt[ ,1], 28)
  expect_length(tst[ ,1], 14)

})
