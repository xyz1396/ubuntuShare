## ----setup, include=FALSE----------------------------------------------------------------------
knitr::opts_chunk$set(echo = TRUE)


## ----------------------------------------------------------------------------------------------
library(Mfuzz)
library(ggplot2)
library(clusterCrit)
library(tidyr)
library(dplyr)


## ----------------------------------------------------------------------------------------------
df <-
  read.csv(
    "../Biomarkers Full Data Set_quant_BlkRemoved_missedinjRemoved_misslabeledRemoved_T_wMeta_TIC_urine_20210520.csv"
  )
meta <- df[, 1:10]
meta <- cbind(ID = paste0("X", 1:nrow(meta)), meta)
data <- df[, -1:-10]
rownames(data) <- meta$ID

data <- prop.table(as.matrix(data), 1)
Time <- meta$ATTRIBUTE_month_day
TimeLevel <- rep(0, length(Time))
TimeLevel[Time == "Sept_10"] <- 1
TimeLevel[Time == "Sept_16"] <- 2
TimeLevel[Time == "Sept_23"] <- 3
TimeLevel[Time == "Sept_30"] <- 4
TimeLevel[Time == "Oct_7"] <- 5
TimeLevel[Time == "Oct_21"] <- 6
TimeLevel[Time == "Oct_28"] <- 7
TimeLevel[Time == "Nov_12"] <- 8
TimeLevel[Time == "Nov_25"] <- 9
data <-
  cbind.data.frame(Time = TimeLevel,
                   Condition = meta$ATTRIBUTE_condition,
                   data)
data <- arrange(data, Time, Condition)
data <- group_by(data, Time, Condition)
data <- summarise(data, across(everything(), mean))
data <-
  pivot_wider(
    data,
    Time,
    names_from = Condition,
    values_from = !(Time:Condition),
    names_sep = "__"
  )
data<-as.matrix(data)
data[data==0]<-NA

rt <- as.matrix(t(data[,-1]))
eset <- new("ExpressionSet", exprs = rt)
eset.r <- filter.NA(eset, thres = 0.5)
eset.f <- fill.NA(eset.r, mode = "knnw")
eset.f <- filter.std(eset.f, min.std = 0.00001)
eset.s <- standardise(eset.f)
eset.m <- t(as.data.frame(eset.s))
dim(eset.m)

m <- mestimate(eset.s)
ixs <- c()
for (c in 2:20) {
  set.seed(9527)
  cl <- mfuzz(eset.s, c = c, m = m)
  ix <- unlist(intCriteria(eset.m,cl$cluster,"all"))
  ixs <- c(ixs, ix)
}
ixname <- names(ixs[1:42])
ixs <- matrix(ixs, ncol = 42, byrow = T)
colnames(ixs) <- ixname
ixs <- as.data.frame(ixs)
saveRDS(ixs,"ixsTreat.rds")
bestK<-c()
for (i in ixname){
  bestK<-c(bestK,bestCriterion(ixs[,i],i))
}
bestK<-bestK+1
names(bestK)<-ixname

#         ball_hall   banfeld_raftery           c_index calinski_harabasz 
#                 3                20                19                 2 
#    davies_bouldin         det_ratio              dunn             gamma 
#                 8                15                 2                20 
#            g_plus             gdi11             gdi12             gdi13 
#                20                 2                 2                 2 
#             gdi21             gdi22             gdi23             gdi31 
#                 7                13                13                 2 
#             gdi32             gdi33             gdi41             gdi42 
#                 6                 6                 7                 7 
#             gdi43             gdi51             gdi52             gdi53 
#                 7                 2                 2                 2 
#          ksq_detw     log_det_ratio      log_ss_ratio       mcclain_rao 
#                 3               NaN                 3                20 
#               pbm    point_biserial          ray_turi   ratkowsky_lance 
#                 2                 2                 7                 3 
#      scott_symons           sd_scat            sd_dis             s_dbw 
#               NaN                20                 7               NaN 
#        silhouette               tau           trace_w         trace_wib 
#                13                 4                 3                15 
# wemmert_gancarski          xie_beni 
#                 8                 3 
bestK

ixsLong <- as.data.frame(scale(ixs))
ixsLong <- cbind(x = 2:20, ixsLong)
ixsLong <- pivot_longer(ixsLong, -x, names_to = "Index", values_to = "y")

p <- ggplot(ixsLong, aes(x = x, y = y)) +
  geom_line() +
  geom_point() +
  xlab("Number of clusters") +
  ylab("Index") +
  scale_x_continuous(breaks = seq(2,20,by=2))+
  facet_wrap(vars(Index), ncol = 5) +
  theme(
    text = element_text(size = 15),
    panel.grid = element_blank(),
    panel.background = element_blank(),
    panel.border = element_rect(
      fill = NA,
      color = "grey10",
      linetype = 1,
      size = 1.
    )
  )

p+ggsave("All Indexes.pdf",width = 12,height = 12)

df<-data.frame(x=2:20,y=c(ixs$ball_hall))
p<-ggplot(df,aes(x=x,y=y))+
  geom_line()+
  geom_point()+
  xlab("Number of clusters")+
  ylab("Total within-clusters sum of squares")+
  theme(
    text = element_text(size = 15),
    panel.grid = element_blank(),
    panel.background = element_blank(),
    panel.border = element_rect(
      fill = NA,
      color = "grey10",
      linetype = 1,
      size = 1.
    ))
p+ggsave("ball_hall Index.pdf",width = 8,height = 6)


## ----------------------------------------------------------------------------------------------
set.seed(9527)
cl <- mfuzz(eset.s, c = 3, m = m)
pdf("mfuzz clust 3.pdf",width = 12,height = 4)
mfuzz.plot(
  eset.s,
  cl,
  mfrow = c(1, 3),
  new.window = FALSE,
  min.mem = 0.5
)
dev.off()
cl7<-cl$cluster
cl7<-data.frame(Protein=names(cl7),Cluster=cl7)
saveRDS(cl7,"cl.rds")

Cluster7<-cl$cluster
Cluster7<-data.frame(Protein=names(Cluster7),Cluster=Cluster7)
sum(rownames(cl$membership)==Cluster7$Protein)
Cluster7<-cbind(Cluster7,cl$membership)
Cluster7$MaxMembership<-apply(Cluster7[,-1:-2],1,max)
write.csv(Cluster7,"speciesCluster7.csv",row.names = F)

