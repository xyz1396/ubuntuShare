library(stringr)

#### login ####

account <- "yixiong@ou.edu"
password <- "4963123yz"
command <- paste0(
  "curl 'https://signon.jgi.doe.gov/signon/create' ",
  "--data-urlencode ",
  "'login=",
  account,
  "' ",
  "--data-urlencode ",
  "'password=",
  password,
  "' ",
  "-c cookies > /dev/null"
)
system(command)

#### download ####

links <- read.table("first10link.txt", header = T)

getTarGz <- function(link) {
  fileName <- str_extract(link, "\\d*?\\.tar\\.gz")
  command <- paste0("curl ",
                    "'",
                    link,
                    "' ",
                    "-b cookies.txt > ",
                    fileName)
  system(command)
}

sapply(links$link, getTarGz)

#### by wget ####

links <- read.table("soil100link.txt", header = T)

getTarGzWget <- function(link) {
  fileName <- str_extract(link, "\\d*?\\.tar\\.gz")
  command <- paste0("wget -c -t 0 --load-cookies cookies.txt",
                    " '",
                    link,
                    "' ",
                    "-O ",
                    fileName)
  system(command)
}

sapply(links$link, getTarGzWget)

#### wget with cookie xargs ####

links <- read.table("soil100link.txt", header = T)
write.table(links,"soil100link2.txt",quote = F,col.names = F,row.names = F)
links$name <- str_extract(links$link, "\\d*?\\.tar\\.gz")
write.table(links, "soil100linkAndName.txt", row.names = F)

# curl 'https://signon.jgi.doe.gov/signon/create' --data-urlencode 'login=yixiong@ou.edu' --data-urlencode 'password=4963123yz' -c cookies.txt > /dev/null
# nohup tail -n +2 soil100linkAndName.txt | xargs -n2 -P 4 bash -c 'wget -c -t 0 --load-cookies cookies.txt $0 -O $1' > downloadlog.txt 2>&1 &
# nohup tail -n +2 soil100linkAndName.txt | xargs -n2 bash -c 'wget -c -t 0 --load-cookies cookies.txt $0 -O $1' > downloadlog.txt 2>&1 &
# wget -c -t 0 --load-cookies cookies.txt -i soil100link2.txt