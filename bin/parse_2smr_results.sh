#!/bin/bash

# This script parses the .md reports from two sample MR output and creates 4 files: one for the result of each test with all genes
# Make sure you have all the files and the python script

for file in *.md; do desired_substring=$(basename "$file" | sed -E 's/.*\.([[:alnum:]]+)gsmrinput_.*/\1/'); python ~/scripts/python/parse_twosamplemr_reports.py $file $desired_substring; echo $desired_substring; done

mkdir modified_files
for i in *heterogeneity*; do
  awk 'NR==1{ sub(/\.csv$/, "", FILENAME) } NR>1{ $1=FILENAME "," $1 }1' "$i" |
    column -t > "./modified_files/$i"
done
for i in *steiger*; do
  awk 'NR==1{ sub(/\.csv$/, "", FILENAME) } NR>1{ $1=FILENAME "," $1 }1' "$i" |
    column -t > "./modified_files/$i"
done
for i in *metrics*; do
  awk 'NR==1{ sub(/\.csv$/, "", FILENAME) } NR>1{ $1=FILENAME "," $1 }1' "$i" |
    column -t > "./modified_files/$i"
done
for i in *pleiotropy*; do
  awk -F "," 'NR==1{ sub(/\.csv$/, "", FILENAME) } NR>1{ $1=FILENAME "," $1 }1' "$i" |
    column -t > "./modified_files/$i"
done

for file in ./modified_files/*heterogeneity*; do tail -n+2 $file >> merged_heterogeneity.csv; done
for file in ./modified_files/*steiger*; do tail -n+2 $file >> merged_steiger.csv; done
for file in ./modified_files/*metrics*; do tail -n+2 $file >> merged_metrics.csv; done
for file in ./modified_files/*pleiotropy*; do tail -n+2 $file >> merged_pleiotropy_comma.csv; done

cat ./modified_files/merged_pleiotropy_comma.csv | tr "," "\t" >> merged_pleiotropy.csv

