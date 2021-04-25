library(stringr)
library(XML)

files<-dir()
files<-files[str_detect(files,".files.xml")]
# all XML files 10577
length(files)

getLink<-function(XMLfile){
  id<-str_split(XMLfile,"\\.",simplify = T)[1]
  pattern<-paste0("url=.*.",id,".tar.gz")
  XMLfile<-readLines(XMLfile)
  link<-str_extract(XMLfile,pattern)
  link <- as.character(na.omit(link))
  link<-str_sub(link,6)
  return(c(id,link))
}
links<-sapply(files,getLink,simplify = T)

getLinkAndMD5 <- function(XMLfile) {
  id <- str_split(XMLfile, "\\.", simplify = T)[1]
  XMLfile <- htmlParse(XMLfile, encoding = "utf-8")
  downloadLink <-
    getNodeSet(XMLfile,
               paste0("//file[@filename='", id, ".tar.gz", "']//@url"))[[1]]
  downloadLink <- paste0("https://genome.jgi.doe.gov", downloadLink)
  md5 <-
    getNodeSet(XMLfile,
               paste0("//file[@filename='", id, ".tar.gz", "']//@md5"))[[1]]
  return(c(id,downloadLink,md5))
}

# some xml file is without tar.gz with the same id

links<-sapply(files,getLinkAndMD5,simplify = T)
# saveRDS(links,"allLinksAndMD5.rds")
# links<-readRDS("../draft/allLinksAndMD5.rds")

indx <- sapply(links, length)
links2 <- as.data.frame(do.call(rbind,lapply(links, `length<-`,max(indx))))
colnames(links2) <- c("id","link","md5")
# 10577 
nrow(links2)
links2<-links2[!is.na(links2$md5),]
# 10347
nrow(links2)
links3<-cbind(link=links2$link,name=paste0(links2$id,".tar.gz"))
write.table(links3, "alllinkAndName.txt", row.names = F)

# curl 'https://signon.jgi.doe.gov/signon/create' --data-urlencode 'login=yixiong@ou.edu' --data-urlencode 'password=4963123yz' -c cookies.txt > /dev/null
# nohup tail -n +2 alllinkAndName.txt | xargs -n2 bash -c 'wget -c -t 0 -T 60 --load-cookies cookies.txt $0 -O $1' > alllinkAndName.log.txt 2>&1 &
