
[E. coli protein fasta link](https://www.uniprot.org/proteomes/UP000000558)

Only regular search type has PTM. iMaxPTMcount will take effect in regular search type

### convert raw to ft

```bash
conda create -n mono
conda install -c conda-forge mono
conda activate mono
mono Raxport.exe -i raw -o ft
```

### scan for one percent of one file

```bash
cd /ourdisk/hpc/prebiotics/yixiong/auto_archive_notyet/Projects/SiprosDevelop/working
bin/SiprosV3omp \
    -c /ourdisk/hpc/prebiotics/yixiong/auto_archive_notyet/ubuntuShare/EcoliSIP/SiproConfig.Ecoli.C13.cfg \
    -f /ourdisk/hpc/prebiotics/yixiong/auto_archive_notyet/ubuntuShare/EcoliSIP/ft/Pan_022822_X1.FT2 \
    -o /ourdisk/hpc/prebiotics/yixiong/auto_archive_notyet/ubuntuShare/EcoliSIP/sip \
```

### filter peptide by FDR

```bash
cd /ourdisk/hpc/prebiotics/yixiong/auto_archive/ubuntuShare/EcoliSIP
python scripts/sipros_peptides_filtering.py \
  -c SiproConfig.Ecoli.C13.cfg \
  -w sip
```
### assemble protein

```bash
python scripts/sipros_peptides_assembling.py \
  -c SiproConfig.Ecoli.C13.cfg \
  -w sip
```

```bash
conda create -n py2 numpy biopython python=2.7
conda activate py2
cd /ourdisk/hpc/prebiotics/yixiong/auto_archive_notyet/Projects/SiprosDevelop/working
bin/SiprosV3omp \
    -c /ourdisk/hpc/prebiotics/yixiong/auto_archive_notyet/Projects/SiprosDevelop/data/SiproConfig.Ecoli.C13.cfg \
    -f /ourdisk/hpc/prebiotics/yixiong/auto_archive_notyet/ubuntuShare/EcoliSIP/Pan_022822_X1.FT2 \
    -o /ourdisk/hpc/prebiotics/yixiong/auto_archive_notyet/ubuntuShare/EcoliSIP/ \
    -s

cd /ourdisk/hpc/prebiotics/yixiong/auto_archive_notyet/ubuntuShare/EcoliSIP/

python scripts/sip.py \
    -c SiproConfig.Ecoli.C13.cfg \
    -w configFiles

# start 5 progresses, 1 master and 4 slaves
# each slave process one config file with one ft2 file using 10 threads
export OMP_NUM_THREADS=10
nohup mpirun -np 5 /ourdisk/hpc/prebiotics/yixiong/auto_archive_notyet/Projects/SiprosDevelop/working/bin/SiprosV3mpi \
  -g configFiles \
  -w . \
  -o pct100 \
  > pct100.log.txt 2>&1 & 

nohup python scripts/sipros_peptides_filtering.py \
  -c SiproConfig.Ecoli.C13.cfg \
  -w pct100 > filter.log.txt 2>&1 & 

python scripts/sipros_peptides_assembling.py \
  -c SiproConfig.Ecoli.C13.cfg \
  -w pct100

python scripts/ClusterSip.py \
  -c SiproConfig.Ecoli.C13.cfg \
  -w pct100
```
