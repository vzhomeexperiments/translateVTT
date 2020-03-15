
<!-- README.md is generated from README.Rmd. Please edit that file -->

# translateVTT

<!-- badges: start -->

[![Travis build
status](https://travis-ci.org/vzhomeexperiments/translateVTT.svg?branch=master)](https://travis-ci.org/vzhomeexperiments/translateVTT)
<!-- badges: end -->

The goal of translateVTT is to translate VTT subtitles automatically.
For example we can translate multiple files with Closed Captions from
English to many ‘other’ languages…

This package is complementing Udemy Course [course referral
link](https://www.udemy.com/course/automated-translation-google-translate-api/?referralCode=5C6A6465A4ADFC5CC326)

## Installation

Once available, you can install the released version of translateVTT
from [CRAN](https://CRAN.R-project.org) with:

``` r
install.packages("translateVTT")
```

And the development version from [GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("vzhomeexperiments/translateVTT")
```

# Basic description of Automatic Translations with R and Google Translator API

This document is to create a way to easier read and translate captions
in `*.vtt` format

## Why do you need it?

This course is about **automating your translation jobs with Google
Translate API**. We will access it via R Software for Statistics and
Graphics. This way we coud use this course even for more anvance text
processing or even sentiment analysis. With R we can do all that while
not being professional programmers

Google Translate web page is free service, **Google translate API is not
free**. Great news is that **you can have free trial** period and you
could be able to start right away without paying a dime.

## Google Translator API key

  - Subscribe to Google Cloud Platform
  - Generate your API Key
  - Copy your key

## Encrypt your key in R\!

See dedicated course that teach in detail about how to use Public key
Cryptography in R Statistical Software. **Cryptography is more fun with
R\!** [course referral
coupon](https://www.udemy.com/course/keep-your-secrets-under-control/?referralCode=5B78D58E7C06AFFD80AE)

## Using Public Key Cryptography to securely store your API Key

``` r
# Generate your private key and write it to the folder, we assume you will save it to the folder C:/Users/UserName/.ssh/ mac users can adapt the path...
# if necessary install package
# install.packages("openssl"); install.packages("tidyverse")
# loads library open ssl and tidyverse
library(openssl)
library(tidyverse)

# generate private key
rsa_keygen(bits = 5555) %>% write_pem(path = "C:/Users/UserName/.ssh/id_api")
# extract and write your public key
read_key(file = "C:/Users/UserName/.ssh/id_api", password = "") %>% `[[`("pubkey") %>% write_pem("C:/Users/UserName/.ssh/id_api.pub")
```

Now you have your personal public key which we will use to encrypt the
credentials

``` r
# encrypt your key (always clear history and delete the key used for encryption)
## Encrypt with PRIVATE key (e.g. use this code yourself)
"=== xxx Place 4 API Key xxx yyy zzz ===" %>% 
  # serialize the object
  serialize(connection = NULL) %>% 
  # encrypt the object
  encrypt_envelope("C:/Users/UserName/.ssh/id_api.pub") %>% 
  # write encrypted data to File
  write_rds("api_key.enc.rds")
```

Now we have our encrypted key inside our project folder\!

If you will use this script later -\> delete API key from your script
and feel free to use Version Control Repository\!

In the next lecture we will see how to read the key back\!

**NOTE:** if you plan to collaborate and use your key by multiple
persons with version control check out R package ‘secret’. Remember that
you can learn how to use it in my course about Cryptography in R\!

## Translate Hello World\!

``` r
library(openssl)
library(tidyverse)
# to install package in R
#install.packages("translate")
library(translate)
citation("translate")
```

``` r
# help on the package
#?translate

# we need our API key to translate 
out <- read_rds("api_key.enc.rds")

# decrypting the password using public data list and private key (optional!)
api_key <- decrypt_envelope(out$data, out$iv, out$session, "C:/Users/fxtrams/.ssh/id_api", password = "") %>% 
  unserialize()

# usage: translate(query, source, target, key = get.key())
translate("I like this course", "en", "de", key = decrypt_envelope(out$data, out$iv, out$session, "C:/Users/fxtrams/.ssh/id_api", password = "") %>% 
  unserialize()) 

# you can detect source language of the text
detect.source("Mi piace questo corso", key = api_key)

# list of valid language mappings
languages(key = api_key)

translate("ÐšÐ°Ðº Ð½Ð°ÑÑ‡ÐµÑ‚ Ð²Ñ‹Ð¿Ð¸Ñ‚ÑŒ", "ru", "en", key = decrypt_envelope(out$data, out$iv, out$session, "C:/Users/fxtrams/.ssh/id_api", password = "") %>% 
  unserialize())

translate("How about a drink", "en", "ru", key = decrypt_envelope(out$data, out$iv, out$session, "C:/Users/fxtrams/.ssh/id_api", password = "") %>% 
  unserialize())
```

## Solving Translation problem for one VTT file

Solving for one file. Reading the file and visualizing the object

``` r
# read file -> it will be a dataframe
t <- read.delim("C:/Users/fxtrams/Downloads/L0.vtt", stringsAsFactors = F)
t
```

Extract logical vector identifying position of the arrow ‘–\>’ Get only
piece of table with text and with timestamps

``` r
library(tidyverse)
# extract logical vector indicating which rows containing timestamps
x <- t %>% 
  # detect rows with date time (those for not translate)
  apply(MARGIN = 1, str_detect, pattern = "-->")

# extract only rows containing text (e.g. not containing timestamps) 
txt <- subset.data.frame(t, !x) 
# extract only time stamps
tst <- subset.data.frame(t,  x)
```

Translating this file. We will need to read API key first Selecting one
column and giving it the original name

``` r
library(translateR)
library(openssl)
citation("translateR")
# get back our encrypted API key
out <- read_rds("api_key.enc.rds")
api_key <- decrypt_envelope(out$data, out$iv, out$session, "C:/Users/fxtrams/.ssh/id_api", password = "") %>% 
  unserialize()
# translate object txt or file in R
# Google, translate column in dataset
google.dataset.out <- translate(dataset = txt,
                                content.field = 'WEBVTT',
                                google.api.key = api_key,
                                source.lang = 'en',
                                target.lang = 'es')

# extract only new column
trsltd <- google.dataset.out %>% select(translatedContent)

# give original name
colnames(trsltd) <- "WEBVTT"
```

Join timestamps with translated text Order dataframe

``` r
# bind rows with original timestamps
abc <- rbind(tst, trsltd)

# order this file back again
bcd <-  abc[ order(as.numeric(row.names(abc))), ] %>% as.character() %>% as.data.frame()
```

Add empty row Write to the file…

``` r
# return original name
colnames(bcd) <- "WEBVTT"

bcd <- as.tibble(bcd)
# add one row
bcd2 <- add_row(bcd, WEBVTT  = "", .before = 1)

# write this file back :_)
write.table(bcd2, "translated.vtt",quote = F, row.names = F, fileEncoding = "UTF-8")
```

## Pack code into Function

``` r
# call our translation function from R script to environment
source("translateVTT.R")

translateVTT(fileName = "C:/Users/fxtrams/Downloads/L0.vtt", 
             sourceLang = "en",
             destLang = "nl",
             apikey = api_key)
```

Package that is capable to work with Dataframes directly:

``` r
library(translateR)

# read file -> it will be a dataframe
t <- read.delim("C:/Users/fxtrams/Downloads/L3.vtt", stringsAsFactors = F)

# extract logical vector indicating which rows containing timestamps
x <- t %>% 
  # detect rows with date time (those for not translate)
  apply(MARGIN = 1, str_detect, pattern = "-->")

# extract only rows containing text (e.g. not containing timestamps) 
txt <- subset.data.frame(t, !x) 
# extract only time stamps
tst <- subset.data.frame(t,  x)

# # write to file for translation (manually)
# txt %>% write.table("translate.txt", row.names = F)

# # write lines for translations
# lns <- txt %>% as.matrix() %>% c()
```

## translate this file using translate API paid service in Google

``` r
# translate object txt or file in R
# Google, translate column in dataset
google.dataset.out <- translate(dataset = txt,
                                content.field = 'WEBVTT',
                                google.api.key = "api key do not check me in to Version Control!",
                                source.lang = 'en',
                                target.lang = 'es')

# extract only new column
trsltd <- google.dataset.out %>% select(translatedContent)

# give original name
colnames(trsltd) <- "WEBVTT"

# 
```

## place it back…

``` r
## read this file back
#tsltd <- read.table("translate.txt", encoding = "UTF-8", header = T, stringsAsFactors = F)

# add original row names to the table tsltd
# row.names(tsltd) <- as.numeric(row.names(txt))

# bind rows with original timestamps
abc <- rbind(tst, trsltd)

# order this file back again
bcd <-  abc[ order(as.numeric(row.names(abc))), ] %>% as.character() %>% as.data.frame()

# return original name
colnames(bcd) <- "WEBVTT"

bcd <- as.tibble(bcd)
# add one row
bcd2 <- add_row(bcd, WEBVTT  = "", .before = 1)

# write this file back :_)
write.table(bcd2, "translated.vtt",quote = F, row.names = F)
```

## For loop\!

``` r
# translate 10 files in .vtt format
source("translateVTT.R")
library(openssl)
library(tidyverse)

# make a list of files to translate
filesToTranslate <-list.files("C:/Users/fxtrams/Downloads/", pattern="*.vtt", full.names=TRUE)
# make a list of languages
languages <- c("fr", "tr", "it", "id", "pt", "es", "ms", "de")
# get api key
out <- read_rds("api_key.enc.rds")

# decrypting the password using public data list and private key
api_key <- decrypt_envelope(out$data, out$iv, out$session, "C:/Users/fxtrams/.ssh/id_api", password = "") %>% unserialize()

# starting time of my job
start_time <- Sys.time()
balance_before <- 256.43

# for loop
for (FILE in filesToTranslate) {
  # for loop for languages
  for (LANG in languages) {
    # translation
    translateVTT(fileName = FILE, sourceLang = "en", destLang = LANG, apikey = api_key)
  }
  
}


## How much does it cost?

#1.26 hours and 18.37$ to translate 23 files to 8 different languages...
```

# Troubleshooting

## translateR package does not return translation (Mac)

If you are using Mac and using `translateR` package you may encounter
following problem. Function translate() would return only 1 column with
original text without giving you translation.

``` r
google.dataset.out <- translate(dataset = t, content.field = 'WEBVTT', google.api.key = api_key, source.lang = 'en', target.lang = 'es')
```

It was possible to override this problem by using code from `translate`
package first…

``` r
# executed first
res.translate <- translate::translate(query = "Hello World", source = "en", target = "de", key = apikey)
and then above code worked

# Google, translate column in dataset
res.translateR2 <- translateR::translate(dataset = txt,
                              content.field = 'WEBVTT',
                              google.api.key = apikey,
                              source.lang = "en",
                              target.lang = "de")
```

## not visualizing proper Encoding for ‘special’ characters

see:
<https://stackoverflow.com/questions/44095025/r-how-to-convert-utf-8-code-like-u9600u524d-back-to-chinese-characters>

For ‘special’ characters like chinese, cyrilic, etc there might be
problems with encoding while writing to the file\!

The most possible reason is the Operating System `locale`. Function
`translateVTT` tries to handle that by switching OS locale to
appropriate one:

``` r
  ## dealing with locale ... only supporting few key languages at the moment
  # note: we must apply fail back mechanism in case OS does not support it!
  if(destLang == "fr") {
    res <- Sys.setlocale(locale = "French")
    if(res == "") {stop("Your OS does not support this language", call. = FALSE)}
  } else if(destLang == "ru") {
    res <- Sys.setlocale(locale = "Russian")
    if(res == "") {stop("Your OS does not support this language", call. = FALSE)}
  } else if(destLang == "it") {
    res <- Sys.setlocale(locale = "Italian")
    if(res == "") {stop("Your OS does not support this language", call. = FALSE)}
  } else if(destLang == "zh-CN") {
    res <- Sys.setlocale(locale = "Chinese")
    if(res == "") {stop("Your OS does not support this language", call. = FALSE)}
  } else if(destLang == "hi") {
    res <- Sys.setlocale(locale = "Hindi")
    if(res == "") {stop("Your OS does not support this language", call. = FALSE)}
  }

# ... your code to translate

# restoring locale
  Sys.setlocale()
```

## Want to learn more?

Join this *Udemy Course* with this
[coupon](https://www.udemy.com/course/automated-translation-google-translate-api/?referralCode=5C6A6465A4ADFC5CC326)
and get Lifetime access with 30 days money back guarantee\!
