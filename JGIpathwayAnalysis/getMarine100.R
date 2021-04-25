library(tidyverse)

#### get id ####

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

marine<-filter(df,GOLD.Ecosystem.Type=="Marine")
set.seed(9527)
marine100<-marine[sample(1:nrow(marine),100),]
write.table(data.frame(id=marine100$taxon_oid),"marine100.txt",row.names = F)

# ssh c651
# conda activate R4
# nohup Rscript getLink100twoMethods.R marine100.txt marine100link.txt > marine100link.log.txt 2>&1 &
# exit