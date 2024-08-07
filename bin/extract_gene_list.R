#### Get a significative gene list from GSMR to filter input for TSMR and coloc

args <- commandArgs(trailingOnly = TRUE)

library(vroom)
library(dplyr)

# Get path and filename of file
#eqtlgen_all_path <- "~/scripts/GSMR/nextflow/bdep_new_eqtlgen_gsmr/results/results_new_bdep_eqtlgen.txt"
eqtlgen_all_path <- args[1]
eqtlgen_all_name <- stringr::str_remove(eqtlgen_all_path, "\\.txt")

# Open and tidy file
eqtlgen_all=vroom(eqtlgen_all_path)
colnames(eqtlgen_all) <- c("Exposure", "Outcome", "bxy", "se", "p", "nsnp")

# Filter results based on pBH and nsnp
eqtlgen_result=eqtlgen_all %>% mutate("p"=as.numeric(p)) %>% filter(!is.na(p))
eqtlgen_result=eqtlgen_result %>% filter(nsnp>=3)
eqtlgen_result=eqtlgen_result %>% mutate(Q=p.adjust(p,method="BH"))
eqtlgen_result=eqtlgen_result %>% filter(Q<0.05)

# Correct gene name
eqtlgen_result$Exposure <- sapply(eqtlgen_result$Exposure, function(x) strsplit(x, "_")[[1]][1])

# Save file with significant genes info
vroom_write(eqtlgen_result, paste(eqtlgen_all_name, "_sign_genes.txt", sep = ""))

# Get gene list and save
sign_genes <- eqtlgen_result$Exposure
write(sign_genes, paste(eqtlgen_all_name, "_genelist.txt", sep = ""))
