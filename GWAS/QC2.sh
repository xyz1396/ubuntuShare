#$ -cwd

CHR=$1
 
# directories
ROOT_DIR=../
DATA_DIR=${ROOT_DIR}data_files/
RESULTS_DIR=${ROOT_DIR}results/
 
# executable
EXEC=${ROOT_DIR}bin/plink
 
# GWAS data files in PLINK BED format
GWASDATA=${DATA_DIR}ukb_cal_chr${CHR}

# main output file
OUTPUT=${RESULTS_DIR}chr${CHR}

# filter out trios and variants with Mendel error
${EXEC} \
--bfile ${GWASDATA} \
--keep-allele-order \
--me 1 1 \
--set-me-missing \
--make-bed \
--out ${OUTPUT}.nomendel \

# --geno 0.05 Exclude variants with missing call frequencies greater than 0.05
# --mind 0.05 Exclude samples with missing call frequencies greater than 0.05
# --maf 0.01 Exclude variants with minor allele frequency lower than 0.01
# --hwe 0.0001 Exclude variants with Hardy-Weinberg equilibrium exact test p-values below 0.0001
${EXEC} \
--bfile ${OUTPUT}.nomendel \
--keep-allele-order \
--geno 0.05 \
--mind 0.05 \
--maf 0.01 \
--hwe 1e-6 \
--make-bed \
--out ${OUTPUT}.filter
