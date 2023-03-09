#!/bin/bash
source ~/miniconda3/etc/profile.d/conda.sh
binPath="/ourdisk/hpc/prebiotics/yixiong/auto_archive_notyet/ubuntuShare/EcoliSIP"
#seqkit rmdup amxgranules_db.faa -s -o amxNoDup.faa -D amxDup.txt
case $1 in
"mkdir")
    mkdir configs raw ft sip fasta
    conda activate r
    ${binPath}/configGenerator -i C13.cfg -o configs -e C
    ;;
"mkdb")
    conda activate r
    Rscript ${binPath}/makeDBforLabelSearch.R \
        -pro /scratch/yixiong/AMX/sip/Sipros_searches.pro.txt \
        -faa /scratch/yixiong/AMX/fasta/amxgranules_db.faa \
        -o fasta/db.faa
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
    conda activate mpi
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${CONDA_PREFIX}/lib
    # module load \
    #     CMake/3.15.3-GCCcore-8.3.0 \
    #     OpenMPI/3.1.4-GCC-8.3.0 \
    #     gperftools/2.7.90-GCCcore-8.3.0
    export OMP_NUM_THREADS=10
    binPath2=$binPath
    binPath="/scratch/yixiong/working/bin"
    time mpirun -np 9 $binPath/SiprosV3mpi \
        -g configs \
        -w /scratch/yixiong/AMX/ft \
        -o sip
    binPath=$binPath2
    echo "Filter PSM"
    conda activate pypy2
    time pypy ${binPath}/scripts/sipros_peptides_filtering.py \
        -c C13.cfg \
        -w sip
    pypy ${binPath}/scripts/sipros_peptides_assembling.py \
        -c C13.cfg \
        -w sip
    pypy ${binPath}/scripts/ClusterSip.py \
        -c C13.cfg \
        -w sip
    ;;
*)
    ./SIPcmd.sh "run"
    ;;
esac
