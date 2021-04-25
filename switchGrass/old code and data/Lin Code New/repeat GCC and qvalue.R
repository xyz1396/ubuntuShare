read.csv("CellWallComponent.csv", header=T,row.names = 1, sep=",")->wetchem

read.csv("GeneExpressionData.csv", header=T,row.names = 1, sep=",")->genes # gene expression data.csv

wg.matrix <-cbind(wetchem, genes)

t(wg.matrix)-> wg.matrix.t

library(rsgcc)

wg.gcc.total<-cor.matrix(wg.matrix.t, cormethod  = "GCC", cpus=12, style  =  "all.pairs", output= "matrix",sigmethod  = "two.sided", pernum  =  2000)

library(qvalue)

take.topr<-
function(x,y,z){x[c(1:y),c((y+1):(y+z))]->aa;aa}

take.topr(wg.gcc.total[[2]],ncol(wetchem),ncol(genes))-> wg.gcc.total.p

take.topr(wg.gcc.total[[1]],ncol(wetchem),ncol(genes))-> wg.gcc.total.gcc

 

#wg.gcc.total.p[-c(4,5,6),]-> wg.gcc.total.p.PS

#wg.gcc.total.gcc[-c(4,5,6),]-> wg.gcc.total.gcc.PS

 

qvalue(wg.gcc.total.p)-> wg.gcc.total.q

#qvalue(wg.gcc.total.p.PS) -> wg.gcc.total.q.PS

write.csv(wg.gcc.total.q$qvalues, file = "repeat_GCC_correlation.csv" )