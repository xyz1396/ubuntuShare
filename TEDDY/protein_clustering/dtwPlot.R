# nohup Rscript dtwPlot.R > dtwPlot.log.txt 2>&1 &

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
rt.abundance <- rowSums(rt)
rt.abundance <- rt.abundance / sum(rt.abundance) * 100
rt <- rt[rt.abundance > 0.001, ]
eset <- new("ExpressionSet", exprs = rt)
eset.r <- filter.NA(eset, thres = 0.25)
eset.f <- fill.NA(eset.r, mode = "mean")
eset.f <- filter.std(eset.f, min.std = 0)
eset.s <- standardise(eset.f)
eset.m <- t(as.data.frame(eset.s))

set.seed(9527)
hc <- tsclust(
  eset.m,
  type = "hierarchical",
  k = 3L,
  distance = "dtw_basic",
  trace = TRUE,
  control = hierarchical_control(method = "ward.D2")
)
# saveRDS(hc,"hc.rds")
saveRDS(hc@cluster, "cluster.rds")
saveRDS(hc@centroids, "centroid.rds")

p <- plot(hc, type = "sc")
p <-
  p + scale_x_continuous(breaks = 1:8,
                         labels = colnames(eset.m),
                         name = "Time")
p <- p + ylab("Abundance")
p <- p + theme(
  text = element_text(size = 15),
  panel.background = element_blank(),
  panel.grid.major = element_blank(),
  panel.grid.minor = element_blank()
)
p + ggsave("DTW Cluster.pdf", width = 18, height = 6)

p <- plot(hc, type = "centroids")
p <-
  p + scale_x_continuous(breaks = 1:8,
                         labels = colnames(eset.m),
                         name = "Time")
p <- p + ylab("Abundance")
p <- p + theme(
  text = element_text(size = 15),
  panel.background = element_blank(),
  panel.grid.major = element_blank(),
  panel.grid.minor = element_blank()
)
p + ggsave("DTW Cluster centroids.pdf",
           width = 18,
           height = 6)