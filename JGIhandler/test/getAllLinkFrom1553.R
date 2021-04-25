# get parameters
# The 1st is id txt file name 
# The 2nd is link txt file name 
# demo
# nohup Rscript getAllLinkFrom1553.R allFrom1553ID.txt allFrom1553ID.txt > allFrom1553Link.log.txt 2>&1 &
# pid 205061

source("linkHandlerPhantomJS2.R")

args<-commandArgs(T)
df <- read.table(args[1], header = T)

getCookies("yixiong@ou.edu","4963123yz")
parseCookies("cookies.txt")

download<-function(id){
  uid<-NA
  times<-0
  while(is.na(uid)){
    uid <- getUID(id)
    times<-times+1
    # retry 10 times
    if (times==10) {
      msg<-paste(id,"not found")
      print(msg)
      return(paste(msg))
    }
  }
  XML<-getXML(id,uid)
  return(getTarLink(id,XML))
}

linklist <-
  sapply(df$id, function(id)
  {
    ## download(id) cannot work in trycatch with error
    # link <- tryCatch({
    #   download(id)
    # },
    # error = function(e) {
    #   message(e)
    #   message(id, " Timeout. Skipping.")
    #   NA
    # },
    # finally = {
    #   
    # })
    link<-download(id)
    Sys.sleep(runif(1, 1, 2))
    link
  })

write.table(data.frame(link = linklist), args[2], row.names = F)