#!/bin/bash
module load \
    CMake/3.15.3-GCCcore-8.3.0 \
    OpenMPI/3.1.4-GCC-8.3.0 \
    gperftools/2.7.90-GCCcore-8.3.0
export OMP_NUM_THREADS=10
time mpirun -np 9 /ourdisk/hpc/prebiotics/yixiong/auto_archive_notyet/Projects/SiprosDevelop/working/bin/SiprosV3mpi \
  -g configs \
  -w /scratch/yixiong/ubuntuShare/EcoliSIP/C13pct50orbit90min/ft \
  -o sip