
import os
import pandas as pd
import xlsxwriter

fileSelect=r'/scratch/dywang/Metagenome_Warming_site/M8_NB/CPM/KEGG_IDmapping.idmapping'
fileID=r'/scratch/dywang/Metagenome_Warming_site/M8_NB/CPM/srrID.txt'
wkdir=r'/scratch/dywang/Metagenome_Warming_site/M8_NB/CPM'


#get file list
files=[]
with open(fileID,'r') as f:
    for line in f:
        files.append(line.strip())

#read KEGG file and convert into Dataframe
lines=[]
with open(fileSelect,'r') as f:
    for line in f:
        items=line.split()
        lines.append([items[0], items[1], ' '.join(items[2:])])

dfKEGG=pd.DataFrame(lines,columns=['Name', 'A', 'B'])
#get matched gene list
dfKEGG['GA']=dfKEGG['Name']

#read RPKM file and merge
for file in files:
    df=pd.read_table(os.path.join(wkdir,file+'.txt'),header=None)
    cols=['{0:d}@{1:s}'.format(i,file) for i in range(len(df.columns))]
    cols[0]='GA'
    df.columns=cols
    dfKEGG=dfKEGG.merge(df,on='GA',how='left')

#replace empty data with ---
dfKEGG=dfKEGG.fillna('---')
#output Excel
dfKEGG.to_excel(os.path.join(wkdir,'rlt.xlsx'))

