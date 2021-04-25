library(XML)
library(stringr)

# get parameters
# The 1st is id txt file name 
# The 2nd is link txt file name 
# demo
# Rscript Soil100downloadByPhantomJS.R soil100.txt soil100link.txt

# 3300018954 cannot be got by 
# https://img.jgi.doe.gov/cgi-bin/mer/main.cgi?section=TaxonDetail&page=taxonDetail&taxon_oid=3300018954
# but can be got by
# https://genome.jgi.doe.gov/portal/pages/dynamicOrganismDownload.jsf?organism=IMG_3300018954

args<-commandArgs(T)

#### get cookies ####

account <- "yixiong@ou.edu"
password <- "4963123yz"
command <- paste0(
  "curl 'https://signon.jgi.doe.gov/signon/create' ",
  "--data-urlencode ",
  "'login=",
  account,
  "' ",
  "--data-urlencode ",
  "'password=",
  password,
  "' ",
  "-c cookies.txt > /dev/null"
)
system(command)

#### parse cookies ####

cookies<-readLines("cookies.txt")
cookies<-grep("^.jgi.doe.gov",cookies,value = T)
cookies<-unlist(str_split(cookies,"\\t"))
domain<-cookies[1]
flag<-cookies[2]
path<-cookies[3]
secure<-cookies[4]
expiration<-cookies[5]
name<-cookies[6]
value<-cookies[7]

#### get download page link ####

agent <-
  paste0(
    "Mozilla/5.0 (Windows NT 6.1; WOW64) ",
    "AppleWebKit/537.36 (KHTML, like Gecko) ",
    "Chrome/37.0.2062.120 Safari/537.36"
  )
detailPageLink <-
  paste0("https://img.jgi.doe.gov/cgi-bin/mer/",
         "main.cgi?section=TaxonDetail&page=taxonDetail&taxon_oid=")
phantomJS <- function(url) {
  writeLines(
    sprintf(
      "var page = require('webpage').create();
      page.settings.userAgent = '%s';
      phantom.addCookie({
        'name'     : '%s',
        'value'    : '%s',
        'domain'   : '%s',
        'path'     : '%s',
        });
      page.open('%s', function (){
          console.log(page.content);
          phantom.exit();
        });",
      agent,
      name,
      value,
      domain,
      path,
      url
    ),
    con = "scrape.js"
  )
  system("phantomjs scrape.js --ignore-ssl-errors=true --ssl-protocol=any",
         intern = T)
}

getDownloadLink <- function(id) {
  url <- paste0(detailPageLink, id)
  detailPage <- phantomJS(url)
  detailPage <- htmlParse(detailPage, encoding = "utf-8")
  getNodeSet(detailPage, "//a[@class='genome-btn download-btn']//@href")[[1]]
}

#### get XML file and link ####

getXMLlink <- function(url) {
  downloadPage <- phantomJS(url)
  downloadPage <- htmlParse(downloadPage, encoding = "utf-8")
  link <-
    getNodeSet(downloadPage, "//a[@id='downloadForm:xmlLink']//@href")[[1]]
  # deal with Data Usage Policy button
  if (is.null(link)) {
    link <-
      getNodeSet(downloadPage,
                 "//input[@id='data_usage_policy:okButton']//@onclick")[[1]]
    link <- str_sub(link, 19, -17)
    link <- paste0("https://genome.jgi.doe.gov/portal/", link)
    link <-
      getNodeSet(htmlParse(phantomJS(link)),
                 "//a[@id='downloadForm:xmlLink']//@href")[[1]]
  }
  paste0("https://genome.jgi.doe.gov/portal/",str_sub(link,4))
}

# phantomJS will get ReferenceError: Can't find variable: 
# browserUpdateMessage after getting dozens of XML files 
# getXMLfile<-function(id,url){
#   files <-  phantomJS(url)
#   # save file
#   fileConn <- file(paste0(id, ".files.xml"))
#   writeLines(files, fileConn)
#   close(fileConn)
#   files
# }

getXMLfile <- function(id, url) {
  files <- system(paste0("curl '", url, "' -b cookies.txt"),
                  intern = T)
  # save file
  fileConn <- file(paste0(id, ".files.xml"))
  writeLines(files, fileConn)
  close(fileConn)
  files
}

#### get id.tar.gz link ####

getTarLink <- function(id, files) {
  files <- htmlParse(files, encoding = "utf-8")
  downloadLink <-
    getNodeSet(files,
               paste0("//file[@filename='", id, ".tar.gz", "']//@url"))[[1]]
  downloadLink <- paste0("https://genome.jgi.doe.gov", downloadLink)
  downloadLink
}

#### loop ####

df <- read.table(args[1], header = T)


linklist <-
  sapply(df$id, function(id)
  {
    link <- getTarLink(id, getXMLfile(id, getXMLlink(getDownloadLink(id))))
    while(link=="https://genome.jgi.doe.gov"){
      Sys.sleep(runif(1,10,20))
      link <- getTarLink(id, getXMLfile(id, getXMLlink(getDownloadLink(id))))
    }
    link
  })
write.table(data.frame(link = linklist), args[2], row.names = F)
