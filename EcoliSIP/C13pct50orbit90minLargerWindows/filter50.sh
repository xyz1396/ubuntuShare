#!/bin/bash
source ~/miniconda3/etc/profile.d/conda.sh
conda activate pypy2
time pypy /ourdisk/hpc/prebiotics/yixiong/auto_archive_notyet/ubuntuShare/EcoliSIP/scripts/sipros_peptides_filtering.py \
  -c /scratch/yixiong/ubuntuShare/EcoliSIP/C13pct50orbit90minLargerWindows/SiproConfig.Ecoli.C13.cfg \
  -w sip 