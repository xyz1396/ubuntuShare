library(XML)
library(stringr)

#### get cookies ####

# https://stackoverflow.com/questions/2388974/how-do-i-use-cookies-with-rcurl
# agent="Mozilla/5.0"
# curl = getCurlHandle()
# curlSetOpt(cookiejar="cookies.txt",  useragent = agent, followlocation = TRUE, curl=curl)
# login <- "https://signon.jgi.doe.gov/signon/create"
# payload <- c(login = "yixiong@ou.edu", password = "4963123yz")
# cookie <-postForm(login,.params = payload,.encoding = "UTF-8",curl = curl,style = "post")
## cookies file appeared after handle was removed 
# rm(curl)
# gc()

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

cookies<-readLines("cookies.txt")
cookies<-grep("^.jgi.doe.gov",cookies,value = T)
cookies<-unlist(str_split(cookies,"\\t"))
# format of cookies get by curl
# https://stackoverflow.com/questions/7181785/send-cookies-with-curl
domain<-cookies[1]
flag<-cookies[2]
path<-cookies[3]
secure<-cookies[4]
expiration<-cookies[5]
name<-cookies[6]
value<-cookies[7]

id="3300015087"

# writeLines(sprintf("var page = require('webpage').create();
# page.open('%s', function () {
#     console.log(page.content); //page source
#     phantom.exit();
# });","https://www.google.com"
# ), con="scrape.js")
# system("phantomjs scrape.js --ignore-ssl-errors=true --ssl-protocol=any > scrape.html", intern = T)

# userAgent most be setted
# https://phantomjs.org/api/webpage/property/settings.html
agent <-
  paste0(
    "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) ",
    "Chrome/37.0.2062.120 Safari/537.36"
  )
url <-
  "https://img.jgi.doe.gov/cgi-bin/mer/main.cgi?section=TaxonDetail&page=taxonDetail&taxon_oid="
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
page.open('%s', function () {
    console.log(page.content);
    phantom.exit();
});",
    agent,
    name,
    value,
    domain,
    path,
    paste0(url, id)
  ),
  con = "scrape.js"
)
detailPage <- system("phantomjs scrape.js --ignore-ssl-errors=true --ssl-protocol=any",
                     intern = T)
detailPage <- htmlParse(detailPage, encoding = "utf-8")
# get element "a"'s value 'href'
downloadLink <-
  getNodeSet(detailPage, "//a[@class='genome-btn download-btn']//@href")[[1]]

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
page.open('%s', function () {
    console.log(page.content);
    phantom.exit();
});",
    agent,
    name,
    value,
    domain,
    path,
    downloadLink
  ),
  con = "scrape.js"
)
downloadPage <- system("phantomjs scrape.js --ignore-ssl-errors=true --ssl-protocol=any",
                     intern = T)
downloadPage <- htmlParse(downloadPage, encoding = "utf-8")
xmlLink <-getNodeSet(downloadPage, "//a[@id='downloadForm:xmlLink']//@href")[[1]]

writeLines(
  sprintf(
    "var page = require('webpage').create();
phantom.addCookie({
  'name'     : '%s',   /* required property */
  'value'    : '%s',  /* required property */
  'domain'   : '%s',
  'path'     : '%s',                /* required property */
});
page.open('%s', function () {
    console.log(page.content); //page source
    phantom.exit();
});",
    name,
    value,
    domain,
    path,
    downloadLink
  ),
  con = "scrape.js"
)

system("phantomjs scrape.js > scrape.html --cookies-file=cookies.txt", intern = T)
downloadPage <- htmlParse("scrape.html", encoding = "utf-8")
xmlLink <-getNodeSet(downloadPage, "//a[@id='downloadForm:xmlLink']//@href")[[1]]