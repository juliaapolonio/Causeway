#!/usr/bin/env Rscript
args <- commandArgs(trailingOnly = TRUE)

qtl_path <- args[1]
gwas_path <- args[2]

# Run colocalization
library(coloc)

eqtl <- read.table(file=qtl_path, header=T, as.is=T); head(eqtl) 
gwas <- read.table(file=gwas_path, header=T, as.is=T); head(gwas)

eqtl$varbeta_eqtl <- eqtl$se^2
gwas$varbeta_gwas <- gwas$se^2

input <- merge(eqtl, gwas, by="SNP", all=FALSE, suffixes=c("_eqtl","gwas")); head(input)

dataset1=list(beta=input$bgwas, varbeta=input$varbeta_gwas, snp=input$SNP, type="quant", N=nrow(gwas), MAF=input$freqgwas)
dataset2=list(beta=input$b_eqtl, varbeta=input$varbeta_eqtl, snp=input$SNP, type="quant", N=nrow(eqtl), MAF=input$freq_eqtl)

result <- coloc.abf(dataset1,dataset2)


# Plot colocalization results
name <- sub(".*/filtered/([^_]+)_.*", "\\1", qtl_path)
png(filename = paste0(name,".png"))
sensitivity(result,rule="H4 >= 0.8")
dev.off()

# Write H3 and H4 and the causal SNP in a file
causal_snp <- result[[2]][which(result[[2]][11]==max(result[[2]][11])),1]
line <- paste(name, result[[1]][5], result[[1]][6], causal_snp, sep = "\t")
write(line,file=paste0(name,"_coloc.txt"))
