#!/bin/bash

# conda create -n mpi -c conda-forge openmpi gxx_linux-64 gcc_linux-64
# get this script path
SCRIPTPATH="$(
    cd -- "$(dirname "$0")" >/dev/null 2>&1
    pwd -P
)"
echo $SCRIPTPATH
source ~/miniconda3/etc/profile.d/conda.sh
conda activate mpi
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${CONDA_PREFIX}/lib
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$SCRIPTPATH
# export OMP_NUM_THREADS=10
mpirun -np 8 $SCRIPTPATH/SiprosEnsembleMPI "$@"
