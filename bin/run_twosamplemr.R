#!/usr/bin/env Rscript
library(TwoSampleMR)
library(dplyr)

args <- commandArgs(trailingOnly = TRUE)

exposure_path <- args[1]
prefix_exp <- gene_name <- sub(".*/filtered/([^_]+)_.*", "\\1", exposure_path)
outcome_path <- args[2]
prefix_outcome <- gene_name <- sub(".*/filtered/([^_]+)_.*", "\\1", outcome_path)
ref <- args[3]

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

mic_exp <- ieugwasr::ld_clump(
  exp_filtered |> dplyr::select(
    rsid = SNP,
    pval = pval.exposure,
    id = id.exposure
  ),
  clump_kb = 1000,
  clump_p = 5e-8,
  clump_r2 = 0.05,
  plink_bin = "/usr/local/bin/plink",
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


# Create outfile prefix
outfile <- paste(prefix_exp, prefix_outcome, sep = "_")

# Calculate rsquare for each association
df <- add_rsq(dat)

write.table(
  df,
  file = paste0(outfile, ".csv"),
  sep = "\t",
  row.names = F,
  quote = F
)

# Run MR-PRESSO and get global p-value
mrpresso <- run_mr_presso(dat, NbDistribution = 1000, SignifThreshold = 0.05)

mrpresso_pval <- mrpresso[[1]][["MR-PRESSO results"]]["Global Test"]$`Global Test`$Pvalue

write(c(prefix_exp, mrpresso_pval), ncolumns = 2, file = paste0(prefix_exp, "_mrpresso.txt"))

# Generate and save MR report with the other metrics
mr_report(dat, output_type = "md")


# Effect plot
res <- mr(dat)

p1 <- mr_scatter_plot(res, dat)

png(paste0(prefix_exp, "_effect.png"))

p1[[1]]

dev.off()
