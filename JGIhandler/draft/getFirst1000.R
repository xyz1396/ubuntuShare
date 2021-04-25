library(tidyverse)

#### get id ####

df <- read.delim("taxontable7014_23-dec-2020.xls")
df <- df[, -25]
# KO Count (Number of genes in KEGG Orthology (KO))
dfKEGG<-read.delim("taxontable107306_23-dec-2020kegg.xls")
# all is same
sum(dfKEGG$taxon_oid==df$taxon_oid)

ggplot(data.frame(Microbe=rep('Microbe',nrow(df)),Genome.Size=log10(df$Genome.Size.....assembled)),
       aes(x=Microbe,y=Genome.Size))+
  geom_violin(show.legend = FALSE)+
  geom_boxplot(width=.1,show.legend = FALSE)+
  ylab(expression(log[10]("Genome.Size")))+
  theme(text = element_text(size = 30),axis.text=element_text(colour="black"),
        axis.title.x=element_blank())
ggplot(data.frame(Microbe=rep('Microbe',nrow(df)),Gene.Count=log10(df$Gene.Count.....assembled)),
       aes(x=Microbe,y=Gene.Count))+
  geom_violin(show.legend = FALSE)+
  geom_boxplot(width=.1,show.legend = FALSE)+
  ylab(expression(log[10]("Gene.Count")))+
  theme(text = element_text(size = 30),axis.text=element_text(colour="black"),
        axis.title.x=element_blank())
ggplot(data.frame(Microbe=rep('Microbe',nrow(dfKEGG)),
                  KEGG.Count=log10(dfKEGG$KEGG.Count.....assembled)),
       aes(x=Microbe,y=KEGG.Count))+
  geom_violin(show.legend = FALSE)+
  geom_boxplot(width=.1,show.legend = FALSE)+
  ylab(expression(log[10]("KEGG.Count")))+
  theme(text = element_text(size = 30),axis.text=element_text(colour="black"),
        axis.title.x=element_blank())
ggplot(data.frame(Microbe=rep('Microbe',nrow(dfKEGG)),
                  KO.Count=log10(dfKEGG$KO.Count.....assembled)),
       aes(x=Microbe,y=KO.Count))+
  geom_violin(show.legend = FALSE)+
  geom_boxplot(width=.1,show.legend = FALSE)+
  ylab(expression(log[10]("KO.Count")))+
  theme(text = element_text(size = 30),axis.text=element_text(colour="black"),
        axis.title.x=element_blank())

df2<-cbind(df,dfKEGG[,10:13])

# df <-
#   filter(
#     df,
#     GOLD.Ecosystem == "Environmental",
#     GOLD.Analysis.Project.Type == "Metagenome Analysis",
#     log10(Genome.Size.....assembled) > 7,
#     !is.na(Latitude),
#     !is.na(Longitude),
#     Is.Public=="Yes"
#   )



# little of metagenome data's quality is high
sum(df$High.Quality == "Yes" & df$GOLD.Analysis.Project.Type == "Metagenome Analysis")

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

set.seed(9527)
first1000<-df2[sample(1:nrow(df2),1000),]
write.table(data.frame(id=first1000$taxon_oid),"first1000.txt",row.names = F)
