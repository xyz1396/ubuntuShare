#$ -cwd
 
CHR=$1
 
# directories
ROOT_DIR=../
DATA_DIR=${ROOT_DIR}data_files/
RESULTS_DIR=${ROOT_DIR}results/
 
# executable
SHAPEIT_EXEC=${ROOT_DIR}bin/shapeit
 
# parameters
THREAT=20
EFFECTIVESIZE=11418
 
# reference MAP files
GENMAP_FILE=${DATA_DIR}genetic_map_GRCh37_chr${CHR}.txt
GENMAP_FILE_3=${RESULTS_DIR}genetic_map_GRCh37_chr${CHR}_3.txt
 
# GWAS data files in PLINK BED format
GWASDATA_BED=${RESULTS_DIR}chr${CHR}.filter.bed
GWASDATA_BIM=${RESULTS_DIR}chr${CHR}.filter.bim
GWASDATA_FAM=${RESULTS_DIR}chr${CHR}.filter.fam

# main output file
OUTPUT_HAPS=${RESULTS_DIR}chr${CHR}.haps
OUTPUT_SAMPLE=${RESULTS_DIR}chr${CHR}.sample
OUTPUT_LOG=${RESULTS_DIR}chr${CHR}.log

# keep last 3 columns of map file
cut $GENMAP_FILE -f 2- > $GENMAP_FILE_3
 
## phase GWAS genotypes
$SHAPEIT_EXEC \
--input-bed $GWASDATA_BED $GWASDATA_BIM $GWASDATA_FAM \
--input-map $GENMAP_FILE_3 \
--thread $THREAT \
--effective-size $EFFECTIVESIZE \
--output-max $OUTPUT_HAPS $OUTPUT_SAMPLE \
--output-log $OUTPUT_LOG