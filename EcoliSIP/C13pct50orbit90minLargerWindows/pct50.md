
```bash
conda activate mono
mono /ourdisk/hpc/prebiotics/yixiong/auto_archive_notyet/ubuntuShare/EcoliSIP/Raxport.exe -i raw -o ft
conda activate py2
python /ourdisk/hpc/prebiotics/yixiong/auto_archive_notyet/ubuntuShare/EcoliSIP/scripts/sip.py \
    -c  SiproConfig.Ecoli.C13.cfg \
    -w configs

nohup ./pct50.sh > pct50.log.txt 2>&1 &

nohup ./filter50.sh > filter50.log.txt 2>&1 &

python /ourdisk/hpc/prebiotics/yixiong/auto_archive_notyet/ubuntuShare/EcoliSIP/scripts/sipros_peptides_assembling.py \
  -c SiproConfig.Ecoli.C13.cfg \
  -w sip

python /ourdisk/hpc/prebiotics/yixiong/auto_archive_notyet/ubuntuShare/EcoliSIP/scripts/ClusterSip.py \
  -c SiproConfig.Ecoli.C13.cfg \
  -w sip
```

