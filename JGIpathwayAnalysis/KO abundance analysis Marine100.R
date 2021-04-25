library(stringr)
library(tidyverse)

# change node
# ssh c651

#### check md5 ####

df<-read.table("marine100md5.txt")
fileName<-df$V1[df$V2==df$V3]

#### unzip ####

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
    file.remove(files[1:3])
    return(NA)
  }
  # in case a.depth.txt is empty
  if (file.info(files[1])$size < 2048) {
    print(paste(files[1], "is empty"))
    file.remove(files[1:3])
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
  gff <- read.table(files[2], header = F, sep = "\t",quote = "")
  gff2 <-
    data.frame(ContigID = gff$V1,
               GeneID = str_sub(str_extract(gff$V9, "locus_tag=.*?;"), 11, -2))
  ko <- read.table(files[3], header = F)
  ko <- data.frame(GeneID = ko$V1, KO = ko$V3)
  KOtable <- inner_join(ko, gff2, by = c("GeneID" = "GeneID"))
  # in case the first column of a.ko.txt is ID of gff
  if (nrow(KOtable)==0) {
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
  write.table(KOtable,paste0(files[4],"KOtable.txt"),quote = F,col.names = F,row.names = F)
  file.remove(files[1:3])
  KOtable
}

# a<-getKOtable(unTarFiles("3300002231.tar.gz"))

KOtables<-lapply(fileName, function(x) getKOtable(unTarFiles(x)))
saveRDS(KOtables,"marine100KOtables.rds")

# ssh c651
# nohup Rscript 'KO abundance analysis Marine100.R' > KOtables.log.txt 2>&1 &
# exit