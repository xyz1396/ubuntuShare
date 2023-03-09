#!/bin/bash
source ~/miniconda3/etc/profile.d/conda.sh
binPath="/ourdisk/hpc/prebiotics/yixiong/auto_archive_notyet/ubuntuShare/EcoliSIP"
case $1 in
"mkdir")
    mkdir configs raw ft sip fasta
    ${binPath}/configGenerator -i C13.cfg -o configs -e C
    ;;
"mkdb")
    conda activate r
    Rscript ${binPath}/makeDBforLabelSearch.R \
        -pro /scratch/yixiong/pct1ensemble/sip/Pan_062822_X.pro.txt \
        -faa /ourdisk/hpc/prebiotics/yixiong/auto_archive_notyet/ubuntuShare/EcoliSIP/EcoliWithCrapNodup.fasta \
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
    # echo "Search database"
    # conda activate mpi
    # export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${CONDA_PREFIX}/lib
    # # module load \
    # #     CMake/3.15.3-GCCcore-8.3.0 \
    # #     OpenMPI/3.1.4-GCC-8.3.0 \
    # #     gperftools/2.7.90-GCCcore-8.3.0
    # export OMP_NUM_THREADS=10
    # binPath2=$binPath
    # binPath="/scratch/yixiong/working/bin"
    # time mpirun -np 16 $binPath/SiprosV3mpi \
    #     -g configs \
    #     -w ft \
    #     -o sip
    # binPath=$binPath2
    echo "Filter PSM"
    conda activate pypy2
    time pypy ${binPath}/scripts/sipros_peptides_filtering.py \
        -c C13.cfg \
        -w sip
    wait
    pypy ${binPath}/scripts/sipros_peptides_assembling.py \
        -c C13.cfg \
        -w sip
    wait
    pypy ${binPath}/scripts/ClusterSip.py \
        -c C13.cfg \
        -w sip
    wait
    filter() {
        mkdir $1
        cp sip/*$1*.sip $1
        pypy ${binPath}/scripts/sipros_peptides_filtering.py \
            -c C13.cfg \
            -w $1
        wait
        pypy ${binPath}/scripts/sipros_peptides_assembling.py \
            -c C13.cfg \
            -w $1
        wait
        pypy ${binPath}/scripts/ClusterSip.py \
            -c C13.cfg \
            -w $1
        wait
    }
    files=(ft/*.FT2)
    files=($(echo "${files[@]}" | tr ' ' '\n' | cut -d '/' -f2 | tr '\n' ' '))
    files=($(echo "${files[@]}" | tr ' ' '\n' | cut -d '.' -f1 | tr '\n' ' '))
    files=($(echo "${files[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))
    for folder in ${files[@]}; do
        filter "$folder" &
    done
    wait
    ;;
"filter")
    conda activate pypy2
    filter() {
        mkdir $1
        cp sip/*$1*.sip $1
        pypy ${binPath}/scripts/sipros_peptides_filtering.py \
            -c C13.cfg \
            -w $1
        pypy ${binPath}/scripts/sipros_peptides_assembling.py \
            -c C13.cfg \
            -w $1
        pypy ${binPath}/scripts/ClusterSip.py \
            -c C13.cfg \
            -w $1
    }
    files=(raw/*.raw)
    files=($(echo "${files[@]}" | tr ' ' '\n' | cut -d '/' -f2 | tr '\n' ' '))
    files=($(echo "${files[@]}" | tr ' ' '\n' | cut -d '.' -f1 | tr '\n' ' '))
    files=($(echo "${files[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))
    for folder in ${files[@]}; do
        filter "$folder" &
    done
    wait
    ;;
*)
    ./SIPcmd.sh "run"
    ;;
esac
