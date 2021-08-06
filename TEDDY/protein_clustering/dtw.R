# nohup Rscript dtw.R > dtw.log.txt 2>&1 &

library(Mfuzz)
library(ggplot2)
library(clusterCrit)
library(dtwclust)

data <-
  read.table(
    "final_age_8stages_rpkm_0801",
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

ixs <- c()
for (c in 2:20) {
  set.seed(9527)
  cl <- tsclust(
    eset.m,
    type = "hierarchical",
    k = c,
    distance = "dtw_basic",
    trace = TRUE,
    control = hierarchical_control(method = "ward.D2")
  )
  ix <- unlist(intCriteria(eset.m, cl@cluster, "all"))
  ixs <- c(ixs, ix)
}
ixname <- names(ixs[1:42])
ixs <- matrix(ixs, nrow = 19, byrow = T)
colnames(ixs) <- ixname
ixs <- as.data.frame(ixs)
saveRDS(ixs,"ixs.rds")

df <- data.frame(x = 2:20, y = c(ixs$ball_hall))
p <- ggplot(df, aes(x = x, y = y)) +
  geom_line() +
  geom_point() +
  xlab("Number of clusters") +
  ylab("Ball Hall Index") +
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
p + ggsave("DTW Ball Hall Index.pdf", width = 8, height = 6)

df <- data.frame(x = 2:20, y = c(ixs$c_index))
p <- ggplot(df, aes(x = x, y = y)) +
  geom_line() +
  geom_point() +
  xlab("Number of clusters") +
  ylab("C Index") +
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
p + ggsave("DTW C Index.pdf", width = 8, height = 6)

df <- data.frame(x = 2:20, y = c(ixs$dunn))
p <- ggplot(df, aes(x = x, y = y)) +
  geom_line() +
  geom_point() +
  xlab("Number of clusters") +
  ylab("Dunn Index") +
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
p + ggsave("DTW Dunn Index.pdf", width = 8, height = 6)