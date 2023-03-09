#!/bin/bash
source ~/miniconda3/etc/profile.d/conda.sh
conda activate pypy2
time pypy ../scripts/sipros_peptides_filtering.py \
  -c SiproConfig.Ecoli.C13.cfg \
  -w sip 