library(stringr)
library(tidyverse)
library(KEGGREST)
library(vegan)
library(ggalluvial)
library(maps)
library(KEGGgraph)
library(patchwork)

KOlist <- readRDS("soil100KOtables.rds")
md5 <- read.table("soil100md5.txt")
fileName <- str_sub(md5$V1[md5$V2 == md5$V3], end = -8)
names(KOlist) <- fileName
KOlist <- KOlist[!is.na(KOlist)]
KOdf <- reduce(KOlist, full_join, by = "KO")
colnames(KOdf)[-1] <- names(KOlist)
soilKOdf <- KOdf
soilKOdf[is.na(KOdf)] <- 0
soilKOdf$KO <- str_sub(KOdf$KO, 4)

KOlist <- readRDS("marine100KOtables.rds")
md5 <- read.table("marine100md5.txt")
fileName <- str_sub(md5$V1[md5$V2 == md5$V3], end = -8)
names(KOlist) <- fileName
KOlist <- KOlist[!is.na(KOlist)]
KOdf <- reduce(KOlist, full_join, by = "KO")
colnames(KOdf)[-1] <- names(KOlist)
marineKOdf <- KOdf
marineKOdf[is.na(KOdf)] <- 0
marineKOdf$KO <- str_sub(KOdf$KO, 4)

twoKOdf <- full_join(soilKOdf, marineKOdf, by = "KO")
twoKOdf[is.na(twoKOdf)] <- 0
twoKOdf <- as.data.frame(twoKOdf)
rownames(twoKOdf) <- twoKOdf$KO
twoKOdf <- t(twoKOdf[, -1])

metadata <- read.delim("taxontable7261.xls")
metadata <- metadata[,-20]
metadata <- metadata[match(rownames(twoKOdf), metadata$taxon_oid), ]

#### metadata constitution ####

tempDf <- data.frame(
  Ecosystem.Type = metadata$GOLD.Ecosystem.Type,
  Ecosystem.Subtype = metadata$GOLD.Ecosystem.Subtype
)
tempDf <- group_by(tempDf, Ecosystem.Type, Ecosystem.Subtype)
tempDf <- as.data.frame(summarise(tempDf, Count = n()))

ggplot(data = tempDf,
       aes(axis1 = Ecosystem.Type, axis2 = Ecosystem.Subtype,
           y = Count)) +
  scale_x_discrete(
    limits = c("Ecosystem.Type", "Ecosystem.Subtype"),
    expand = c(.1, .05)
  ) +
  geom_alluvium(aes(fill = Ecosystem.Subtype)) +
  geom_stratum() + geom_text(stat = "stratum", label.strata = TRUE) +
  theme_minimal() +
  ggsave(
    "SoilAndMarine100EcosystemType.png",
    width = 10,
    height = 20,
    dpi = 100
  )

#### metadata map ####

tempDf <- data.frame(
  Ecosystem.Type = metadata$GOLD.Ecosystem.Type,
  Ecosystem.Subtype = metadata$GOLD.Ecosystem.Subtype,
  Latitude = metadata$Latitude,
  Longitude = metadata$Longitude
)
# Marine   Soil 
# 84     73
table(metadata$GOLD.Ecosystem.Type)
# Oceanic Intertidal zone        Wetlands            Loam         Coastal
# 24                 21          16                  10           4
sort(table(metadata$GOLD.Ecosystem.Subtype), decreasing = T)[2:6]
top5 <-
  names(sort(table(metadata$GOLD.Ecosystem.Subtype), decreasing = T)[2:6])
tempDf$Ecosystem.Subtype[!(tempDf$Ecosystem.Subtype %in% top5)] <-
  "Others"
world_map <- map_data("world")
p <- ggplot(world_map, aes(x = long, y = lat, group = group)) +
  geom_polygon(fill = "lightgray", colour = "white") +
  geom_point(
    inherit.aes = FALSE,
    data = tempDf,
    aes(
      x = Longitude,
      y = Latitude,
      colour = Ecosystem.Type,
      shape = Ecosystem.Subtype
    ) ,
    size = 5
  )

p <- p + guides(colour = guide_legend(override.aes = list(size = 5)))
p + theme(
  text = element_text(size = 20),
  panel.border = element_rect(color = 'black',fill=NA, size=1),
  panel.background = element_blank()
) +
  ggsave(
    "SoilAndMarine100worldMap.png",
    width = 19.2,
    height = 10.8,
    dpi = 100
  )
#### PCA ####

pca <- rda(twoKOdf, scale = T)
importance <- summary(pca)[["cont"]][["importance"]]
siteScore <- summary(pca)[["sites"]]
tempDf <- data.frame(
  x = siteScore[, 1],
  y = siteScore[, 2],
  Ecosystem.Type = as.factor(metadata$GOLD.Ecosystem.Type),
  Ecosystem.Subtype = as.factor(metadata$GOLD.Ecosystem.Subtype)
)
ggplot(tempDf,
       aes(
         x = x,
         y = y,
         color = Ecosystem.Type,
         fill = Ecosystem.Type
       )) +
  geom_point(size = 3) +
  xlab(paste0("PC1(", round(importance[2, 1] * 100, 2), "%)")) +
  ylab(paste0("PC2(", round(importance[2, 2] * 100, 2), "%)")) +
  theme(text = element_text(size = 30)) +
  ggsave(
    "SoilAndMarinePCA.png",
    width = 10.24,
    height = 7.68,
    dpi = 100
  )

#### nmds ####

nmds <- metaMDS(twoKOdf, distance = 'bray', k = 2)
tempDf <- data.frame(
  x = nmds$points[, 1],
  y = nmds$points[, 2],
  Ecosystem.Type = metadata$GOLD.Ecosystem.Type,
  Ecosystem.Subtype = metadata$GOLD.Ecosystem.Subtype
)
tempDf$Ecosystem.Subtype[!(tempDf$Ecosystem.Subtype %in% top5)] <-
  "Others"
stress <- nmds$stress
ggplot(tempDf,
       aes(
         x = x,
         y = y,
         color = Ecosystem.Type,
         fill = Ecosystem.Type,
         shape=Ecosystem.Subtype
       )) +
  geom_point(size = 5) +
  xlab("MDS1") +
  ylab("MDS2") +
  labs(title = paste0("Stress=", round(stress, 3))) +
  theme(text = element_text(size = 30)) +
  ggsave(
    "SoilAndMarineNMDS.png",
    width = 19.2,
    height = 10.8,
    dpi = 100
  )

#### get annotations ####

# KO<-keggList("ko")
# KO.df<-data.frame(id=names(KO),term=KO)
# saveRDS(KO.df,"KO.df.rds")
KOannotation <- readRDS("KO.df.rds")
row.names(KOannotation) <- NULL
KOannotation$id <- str_sub(KOannotation$id, 4)
twoDfKOannotation <- KOannotation[match(colnames(twoKOdf), KOannotation$id),]

#### nitrogen cycle ####

nitrogen<-parseKGML2DataFrame("ko00910.xml",genesOnly=FALSE)
nitrogenKO<-unique(c(as.character(nitrogen$from),as.character(nitrogen$to)))
nitrogenKO<-str_sub(nitrogenKO[!str_detect(nitrogenKO,"path")],4)
twoKOdfnitrogen<-twoKOdf[,colnames(twoKOdf) %in% nitrogenKO]
twoKOdfnitrogenAnnotation<-KOannotation[match(colnames(twoKOdfnitrogen), KOannotation$id),]
data1 <- twoKOdfnitrogen
data1 <-
  data.frame(Ecosystem.Type = metadata$GOLD.Ecosystem.Type,
             data1)
data1$Ecosystem.Type <- as.factor(data1$Ecosystem.Type)

diff1 <- data1 %>%
  select_if(is.numeric) %>%
  map_df( ~ broom::tidy(t.test(. ~ Ecosystem.Type, data = data1)), .id = 'var')
diff1$q.value <- p.adjust(diff1$p.value, "bonferroni")
diff1.filter <- diff1 %>% filter(q.value < 0.05)
diff1.filter$annotation <-
  as.character(twoKOdfnitrogenAnnotation$term[match(diff1.filter$var, twoKOdfnitrogenAnnotation$id)])
write.csv(diff1.filter, "marineSoilKOdfnitrogenTTest.csv", row.names = F)

abun.bar <- data1[, c(diff1.filter$var, "Ecosystem.Type")] %>%
  gather(variable, value, -Ecosystem.Type) %>%
  group_by(variable, Ecosystem.Type) %>%
  summarise(Mean = mean(value))
abun.bar$variable <-
  as.character(twoKOdfnitrogenAnnotation$term[match(abun.bar$variable, twoKOdfnitrogenAnnotation$id)])

diff1.mean <-
  diff1.filter[, c("var", "estimate", "conf.low", "conf.high", "q.value")]
# 保留三位小数
diff1.mean$q.value <- format(round(diff1.mean$q.value, 3), nsmall = 2)
diff1.mean$var <-
  as.character(twoKOdfnitrogenAnnotation$term[match(diff1.mean$var, twoKOdfnitrogenAnnotation$id)])
diff1.mean$Ecosystem.Type <-
  c(ifelse(
    diff1.mean$estimate > 0,
    levels(data1$Ecosystem.Type)[1],
    levels(data1$Ecosystem.Type)[2]
  ))
diff1.mean <-
  diff1.mean[order(diff1.mean$estimate, decreasing = TRUE), ]

#### 绘图 ####

## 左侧条形图
cbbPalette <- c("#E69F00", "#56B4E9")
abun.bar$variable <-
  factor(abun.bar$variable, levels = rev(diff1.mean$var))
p1 <- ggplot(abun.bar, aes(variable, Mean, fill = Ecosystem.Type)) +
  scale_x_discrete(
    labels = function(x)
      stringr::str_wrap(x, width = 80)
  ) +
  coord_flip() +
  xlab("") +
  ylab("Mean proportion (%)") +
  theme(
    panel.background = element_rect(fill = 'transparent'),
    panel.grid = element_blank(),
    axis.ticks.length = unit(0.4, "lines"),
    axis.ticks = element_line(color = 'black'),
    axis.line = element_line(colour = "black"),
    text = element_text(family = "Times New Roman"),
    axis.title.x = element_text(colour = 'black', size = 12,face = "bold"),
    axis.text = element_text(colour = 'black', size = 10, ),
    legend.title = element_blank(),
    legend.text = element_text(
      size = 12,
      colour = "black",
      margin = margin(r = 20)
    ),
    legend.position = c(-1, -0.1),
    legend.direction = "horizontal",
    legend.key.width = unit(0.8, "cm"),
    legend.key.height = unit(0.5, "cm")
  )


for (i in 1:(nrow(diff1.mean) - 1))
  p1 <-
  p1 + annotate(
    'rect',
    xmin = i + 0.5,
    xmax = i + 1.5,
    ymin = -Inf,
    ymax = Inf,
    fill = ifelse(i %% 2 == 0, 'white', 'gray95')
  )

p1 <- p1 +
  geom_bar(
    stat = "identity",
    position = "dodge",
    width = 0.7,
    colour = "black"
  ) +
  scale_fill_manual(values = cbbPalette)


## 右侧散点图
diff1.mean$var <-
  factor(diff1.mean$var, levels = levels(abun.bar$variable))
p2 <- ggplot(diff1.mean, aes(var, estimate, fill = Ecosystem.Type)) +
  theme(
    panel.background = element_rect(fill = 'transparent'),
    text = element_text(family = "Times New Roman"),
    panel.grid = element_blank(),
    axis.ticks.length = unit(0.4, "lines"),
    axis.ticks = element_line(color = 'black'),
    axis.line = element_line(colour = "black"),
    axis.title.x = element_text(
      colour = 'black',
      size = 12,
      face = "bold"
    ),
    axis.text = element_text(
      colour = 'black',
      size = 10,
      face = "bold"
    ),
    axis.text.y = element_blank(),
    legend.position = "none",
    axis.line.y = element_blank(),
    axis.ticks.y = element_blank(),
    plot.title = element_text(
      size = 15,
      face = "bold",
      colour = "black",
      hjust = 0.5
    )
  ) +
  scale_x_discrete(limits = levels(diff1.mean$var)) +
  coord_flip() +
  xlab("") +
  ylab("Difference in mean proportions (%)") +
  labs(title = "95% confidence intervals")

for (i in 1:(nrow(diff1.mean) - 1))
  p2 <-
  p2 + annotate(
    'rect',
    xmin = i + 0.5,
    xmax = i + 1.5,
    ymin = -Inf,
    ymax = Inf,
    fill = ifelse(i %% 2 == 0, 'white', 'gray95')
  )

p2 <- p2 +
  geom_errorbar(
    aes(ymin = conf.low, ymax = conf.high),
    position = position_dodge(0.8),
    width = 0.5,
    size = 0.5
  ) +
  geom_point(shape = 21, size = 3) +
  scale_fill_manual(values = cbbPalette) +
  geom_hline(aes(yintercept = 0), linetype = 'dashed', color = 'black')


p3 <- ggplot(diff1.mean, aes(var, estimate, fill = Ecosystem.Type)) +
  geom_text(
    aes(y = 0, x = var),
    label = diff1.mean$q.value,
    family = "Times New Roman",
    hjust = 0,
    inherit.aes = FALSE,
    size = 3
  ) +
  geom_text(
    aes(x = nrow(diff1.mean) / 2 + 0.5, y = 0.4),
    label = "P-value (corrected)",
    srt = -90,
    size = 5,
    family = "Times New Roman"
  ) +
  coord_flip() +
  ylim(c(0, 1)) +
  theme(
    panel.background = element_blank(),
    panel.grid = element_blank(),
    axis.line = element_blank(),
    axis.ticks = element_blank(),
    axis.text = element_blank(),
    axis.title = element_blank(),
    text = element_text(family = "Times New Roman")
  )

## 图像拼接
p <- p1 + p2 + p3 + plot_layout(widths = c(4, 6, 2))

## 保存图像
ggsave(
  "marineSoilKOdfnitrogenSTAMP.png",
  width = 19.2,
  height = 10.8,
  dpi = 100
)

# yellow marine blue soil