# get parameters
# The 1st is id txt file name 
# The 2nd is link txt file name 
# demo
# nohup Rscript get1000link.R first1000.txt first1000link.txt > getFirst1000.log.txt 2>&1 &

source("linkHandlerPhantomJS.R")

args<-commandArgs(T)
df <- read.table(args[1], header = T)

getCookies("yixiong@ou.edu","4963123yz")
parseCookies("cookies.txt")

download<-function(id){
  uid<-NA
  while(is.na(uid)){
    uid <- getUID(id)
  }
  XML<-getXML(id,uid)
  getTarLink(id,XML)
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