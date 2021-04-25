library(stringr)
library(tidyverse)

# change node
# ssh c651

#### check md5 ####

df<-read.table("soil100md5.txt")
fileName<-df$V1[df$V2==df$V3]
# the 2nd is too large without depth.txt
fileName[2]<-"too large"

#### draft ####

# # unzip and check depth.txt
# unzipAndCheck <- function(fileName) {
#   ramDisk<-"/run/user/17803"
#   system(paste("tar zxvf", fileName,"-C",ramDisk))
#   folderName<-str_sub(fileName,end = -8)
#   fileList<-dir(paste0(ramDisk,"/",folderName))
#   depthFile<-paste0(ramDisk,"/",folderName,"/",folderName,".a.depth.txt")
#   if (paste0(folderName,".a.depth.txt") %in% fileList) {
#     if (file.info(depthFile)$size>0) read.table(depthFile,header = T)
#     else print("depth.txt size=0")
#   }
#   else print("no depth.txt")
# }
# depth<-sapply(fileName, unzipAndCheck)
# 
# # read only one file
# 
# untar("3300000705.tar.gz",files="3300000705/3300000705.a.depth.txt",exdir="/run/user/17803")
# system("tar -zxvf 3300000705.tar.gz -C /run/user/17803 3300000705/3300000705.a.depth.txt")
# 
# ramdisk<-"/run/user/17803"
# 
# unTarFiles <- function(fileName) {
#   id<-str_sub(fileName,end = -8)
#   files<-paste0(paste0(id,"/",id,".a."),c("depth.txt","gff","ko.txt"))
#   untar(fileName,files=files,exdir=ramdisk)
#   # absolute path
#   files<-paste0(ramdisk,"/",files)
#   files
# }
# 
# getKOtable<-function(files){
#   if (!file.exists(files[1])){
#     print(paste(files[1],"does not exist"))
#     file.remove(files)
#     return(NA)
#   }
#   if (file.info(files[1])$size==0){
#     print(paste(files[1],"size==0"))
#     file.remove(files)
#     return(NA)
#   }
#   print(paste(files[1],"passed check"))
#   contigDepth<-read.table(files[1],header = T)
#   colnames(contigDepth)<-c("ContigID","AvgFold")
#   contigDepth$TPM<-contigDepth$AvgFold/sum(contigDepth$AvgFold)*10**6
#   gff<-read.table(files[2],header = F,sep = "\t")
#   gff<-data.frame(ContigID=gff$V1,GeneID=str_sub(str_extract(gff$V9,"locus_tag=.*?;"),11,-2))
#   ko<-read.table(files[3],header = F)
#   ko<-data.frame(GeneID=ko$V1,KO=ko$V3)
#   KOtable<-inner_join(ko,gff,by=c("GeneID"="GeneID"))
#   KOtable<-inner_join(KOtable,contigDepth,by=c("ContigID"="ContigID"))
#   KOtable<-group_by(KOtable,KO)
#   KOtable<-summarise(KOtable,TPM=sum(TPM))
#   KOtable$TPM<-KOtable$TPM/sum(KOtable$TPM)*10**6
#   KOtable<-arrange(KOtable,KO)
#   file.remove(files)
#   KOtable
# }

#### useful code ####

ramdisk<-"/run/user/17803"

unTarFiles <- function(fileName) {
  id<-str_sub(fileName,end = -8)
  files<-paste0(paste0(id,"/",id,".a."),c("depth.txt","gff","ko.txt"))
  untar(fileName,files=files,exdir=ramdisk)
  # absolute path
  files<-paste0(ramdisk,"/",files)
  # the 4th item is id
  files<-c(files,id)
  files
}

getKOtable <- function(files) {
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
  if (class(contigDepth$AvgFold) == "character"){
    print(paste(files[1], "AvgFold in Length_1231 type"))
    contigDepth$AvgFold <- as.numeric(str_sub(contigDepth$AvgFold, 8))
  }
  contigDepth$TPM <-
    contigDepth$AvgFold / sum(contigDepth$AvgFold) * 10 ** 6
  gff <- read.table(files[2], header = F, sep = "\t")
  gff <-
    data.frame(ContigID = gff$V1,
               GeneID = str_sub(str_extract(gff$V9, "locus_tag=.*?;"), 11, -2))
  ko <- read.table(files[3], header = F)
  ko <- data.frame(GeneID = ko$V1, KO = ko$V3)
  KOtable <- inner_join(ko, gff, by = c("GeneID" = "GeneID"))
  KOtable <-
    inner_join(KOtable, contigDepth, by = c("ContigID" = "ContigID"))
  KOtable <- group_by(KOtable, KO)
  KOtable <- summarise(KOtable, TPM = sum(TPM))
  KOtable$TPM <- KOtable$TPM / sum(KOtable$TPM) * 10 ** 6
  KOtable <- arrange(KOtable, KO)
  write.table(KOtable,paste0(files[4],"KOtable.txt"),quote = F,col.names = F,row.names = F)
  file.remove(files[1:3])
  KOtable
}

# a<-getKOtable(unTarFiles("3300019789.tar.gz"))
KOtables<-lapply(fileName, function(x) getKOtable(unTarFiles(x)))
saveRDS(KOtables,"KOtables.rds")
# nohup Rscript 'KO abundance analysis.R' > KOtables.log.txt 2>&1 &