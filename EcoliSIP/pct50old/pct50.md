
```bash
python ../scripts/reverseseq.py \
  -i /ourdisk/hpc/prebiotics/yixiong/auto_archive_notyet/ubuntuShare/EcoliSIP/pct50old/Ecoli_UP000000558.fasta \
  -o Ecoli_Rev.fasta

python ../scripts/sip.py \
    -c  SiproConfig.EcoliPct50orbit.C13.cfg \
    -w configs

nohup ./pct50.sh > pct50.log.txt 2>&1 &

nohup ./filter50.sh > filter50.log.txt 2>&1 &

python ../scripts/sipros_peptides_assembling.py \
  -c SiproConfig.EcoliPct50orbit.C13.cfg \
  -w sip

python ../scripts/ClusterSip.py \
  -c SiproConfig.EcoliPct50orbit.C13.cfg \
  -w sip
```

