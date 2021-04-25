account<-"yixiong@ou.edu"
password<-"4963123yz"
command<-paste0("curl 'https://signon.jgi.doe.gov/signon/create' ",
    "--data-urlencode ",
    "'login=",
    account,
    "' ",
    "--data-urlencode ",
    "'password=",
    password,
    "' ",
    "-c cookies > /dev/null")
# system(command)

# curl 'https://genome.jgi.doe.gov/portal/ext-api/downloads/get_tape_file?blocking=true&url=/PhytozomeV10/download/_JAMO/53112a9e49607a1be0055980/Alyrata_107_v1.0.annotation_info.txt' -b cookies > Alyrata_107_v1.0.annotation_info.txt
fileName<-"3300018917.tar.gz"
url<-"/IMG_3300018917/download/_JAMO/5945c4f37ded5e4e5bbce006/3300018917.tar.gz"
command<-paste0("curl ",
    "'https://genome.jgi.doe.gov/portal/ext-api/downloads/get_tape_file?blocking=true&url=",
    url,
    "' ",
    "-b cookies > ",
    fileName)
system(command)