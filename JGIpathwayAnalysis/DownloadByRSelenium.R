# conda create -n R4 r-base=4.0 r-tidyverse r-RCurl r-XML r-rselenium bioconductor-biostrings phantomjs -c bioconda -c conda-forge -c tkharrat
library(RSelenium)
remDr$open()
url<-"http://www.baidu.com"
remDr$navigate(url)
remDr$screenshot(display=F,useViewer=T,file="1.png")