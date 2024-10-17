#!/bin/bash

#----------------------- Make reference file from 1000 Genomes data

#### Source of 1000 Genomes link: https://dougspeed.com/1000-genomes-project/
#### Source of code: https://cran.r-project.org/web/packages/snpsettest/vignettes/reference_1000Genomes.html

# "-O" to specify output file name
wget -O all_phase3.psam $1
wget -O all_phase3.pgen.zst $2
wget -O all_phase3.pvar.zst $3

# Decompress pgen.zst to pgen 
plink2 --zst-decompress all_phase3.pgen.zst > all_phase3.pgen

# "vzs" modifier to directly operate with pvar.zst
# "--chr 1-22" excludes all variants not on the listed chromosomes
# "--output-chr 26" uses numeric chromosome codes
# "--max-alleles 2": PLINK 1 binary does not allow multi-allelic variants
# "--rm-dup" removes duplicate-ID variants
# "--set-missing-var-id" replaces missing IDs with a pattern
plink2 --pfile all_phase3 vzs \
       --chr 1-22 \
       --output-chr 26 \
       --max-alleles 2 \
       --rm-dup exclude-mismatch \
       --set-missing-var-ids '@_#_$1_$2' \
       --make-pgen \
       --out all_phase3_autosomes

# Prepare sub-population filter file
awk 'NR == 1 || $5 == "EUR" {print $1}' all_phase3.psam > EUR_1kg_samples.txt

# Generate sub-population fileset
plink2 --pfile all_phase3_autosomes \
       --keep EUR_1kg_samples.txt \
       --make-pgen \
       --out EUR_phase3_autosomes

# pgen to bed
# "--maf 0.005" remove most monomorphic SNPs 
# (still may have some when all samples are heterozyguous -> maf=0.5)
plink2 --pfile EUR_phase3_autosomes \
       --maf 0.005 \
       --make-bed \
       --out 1KG_phase3_EUR
       
# Send all files to internal ref_folder
mkdir ref_folder
mv 1KG_phase3_EUR* ref_folder
