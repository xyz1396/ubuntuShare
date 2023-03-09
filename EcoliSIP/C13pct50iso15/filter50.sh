#!/bin/bash
source ~/miniconda3/etc/profile.d/conda.sh
conda activate pypy2
time pypy /ourdisk/hpc/prebiotics/yixiong/auto_archive_notyet/ubuntuShare/EcoliSIP/scripts/sipros_peptides_filtering.py \
  -c SiproConfig.Ecoli.C13.cfg \
  -w sip 