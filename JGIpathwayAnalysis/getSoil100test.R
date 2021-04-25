library(RCurl)
library(XML)
library(stringr)

#### get cookies ####

# https://stackoverflow.com/questions/2388974/how-do-i-use-cookies-with-rcurl

agent="Mozilla/5.0"
curl = getCurlHandle()
curlSetOpt(cookiejar="cookies.txt",  useragent = agent, followlocation = TRUE, curl=curl)
login <- "https://signon.jgi.doe.gov/signon/create"
payload <- c(login = "yixiong@ou.edu", password = "4963123yz")
cookie <-postForm(login,.params = payload,.encoding = "UTF-8",curl = curl,style = "post")
rm(curl)
gc()

login <- "https://signon.jgi.doe.gov/signon/create"
payload <- c(login = "yixiong@ou.edu", password = "4963123yz")
agent="Mozilla/5.0" #or whatever 
#Set RCurl pars
chandle <-getCurlHandle()
curlSetOpt(cookiefile="~/cookies.txt",  useragent = agent, followlocation = TRUE, curl=chandle)
# login, save cookie:
cookie <-
  postForm(
    login,
    .params = payload,
    .encoding = "UTF-8",
    curl = chandle,
    style = "post"
  )

id="3300015087"

detail <-
  getURL(
    paste0(
      "https://img.jgi.doe.gov/cgi-bin/mer/main.cgi?section=TaxonDetail&page=taxonDetail&taxon_oid=",
      id
    ),
    curl = chandle
  )
rm(chandle)
gc()
detail <- htmlParse(detail, encoding = "utf-8")
# get element "a"'s value 'href'
downloadLink <-
  getNodeSet(detail, "//a[@class='genome-btn download-btn']//@href")[[1]]

downloadPage <-getURL(downloadLink,curl = chandle)
fileConn <- file(paste0(id, ".downloadPage.html"))
writeLines(downloadPage, fileConn)
close(fileConn)
# They use js to render the link, cannot get link from source
downloadPage <- htmlParse(downloadPage, encoding = "utf-8")
# https://stackoverflow.com/questions/26631511/scraping-javascript-website-in-r
# https://stackoverflow.com/questions/9504765/does-phantomjs-support-cookies

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
  "-c cookies > /dev/null"
)
system(command)



writeLines(sprintf("var page = require('webpage').create();
page.open('%s', function () {
    console.log(page.content); //page source
    phantom.exit();
});", downloadLink), con="scrape.js")

system("phantomjs scrape.js > scrape.html --cookies-file=cookies.txt", intern = T)
downloadPage <- htmlParse("scrape.html", encoding = "utf-8")
xmlLink <-getNodeSet(downloadPage, "//a[@id='downloadForm:xmlLink']//@href")[[1]]

