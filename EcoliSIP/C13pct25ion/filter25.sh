#!/bin/bash
source ~/miniconda3/etc/profile.d/conda.sh
conda activate py2
time python ../scripts/sipros_peptides_filtering.py \
  -c SiproConfig.Ecoli.C13.cfg \
  -w sip 