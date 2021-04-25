library(tidyverse)

df <- read.delim("taxontable7014_23-dec-2020.xls")
df <- df[, -25]
dfKEGG<-read.delim("taxontable107306_23-dec-2020kegg.xls")
df2<-cbind(df,dfKEGG[,10:13])

df2 <-
  filter(
    df2,
    GOLD.Analysis.Project.Type == "Metagenome Analysis",
    Has.Coverage == "Yes",
    !is.na(Latitude),
    !is.na(Longitude),
    Is.Public=="Yes",
    log10(KO.Count.....assembled) > 3
  )

# sort by Genome.Name...Sample.Name and KEGG.Count.....assembled
df3<-arrange(df2,Genome.Name...Sample.Name,desc(KEGG.Count.....assembled))
# reduplicate
# 106 removed
nrow(df2)-nrow(df3)
df3<-distinct(df3,Genome.Name...Sample.Name,.keep_all=T)
write.csv(df3,"MetaDataWithTaxonIDandSampleName_reduplicated.csv",row.names = F)

