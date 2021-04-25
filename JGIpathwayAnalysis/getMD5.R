library(XML)
library(stringr)

xmls<-list.files(pattern = "*.xml")

getMD5<-function(files){
  id<-str_sub(files,1,-11)
  files <- htmlParse(files, encoding = "utf-8")
  # get element "file"'s value 'href'
  md5 <-
    getNodeSet(files,
               paste0("//file[@filename='", id, ".tar.gz", "']//@md5"))[[1]]
  md5
}

getLocalMD5<-function(files){
  md5<-system(paste("md5sum",files),intern=T)
  str_split(md5,"  ",simplify=T)[1]
}

md5<-sapply(xmls, getMD5)
names(md5)<-NULL
tarGz<-paste0(str_sub(xmls,1,-11),".tar.gz")
localMD5<-sapply(tarGz, getLocalMD5)
names(localMD5)<-NULL
# 79
sum(localMD5==md5)
df<-data.frame(name=tarGz,md5=md5,localMD5=localMD5)
write.table(df,"soil100md5.txt",quote = F,col.names = F,row.names = F)