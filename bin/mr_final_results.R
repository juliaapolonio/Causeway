#!/usr/bin/env Rscript
args <- commandArgs(trailingOnly = TRUE)

# Get results from GSMR, coloc and twosampleMR and merge to get the intersection of the significant genes
coloc_path <- args[1]
gsmr_path <- args[2]
tsmr_hetero_path <- args[3]
tsmr_steiger_path <- args[4]
tsmr_pleiotropy_path <- args[5]
tsmr_metrics_path <- args[6]

# Load data
coloc <- vroom(coloc_path, col_names = F)
gsmr <- vroom(gsmr_path)
tsmr_hetero <- vroom(tsmr_hetero_path, col_names = F)
tsmr_steiger <- vroom(tsmr_steiger_path, col_names = F)
tsmr_pleiotropy <- read.table(tsmr_pleiotropy_path)
tsmr_metrics <- vroom(tsmr_metrics_path, col_names = F)

# Name columns
colnames(gsmr) <- c("gene", "outcome","gsmr_beta", "gsmr_se", "gsmr_pval", "gsmr_nsnp", "gsmr_padj")
colnames(coloc) <- c("gene", "H3", "H4")
colnames(tsmr_metrics) <- c("gene", "method", "nsnp", "b", "se", "pval", "padj")
colnames(tsmr_pleiotropy) <- c("method", "pleiotropy_egger_intercept", "pleiotropy_se", "pleiotropy_pval")
colnames(tsmr_steiger) <- c("gene", "r2_exposure", "r2_oucome", "correct_dir", "steiger_pval")
colnames(tsmr_hetero) <- c("gene", "method", "Q", "Q_df", "Q_pval")

#Split method columns
tsmr_metrics <- tidyr::separate(data = tsmr_metrics, col = "gene", into = c("gene", "analysis"))
tsmr_steiger <- tidyr::separate(data = tsmr_steiger, col = "gene", into = c("gene", "analysis"))
tsmr_hetero <- tidyr::separate(data = tsmr_hetero, col = "gene", into = c("gene", "analysis"))
tsmr_pleiotropy <- tidyr::separate(data = tsmr_pleiotropy, col = "method", into = c("gene", "analysis"))
coloc$gene <- stringr::str_remove(coloc$gene, "\\_coloc_input")

tsmr_metrics$method <- gsub("\\s+", "_", tsmr_metrics$method)

# Spread dataframes
wide_hetero <- pivot_wider(tsmr_hetero, names_from = "method", values_from = c("Q", "Q_df", "Q_pval"))
tsmr_metrics$padj <- NULL
tsmr_metrics <- tsmr_metrics[!duplicated(tsmr_metrics), ]
wide_metrics <- pivot_wider(tsmr_metrics, names_from = "method", values_from = c("b", "se", "pval"), values_fill = 1)

# Join results
results_mr <- gsmr %>%
  inner_join(wide_hetero, by = "gene") %>%
  inner_join(wide_metrics, by = "gene") %>%
  inner_join(tsmr_steiger, by = "gene") %>%
  inner_join(coloc, by = "gene") %>%
  inner_join(tsmr_pleiotropy, by = "gene")

# Calculate Adjusted p-value
results_mr <- results_mr %>%
  mutate(adjp_MR_Egger=p.adjust(pval_MR_Egger,method="BH")) %>%
  mutate(adjp_Weighted_median=p.adjust(pval_Weighted_median,method="BH")) %>%
  mutate(adjp_Inverse_variance_weighted=p.adjust(pval_Inverse_variance_weighted,method="BH")) %>%
  mutate(adjp_Simple_mode=p.adjust(pval_Simple_mode,method="BH"))
  
# Create inclusion filter
is_candidate <- results_mr %>%
  filter(`Q_pval_MR_Egger` > 0.05 | `Q_pval_Inverse_variance_weighted` > 0.05) %>%
  filter(nsnp > 3) %>%
  filter(steiger_pval == 0) %>%
  filter(H4 > 0.8) %>%
  filter(pleiotropy_pval > 0.05) %>%
  mutate(
    pval_pass_egger = adjp_MR_Egger < 0.05,
    pval_pass_median = adjp_Weighted_median < 0.05,
    pval_pass_ivw = adjp_Inverse_variance_weighted < 0.05,
    pval_pass_mode = adjp_Simple_mode < 0.05,
    ) %>% 
  rowwise() %>% 
  mutate(
    pass = sum(pval_pass_egger, pval_pass_median, pval_pass_mode, pval_pass_ivw)
  ) %>% 
  filter(pass >= 2)

# Add column indicating significant genes
results_mr <- results_mr %>% 
  mutate(is_candidate <- ifelse(gene %in% is_candidate$gene, TRUE, FALSE))

results_mr$analysis = NULL
results_mr$analysis.x = NULL
results_mr$analysis.x.x = NULL
results_mr$analysis.y = NULL
results_mr$analysis.y.y = NULL
results_mr$method = NULL

results_mr$outcome <- "SDEP"

vroom_write(results_mr, "mr_merged_results_sdep.csv", delim = ",")
