#!/bin/bash

# Source directory where the files are located
source_dir="/storages/acari/julia.amorim/qtls/eqtl/eQTLGen_coloc"

# Destination directory where you want to move the files
destination_dir="/storages/acari/julia.amorim/qtls/eqtl/eQTLGen_coloc/significant_genes"

# Text file containing the list of gene names
gene_list="~/scripts/data/gsmr_gene_list.txt"

# Iterate over each gene name in the list
while IFS= read -r gene_name; do
    # Search for files matching the gene name pattern in the source directory
    matching_files=("$source_dir"/*"${gene_name}"*_coloc_input.txt.gz)
    
    # Move matching files to the destination directory
    for file in "${matching_files[@]}"; do
        if [ -f "$file" ]; then
            mv "$file" "$destination_dir"
            echo "Moved $file to $destination_dir"
        fi
    done
done < "$gene_list"
