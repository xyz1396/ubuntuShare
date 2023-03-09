#!/bin/bash
binPath="/ourdisk/hpc/prebiotics/yixiong/auto_archive_notyet/ubuntuShare/EcoliSIP"
case $1 in
"mkdir")
    mkdir raw ft sip fasta
    ;;
"convert")
    source ~/miniconda3/etc/profile.d/conda.sh
    conda activate mono
    mono ${binPath}/Raxport.exe -i raw -o ft
    ;;
"clean")
    rm -r sip/*
    ;;
"run")
    source ~/miniconda3/etc/profile.d/conda.sh
    conda activate pypy2
    printf "\n=====Make decoy database=====\n\n"
    python ${binPath}/EnsembleScripts/sipros_prepare_protein_database.py \
        -i /scratch/yixiong/CK/fasta/CKluyveri_Protein.fasta \
        -o fasta/Decoy.fasta \
        -c SiprosEnsembleConfig.cfg
    printf "\n=====Search database=====\n\n"
    export OMP_NUM_THREADS=10
    files=(ft/*.FT2)
    echo "${files[@]}" | xargs -n 1 -P 8 \
        bash -c '/ourdisk/hpc/prebiotics/yixiong/auto_archive_notyet/ubuntuShare/EcoliSIP/SiprosEnsembleOMP -f $0 -c SiprosEnsembleConfig.cfg -o sip'
    wait
    printf "\n=====Filter PSM=====\n\n"
    python ${binPath}/EnsembleScripts/sipros_psm_tabulating.py \
        -i sip \
        -c SiprosEnsembleConfig.cfg -o sip
    python ${binPath}/EnsembleScripts/sipros_ensemble_filtering.py \
        -i sip/*.tab \
        -c SiprosEnsembleConfig.cfg \
        -o sip
    printf "\n====Assemble protein=====\n\n"
    python ${binPath}/EnsembleScripts/sipros_peptides_assembling.py \
        -c SiprosEnsembleConfig.cfg \
        -w sip
    ;;
*)
    ./cmd.sh "run"
    ;;
esac
