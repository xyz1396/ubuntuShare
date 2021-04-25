# to test decompressing and getting KOtables while downloading tar.gz file

library(tidyverse)

links <- readRDS("../draft/allLinksAndMD5.rds")
# on server
# cd /scratch/yixiong/all
# links <- readRDS("allLinksAndMD5.rds")
indx <- sapply(links, length)
links <-
  as.data.frame(do.call(rbind, lapply(links, `length<-`, max(indx))))
colnames(links) <- c("name", "link", "md5")
links <- links[!is.na(links$md5), ]
row.names(links) <- NULL
links$name <- paste0(links$name, ".tar.gz")
write.table(links, "../data/alllinkAndNameMD5.txt", row.names = F)
# on server
# write.table(links, "alllinkAndNameMD5.txt", row.names = F)
# links<-read.table("alllinkAndNameMD5.txt",header=T)

getCookies <-
  function(account = "yixiong@ou.edu",
           password = "4963123yz",
           path = ".") {
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
      "-c ",
      path,
      "/",
      "cookies.txt > /dev/null"
    )
    system(command, ignore.stderr = T, ignore.stdout = T)
  }


downloadAndCheck <- function(name, link, md5) {
  command <-
    # try 5 times timeout 60 S
    paste0("wget -c -t 5 -T 60 --load-cookies cookies.txt ","'", link,"'"," -O ", name)
  system(command,
         ignore.stdout = T,
         ignore.stderr = T,wait = T)
  localMD5 <- system(paste("md5sum", name), intern = T)
  localMD5 <-str_split(localMD5," ",simplify = T)[1]
  # try 2 times
  if (md5 != localMD5)
    system(command,
           ignore.stdout = T,
           ignore.stderr = T)
  return(md5 == localMD5)
}

unTarFiles <- function(name) {
  id <- str_sub(name, end = -8)
  files <-
    paste0(paste0(id, "/", id, ".a."), c("depth.txt", "gff", "ko.txt"))
  untar(name, files = files)
  # the 4th item is id
  files <- c(files, id)
  files
}

getKOtable <- function(files, KOtableStorePath) {
  # in case a.depth.txt does not exist
  if (!file.exists(files[1])) {
    print(paste(files[1], "does not exist"))
    file.remove(files)
    return(NA)
  }
  # in case a.depth.txt size==0
  if (file.info(files[1])$size == 0) {
    print(paste(files[1], "size==0"))
    file.remove(files)
    return(NA)
  }
  print(paste(files[1], "passed check"))
  contigDepth <- read.table(files[1], header = T)
  colnames(contigDepth) <- c("ContigID", "AvgFold")
  # in case AvgFold in "Length_1231" type
  if (class(contigDepth$AvgFold) == "character") {
    print(paste(files[1], "AvgFold in Length_1231 type"))
    contigDepth$AvgFold <-
      as.numeric(str_sub(contigDepth$AvgFold, 8))
  }
  contigDepth$TPM <-
    contigDepth$AvgFold / sum(contigDepth$AvgFold) * 10 ** 6
  gff <- read.table(files[2],
                    header = F,
                    sep = "\t",
                    quote = "")
  gff2 <-
    data.frame(ContigID = gff$V1,
               GeneID = str_sub(str_extract(gff$V9, "locus_tag=.*?;"), 11, -2))
  ko <- read.table(files[3], header = F)
  ko <- data.frame(GeneID = ko$V1, KO = ko$V3)
  KOtable <- inner_join(ko, gff2, by = c("GeneID" = "GeneID"))
  # in case the first column of a.ko.txt is ID of gff
  if (nrow(KOtable) == 0) {
    gff2 <-
      data.frame(ContigID = gff$V1,
                 GeneID = str_sub(str_extract(gff$V9, "ID=.*?;"), 4, -2))
    KOtable <- inner_join(ko, gff2, by = c("GeneID" = "GeneID"))
  }
  KOtable <-
    inner_join(KOtable, contigDepth, by = c("ContigID" = "ContigID"))
  KOtable <- group_by(KOtable, KO)
  KOtable <- summarise(KOtable, TPM = sum(TPM))
  KOtable$TPM <- KOtable$TPM / sum(KOtable$TPM) * 10 ** 6
  KOtable <- arrange(KOtable, KO)
  write.table(
    KOtable,
    paste0(KOtableStorePath, "/", files[4], ".KOtable.txt"),
    quote = F,
    col.names = F,
    row.names = F
  )
  # delete temp file
  file.remove(files[1:3])
  file.remove(paste0(files[4], ".tar.gz"))
  KOtable
}

localdisk <- getwd()
ramdisk <- "/run/user/17803"

downloader <- function(name, link, md5) {
  # go to ramdisk
  setwd(ramdisk)
  # in case cookies  expired
  getCookies()
  downloadSucceed <- downloadAndCheck(name, link, md5)
  if (downloadSucceed) {
    files <- unTarFiles(name)
    KOtable <- getKOtable(files, localdisk)
    return(KOtable)
  }
  else{
    print(paste0(name, "download failed"))
    return(NA)
  }
}

# test
# links2<-links[3:6,]
# KOtables <- mapply(downloader, links2$name, links2$link, links2$md5,SIMPLIFY = F)

KOtables <- mapply(downloader, links$name, links$link, links$md5,SIMPLIFY = F)
saveRDS(KOtables, "allKOtables.rds")