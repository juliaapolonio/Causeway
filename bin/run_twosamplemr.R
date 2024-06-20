#!/usr/bin/env Rscript
library(genetics.binaRies)
library(TwoSampleMR)
library(dplyr)

args <- commandArgs(trailingOnly = TRUE)

prefix_exp <- args[1]
prefix_outcome <- args[2]
exposure_path <- args[3]
outcome_path <- args[4]
ref <- args[5]

# prefix_exp <- "phylym_Actinobacteria"
# prefix_outcome <- "2100_both"
# exposure_path <- "data/phylum_Actinobacteria_merged.txt"
# outcome_path <- "data/2100.gwas.imputed_v3.both_sexes.tsv"

exp <-
  read_exposure_data(
    exposure_path,
    sep = "\t",
    snp_col = "SNP",
    beta_col = "b",
    se_col = "se",
    effect_allele_col = "A1",
    other_allele_col = "A2",
    pval_col = "p",
    eaf_col = "freq",
    samplesize_col = "N"
  )

exp[, "exposure"] <- prefix_exp

exp_filtered <- exp[which(exp$pval.exposure < 0.00001), ]

# mic_exp <- clump_data(exp_filtered, clump_r2 = 0.3)
mic_exp <- ieugwasr::ld_clump(
  exp_filtered |> dplyr::select(
    rsid = SNP,
    pval = pval.exposure,
    id = id.exposure
  ),
  clump_kb = 1000,
  clump_p = 5e-8,
  clump_r2 = 0.05,
  plink_bin = genetics.binaRies::get_plink_binary(),
  # bfile = "data/concat_ref/1KG_phase3_EUR"
  bfile = paste0(ref, "/1KG_phase3_EUR")
) |>
  dplyr::select(-c(pval, id)) |>
  dplyr::left_join(
    exp,
    by = c("rsid" = "SNP")
  ) |>
  dplyr::rename(SNP = "rsid")

outcome <-
  read_outcome_data(
    outcome_path,
    sep = "\t",
    snp_col = "SNP",
    beta_col = "b",
    se_col = "se",
    effect_allele_col = "A1",
    other_allele_col = "A2",
    pval_col = "p",
    eaf_col = "freq",
    samplesize_col = "N"
  )

outcome[, "outcome"] <- prefix_outcome

dat <- harmonise_data(exposure_dat = mic_exp, outcome_dat = outcome)

outfile <- paste(prefix_exp, prefix_outcome, sep = "_")

df <- add_rsq(dat)

write.table(
  df,
  file = paste0(outfile, ".csv"),
  sep = "\t",
  row.names = F,
  quote = F
)

mr_report(dat, output_type = "md")
