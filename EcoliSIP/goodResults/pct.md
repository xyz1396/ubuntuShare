
```bash
nohup ./SIPcmd.sh > pct50.log.txt 2>&1 &
nohup ../SIPcmd.sh run > pct0.log.txt 2>&1 &
nohup ../SIPcmd.sh run > pct50.log.txt 2>&1 &
nohup ../SIPcmd.sh run > pct25.log.txt 2>&1 &
nohup ./SIPcmd.sh run > log.txt 2>&1 &
nohup ./SIPcmd.sh filter > filter.log.txt 2>&1 &
nohup ../SIPcmdNitrogen.sh run > pct50.log.txt 2>&1 &
nohup ./SIPcmdNitrogen.sh run > AMD.log.txt 2>&1 &
nohup ./cmd.sh run > CK.log.txt 2>&1 &
nohup ./cmd.sh run > li.log.txt 2>&1 &
nohup ./cmd.sh run > log.txt 2>&1 &

a=($(ls -lht /scratch/yixiong/lizhouCO2/raw/*.raw | cut -d ' ' -f 9 | cut -d '/' -f 6 | cut -d '.' -f 1))
b=($(ls -lht /scratch/yixiong/lizhouCO2withPlant/sip/*.Spe2Pep.txt | cut -d ' ' -f 9 | cut -d '/' -f 6 | cut -d '.' -f 1))
# find item only in a
echo ${a[@]} ${b[@]} | tr ' ' '\n' | sort | uniq -u > sampleNotRun.txt

a=($(ls -lht /scratch/yixiong/lizhouCO2/raw/*.raw | cut -d ' ' -f 9 | cut -d '/' -f 6 | cut -d '.' -f 1))
b=($(ls -lht /scratch/yixiong/lizhouCO2withPlantLabeled/sip/*.sip | cut -d ' ' -f 9 | cut -d '/' -f 6 | cut -d '.' -f 1 | uniq -u))
# find item only in a
echo ${a[@]} ${b[@]} | tr ' ' '\n' | sort | uniq -u > sampleNotRun.txt

conda activate prokka
cd /scratch/yixiong/lizhou/fasta
nohup ./prokka.sh > mag.log.txt 2>&1 &
./mergeProteins.sh
mmseqs easy-cluster 14Samp1k_proteins_annot.renamed.faa clusterRes tmp --min-seq-id 0.5 -c 0.8 --cov-mode 1
seqkit rmdup largeDB/14Samp1k_proteins_annot.renamed.faa -s -o soilNodup.faa -D soilDup.txt
conda activate R

seqkit rmdup amxgranules_db.faa -s -o AMXnoDup.faa -D AMXnoDup.txt
nohup ./cmd.sh run > AMX.log.txt 2>&1 &
nohup ./SIPcmd.sh run > AMX.log.txt 2>&1 &
nohup ./SIPcmd.sh filter > filter.log.txt 2>&1 &
nohup ./CO2.sh run > CO2mpi.log.txt 2>&1 &

conda activate bio
seqkit rmdup Ga0526692_proteins.faa -s -o GaNoDup.faa -D GaDup.txt
conda activate pypy2
pypy bin/sipros_prepare_protein_database.py -i fasta/GaNoDup.faa -o fasta/GoNoDupDecoy.faa -c configs/SiprosConfig.cfg
conda activate mono
mono /ourdisk/hpc/prebiotics/yixiong/auto_archive_notyet/ubuntuShare/EcoliSIP/RaxportOld.exe -i raw -o ft
nohup bin/SiprosOMP -c configs/SiprosConfig.cfg -f ft/Pan_060222_B4_SF03.FT2 -o sip > wetland.log.txt 2>&1 &
```