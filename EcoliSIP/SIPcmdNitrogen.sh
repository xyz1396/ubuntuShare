#!/bin/bash
binPath="/ourdisk/hpc/prebiotics/yixiong/auto_archive_notyet/ubuntuShare/EcoliSIP"
case $1 in
"mkdir")
    mkdir configs raw ft sip fasta
    ${binPath}/configGenerator -i /scratch/yixiong/AMDpct50/SiproConfig.N15.cfg -o configs -e N
    ;;
"convert")
    source ~/miniconda3/etc/profile.d/conda.sh
    conda activate mono
    mono ${binPath}/Raxport.exe -i raw -o ft
    ;;
"clean")
    rm -r sip/* configs/*
    ;;
"run")
    echo "Search database"
    module load \
        CMake/3.15.3-GCCcore-8.3.0 \
        OpenMPI/3.1.4-GCC-8.3.0 \
        gperftools/2.7.90-GCCcore-8.3.0
    export OMP_NUM_THREADS=10
    binPath2=$binPath
    binPath="/scratch/yixiong/working/bin"
    time mpirun -np 9 $binPath/SiprosV3mpi \
        -g configs \
        -w ft \
        -o sip
    binPath=$binPath2
    source ~/miniconda3/etc/profile.d/conda.sh
    echo "Filter PSM"
    conda activate pypy2
    time pypy ${binPath}/scripts/sipros_peptides_filtering.py \
        -c /scratch/yixiong/AMDpct50/SiproConfig.N15.cfg \
        -w sip
    pypy ${binPath}/scripts/sipros_peptides_assembling.py \
        -c /scratch/yixiong/AMDpct50/SiproConfig.N15.cfg \
        -w sip
    pypy ${binPath}/scripts/ClusterSip.py \
        -c /scratch/yixiong/AMDpct50/SiproConfig.N15.cfg \
        -w sip
    ;;
*)
    ./SIPcmd.sh "run"
    ;;
esac
