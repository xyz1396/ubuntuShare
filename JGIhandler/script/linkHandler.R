library(RCurl)
library(XML)
library(stringr)

#### login ####

login<-function(account,password){
  loginUrl <- "https://signon.jgi.doe.gov/signon/create"
  payload <- c(login = account, password = password)
  # Set error log
  d <- debugGatherer()
  # Construct the curl handle to collect login information and open the Cookiefile manager
  chandle <<-
    getCurlHandle(
      debugfunction = d$update,
      followlocation = TRUE,
      cookiefile = "",
      verbose = TRUE
    )
  # login, save cookie:
  cookie <-
    postForm(
      loginUrl,
      .params = payload,
      .encoding = "UTF-8",
      curl = chandle,
      style = "post"
    )
}

#### parse detail page ####

getDownloadDataLink <- function(id) {
  detail <-
    getURL(
      paste0(
        "https://img.jgi.doe.gov/cgi-bin/mer/main.cgi?section=TaxonDetail&page=taxonDetail&taxon_oid=",
        id
      ),
      curl = chandle
    )
  detail <- htmlParse(detail, encoding = "utf-8")
  # get element "a"'s value 'href'
  downloadLink <-getNodeSet(detail, "//a[@class='genome-btn download-btn']//@href")[[1]]
  downloadLink
}

#### get XML file ####

getXML <- function(id, downloadLink) {
  # if getDownloadDataLink failed run this
  if (downloadLink == "#") {
    downloadLink <-
      paste0(
        "https://genome.jgi.doe.gov/portal/ext-api/downloads/",
        "get-directory?organism=IMG_",
        id,
        "&organizedByFileType=false"
      )
  }
  else{
    downloadLink <- curlGetHeaders(downloadLink)
    downloadLink <-
      str_sub(str_extract(grep(
        downloadLink, pattern = "Location:.*.download.html", value = T
      ), pattern = "portal/.*/"), 8,-2)
    # if link jump failed
    if (identical(downloadLink, character(0))) {
      downloadLink <-
        paste0(
          "https://genome.jgi.doe.gov/portal/ext-api/downloads/",
          "get-directory?organism=IMG_",
          id,
          "&organizedByFileType=false"
        )
    }
    else{
      downloadLink <-
        paste0(
          "https://genome.jgi.doe.gov/portal/ext-api/downloads/get-directory?organism=",
          downloadLink,
          "&organizedByFileType=false"
        )
    }
  }
  files <- getURL(downloadLink, curl = chandle)
  fileConn <- file(paste0(id, ".files.xml"))
  writeLines(files, fileConn)
  close(fileConn)
  files
}

#### get id.tar.gz link ####

getTarLink <- function(id, files) {
  files <- htmlParse(files, encoding = "utf-8")
  # get element "file"'s value 'href'
  downloadLink <-
    getNodeSet(files,
               paste0("//file[@filename='", id, ".tar.gz", "']//@url"))[[1]]
  downloadLink <- paste0("https://genome.jgi.doe.gov", downloadLink)
  downloadLink
}