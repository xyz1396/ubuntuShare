library(tidyverse)
source("../script/linkHandlerPhantomJS.R")
getCookies("yixiong@ou.edu","4963123yz","../data")
parseCookies("../data/cookies.txt")
phantomJS("https://genome.jgi.doe.gov/portal/?core=genome&query=3300041786",
          cookies,"./phantomjs")
getUID("3300020517","./phantomjs")
getUID("3300026360","./phantomjs")
getUID("3300005907","./phantomjs")
XML<-getXML(3300005907,"AntRauMetaVIRRA1_FD","../data","../data/cookies.txt")
getTarLink(3300005907,XML)

# alternative way to parse html
a<-readLines("../test/trycatchtest.html")
a<-str_extract(a,'href="/.*\\.download\\.html"')
a<-as.character(na.omit(a))
a<-str_split(a,pattern = "/",simplify = T)[3]

#### on server ####

getCookies("yixiong@ou.edu","4963123yz")
parseCookies("cookies.txt")
tryCatch(getUID("3300020517"))
b<-tryCatch(getUID("3300020517"),error = function(e) e)

a<-tryCatch(phantomJS("https://genome.jgi.doe.gov/portal/?core=genome&query=3300041786",cookies),error = function(e) e)
fileConn <- file("test/trycatchtest.xml")
writeLines(a, fileConn)
close(fileConn)
a<-readLines("test/trycatchtest.xml")

# htmlParse can parse html with warning massage directly
# but raise error in trycatch

b<-htmlParse(a, encoding = "utf-8",validate=F,isHTML = T)
b<-xmlTreeParse(a, encoding = "utf-8",isHTML = T)
b<-tryCatch(htmlParse(a, encoding = "utf-8",validate=F),
         error = function(e) e)
b<-tryCatch(htmlParse(a, encoding = "utf-8",validate=F),
            error = function(e) e)
tryCatch(b<-htmlParse(a, encoding = "utf-8",validate=F),
            warning=function(w) {print("Warning")},
            error = function(e) print("Error"))
tryCatch(b<-suppressWarnings(xmlTreeParse(a, encoding = "utf-8",isHTML = T)),
         warning=function(w) {print("Warning")},
         error = function(e) print("Error"))
b<-tryCatch(htmlParse("../test/try catch - Suppress warnings using tryCatch in R - Stack Overflow.mhtml", encoding = "utf-8",validate=F),
            error = function(e) e)
b<-tryCatch(htmlParse("trycatchtest.html", encoding = "utf-8",validate=F),
            error = function(e) e)

tryCatch(getUID("3300020517",cookies),error = function(e) print("Hello"))

#### test 2 edition on server ####

source("linkHandlerPhantomJS2.R")

portalSearch<-tryCatch(phantomJS("https://genome.jgi.doe.gov/portal/?core=genome&query=3300041786",cookies),error = function(e) e)
tryCatch(getUID("3300020517"),error = function(e) e)
# id 3300005512 not found on webpage
tryCatch(getUID("3300005512"),error = function(e) e)
tryCatch(getUID("3300002636"),error = function(e) e)