library(XML)
library(stringr)

#### get cookies ####

# path to store cookies
getCookies <- function(account, password, path=".") {
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
    "-c ",path,"/","cookies.txt > /dev/null"
  )
  system(command,ignore.stderr = T)
}

#### parse cookies ####

parseCookies <- function(cookies) {
  cookies <- readLines(cookies)
  cookies <- grep("^.jgi.doe.gov", cookies, value = T)
  cookies <- unlist(str_split(cookies, "\\t"))
  domain <- cookies[1]
  flag <- cookies[2]
  path <- cookies[3]
  secure <- cookies[4]
  expiration <- cookies[5]
  name <- cookies[6]
  value <- cookies[7]
  cookies <<- c(
    name = name,
    value = value,
    domain = domain,
    path = path
  )
  # cookies
}

#### get uid ####

phantomJS <- function(url, cookies,phantomPath="phantomjs") {
  agent <-
    paste0(
      "Mozilla/5.0 (Windows NT 6.1; WOW64) ",
      "AppleWebKit/537.36 (KHTML, like Gecko) ",
      "Chrome/37.0.2062.120 Safari/537.36"
    )
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
      page.open('%s',
          window.setTimeout(function (){
          console.log(page.content);
          phantom.exit();
        },2500));",
      agent,
      cookies['name'],
      cookies['value'],
      cookies['domain'],
      cookies['path'],
      url
    ),
    con = "scrape.js"
  )
  system(paste0(phantomPath," scrape.js --ignore-ssl-errors=true --ssl-protocol=any"),
         intern = T)
}

getUID <- function(id,phantomPath="phantomjs") {
  portalSearch<-"https://genome.jgi.doe.gov/portal/?core=genome&query="
  portalSearch <- paste0(portalSearch, id)
  portalSearch <- phantomJS(portalSearch,cookies,phantomPath)
  # close warning
  options(warn=-1)
  portalSearch <- htmlParse(portalSearch, encoding = "utf-8",validate=F)
  url<-getNodeSet(portalSearch, "//a[text()='Download']//@href")[[1]]
  # restore warning
  options(warn=0)
  uid<-str_split(url,"/",simplify = T)[3]
  uid
}

#### get xml ####

getXML<-function(id,uid,path=".",cookiesPath="cookies.txt"){
  url<-paste0("https://genome.jgi.doe.gov/portal/ext-api/downloads/",
               "get-directory?organism=",
               uid,
               "&organizedByFileType=false")
  files <- system(paste0("curl '", url, "' -b ",cookiesPath),
                  intern = T,ignore.stderr = T)
  # save file
  fileConn <- file(paste0(path,"/",id, ".files.xml"))
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
