#!/bin/bash

# Check if the correct number of arguments is provided
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <gene_list>"
    exit 1
fi

# Assign command-line arguments to variables
gene_list="$1"

destination_dir = ./filtered

# Iterate over each gene name in the list
while IFS= read -r gene_name; do
    # Search for files matching the gene name pattern in the source directory
    matching_files=(./*"${gene_name}"_*)
    
    # Move matching files to the destination directory
    for file in "${matching_files[@]}"; do
        if [ -f "$file" ]; then
            mv "$file" "$destination_dir"
            echo "Moved $file to $destination_dir"
        fi
    done
done < "$gene_list"
