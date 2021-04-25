library(dplyr)
df <- read.delim("taxontable7261.xls")
df <- df[, -19]
df <-
  filter(
    df,
    GOLD.Ecosystem == "Environmental",
    GOLD.Analysis.Project.Type == "Metagenome Analysis",
    log10(Genome.Size.....assembled) > 7,
    !is.na(Latitude),
    !is.na(Longitude),
    Is.Public=="Yes"
  )

soil<-filter(df,GOLD.Ecosystem.Type=="Soil")
set.seed(9527)
soil100<-soil[sample(1:nrow(soil),100),]
write.table(data.frame(id=soil100$taxon_oid),"soil100.txt",row.names = F)
