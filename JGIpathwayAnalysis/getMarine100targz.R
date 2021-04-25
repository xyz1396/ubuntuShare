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
  "-c cookies.txt > /dev/null"
)
system(command)


#### wget with cookie xargs ####

links <- read.table("marine100link.txt", header = T)
write.table(links,"marine100link2.txt",quote = F,col.names = F,row.names = F)
links$name <- str_extract(links$link, "\\d*?\\.tar\\.gz")
write.table(links, "marine100linkAndName.txt", row.names = F)

# file name too long
# nohup wget -c -t 0 -T 60 --load-cookies cookies.txt -i marine100link2.txt > marine100targz.log.txt 2>&1 &

# nohup tail -n +2 marine100linkAndName.txt | xargs -n2 bash -c 'wget -c -t 0 -T 60 --load-cookies cookies.txt $0 -O $1' > marine100targz.log.txt 2>&1 &



