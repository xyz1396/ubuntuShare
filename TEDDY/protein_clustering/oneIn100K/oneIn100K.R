# nohup Rscript onlyKEGG.R > onlyKEGG.log.txt 2>&1 &

library(Mfuzz)
library(ggplot2)
library(clusterCrit)
library(tidyr)

data <-
  read.table(
    "../final_age_8stages_rpkm_0801.txt",
    head = T,
    sep = "\t",
    stringsAsFactors = F,
    row.names = 1
  )
rt <- as.matrix(data)
rt.abundance<-rowSums(rt)
rt.abundance<-rt.abundance/sum(rt.abundance)*100
rt<-rt[rt.abundance>0.001,]
eset <- new("ExpressionSet", exprs = rt)
eset.r <- filter.NA(eset, thres = 0.25)
eset.f <- fill.NA(eset.r, mode = "mean")
eset.f <- filter.std(eset.f, min.std = 0)
eset.s <- standardise(eset.f)
eset.m <- t(as.data.frame(eset.s))

m <- mestimate(eset.s)
ixs <- c()
for (c in 2:20) {
  set.seed(9527)
  cl <- mfuzz(eset.s, c = c, m = m)
  print(paste(c,"mfuzz done"))
  ix <- unlist(intCriteria(eset.m,cl$cluster,"all"))
  print(paste(c,"index done"))
  ixs <- c(ixs, ix)
}
ixname <- names(ixs[1:42])
ixs <- matrix(ixs, nrow = 19, byrow = T)
colnames(ixs) <- ixname
ixs <- as.data.frame(ixs)
saveRDS(ixs,"ixs.rds")

bestK<-c()
for (i in ixname){
  bestK<-c(bestK,bestCriterion(ixs[,i],i))
}
bestK<-bestK+1
names(bestK)<-ixname
saveRDS(bestK,"bestK.rds")

bestK

ixs <- as.data.frame(scale(ixs))
ixsLong <- cbind(x = 2:20, ixs)
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