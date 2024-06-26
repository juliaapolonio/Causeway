#### Get a significative gene list from GSMR to filter input for TSMR and coloc


args <- commandArgs(trailingOnly = TRUE)
res_file <- args[1]

eqtlgen_all <- vroom(res_file)

# Filter results based on pBH and nsnp
eqtlgen_result=eqtlgen_all %>% mutate("p"=as.numeric(p)) %>% filter(!is.na(p))
eqtlgen_result=eqtlgen_result %>% filter(nsnp>3)
eqtlgen_result=eqtlgen_result %>% mutate(Q=p.adjust(p,method="BH"))
eqtlgen_result=eqtlgen_result %>% filter(Q<0.05)

# Correct gene name
eqtlgen_result$Exposure <- stringr::str_remove(eqtlgen_result$Exposure, "\\_GSMR")

vroom_write(eqtlgen_result, "gsmr_filtered_genes.txt")

# Get gene list and save
sign_genes <- eqtlgen_result$Exposure
write(sign_genes, "genelist.txt")
