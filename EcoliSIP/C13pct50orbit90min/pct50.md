
```bash
conda activate mono
mono ../Raxport.exe
conda activate py2
python ../scripts/sip.py \
    -c  SiproConfig.Ecoli.C13.cfg \
    -w configs

nohup ./pct50.sh > pct50.log.txt 2>&1 &

nohup ./filter50.sh > filter50.log.txt 2>&1 &

python ../scripts/sipros_peptides_assembling.py \
  -c SiproConfig.Ecoli.C13.cfg \
  -w sip

python ../scripts/ClusterSip.py \
  -c SiproConfig.Ecoli.C13.cfg \
  -w sip
```

