#### Get a significative gene list from GSMR to filter input for TSMR and coloc


eqtlgen_all=vroom("../GSMR/nextflow/data/results/sdep_eqtlgen/results/results_eqtlgen_sdep.txt")

eqtlgen_all <- vroom("/data/home/julia.amorim/scripts/GSMR/nextflow/data/results/eqtlgen/results/results_bdep_eqtlgen.txt")

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
write(sign_genes, "gsmr_sdep_genelist.txt")
