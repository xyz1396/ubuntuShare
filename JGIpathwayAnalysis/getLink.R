library(RCurl)
library(XML)
library(stringr)

#### login ####

login <- "https://signon.jgi.doe.gov/signon/create"
payload <- c(login = "yixiong@ou.edu", password = "4963123yz")
# Set error log
d <- debugGatherer()
# Construct the curl handle to collect login information and open the Cookiefile manager
chandle <-
  getCurlHandle(
    debugfunction = d$update,
    followlocation = TRUE,
    cookiefile = "",
    verbose = TRUE
  )
# login, save cookie:
cookie <-
  postForm(
    login,
    .params = payload,
    .encoding = "UTF-8",
    curl = chandle,
    style = "post"
  )

#### parse detail page ####

df10 <- read.table("first10Id.txt", header = T)

getfilesXML <- function(id) {
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
  downloadLink <-
    getNodeSet(detail, "//a[@class='genome-btn download-btn']//@href")[[1]]
  downloadLink <- curlGetHeaders(downloadLink)
  downloadLink <-
    str_sub(str_extract(grep(
      downloadLink, pattern = "Location", value = T
    ), pattern = "portal/.*/")[2], 8, -2)
  downloadLink <-
    paste0(
      "https://genome.jgi.doe.gov/portal/ext-api/downloads/get-directory?organism=",
      downloadLink,
      "&organizedByFileType=false"
    )
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

#### loop ####

linklist <-
  sapply(df10$id, function(id)
    getTarLink(id, getfilesXML(id)))
write.table(data.frame(link = linklist), "first10link.txt", row.names = F)
