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

# Exclude variants with missing call frequencies greater than 0.05
${EXEC} \
--bfile ${OUTPUT}.nomendel \
--keep-allele-order \
--geno 0.05 \
--mind 0.05 \
--make-bed \
--out ${OUTPUT}.filter
