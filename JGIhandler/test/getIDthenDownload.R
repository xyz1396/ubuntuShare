
source("linkHandlerPhantomJS3.R")
source("linkHandlerDownloader.R")

args<-commandArgs(T)
idTablePath<-args[1]
KOtablePath<-arg[2]

# idTable <- read.table("allID.txt",header = T)
idTable <- read.table(idTablePath,header = T)

getCookies("yixiong@ou.edu","4963123yz")
parseCookies("cookies.txt")

downloadLinkAndMD5<-function(id){
  uid<-NA
  times<-0
  while(is.na(uid)){
    uid <- getUID(id)
    times<-times+1
    # retry 10 times
    if (times==10) {
      msg<-paste(id,"not found",Sys.time())
      print(msg)
      return(c(id,NA,NA))
    }
  }
  XML<-getXML(id,uid)
  return(getLinkAndMD5(id,XML))
}

linkAndMD5 <-
  sapply(idTable$id, function(id)
  {
    link<-downloadLinkAndMD5(id)
    Sys.sleep(runif(1, 1, 2))
    link
  },simplify = T)

linkAndMD5<-as.data.frame(t(linkAndMD5))
colnames(linkAndMD5)<-c("name","link","md5")
linkAndMD5<-linkAndMD5[!is.na(linkAndMD5$md5),]

failedTime<-0

downloader <- function(name, link, md5) {
  setwd(localdisk)
  downloadSucceed <- downloadAndCheck(name, link, md5)
  # stop about 5s
  # Sys.sleep(runif(1, 3, 7))
  if (downloadSucceed) {
    files <- unTarFiles(name,ramdisk)
    # go to ramdisk
    setwd(ramdisk)
    KOtable <- getKOtable(files, localdisk)
    # when succeed once reset failedTime 
    failedTime<<-0
    return(KOtable)
  }
  else{
    failedTime<<-failedTime+1
    print(paste(name, "download failed",Sys.time()))
    if (failedTime >4){
      # if fail consecutively 5 times stop about 25min
      Sys.sleep(runif(1, 20*60, 30*60))
      failedTime<<-0
      # in case cookies expired
      getCookies(path = localdisk)
    }
    return(NA)
  }
}

localdisk <- getwd()
ramdisk <- "/run/user/17803"

KOtables <-
  mapply(downloader,
         linkAndMD5$name,
         linkAndMD5$link,
         linkAndMD5$md5,
         SIMPLIFY = F)
setwd(localdisk)
saveRDS(KOtables, "allKOtables.rds")