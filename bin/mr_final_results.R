# Get results from GSMR, coloc and twosampleMR and merge to get the intersection of the significant genes

# Load data
coloc <- vroom("merged_coloc_sdep.txt", col_names = F)
gsmr <- vroom("gsmr_filtered_genes_sdep.txt")
tsmr_hetero <- vroom("merged_heterogeneity_sdep.csv", col_names = F)
tsmr_steiger <- vroom("merged_steiger_sdep.csv", col_names = F)
tsmr_pleiotropy <- read.table("merged_pleiotropy_sdep.csv")
tsmr_metrics <- vroom("merged_metrics_sdep.csv", col_names = F)

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
  
# Create inclusion filter

is_candidate <- results_mr %>%
  filter(`Q_pval_MR_Egger` > 0.05 | `Q_pval_Inverse_variance_weighted` > 0.05) %>%
  filter(nsnp > 3) %>%
  filter(steiger_pval == 0) %>%
  filter(H4 > 0.8) %>%
  filter(pleiotropy_pval > 0.05) %>%
  mutate(
    pval_pass_egger = pval_MR_Egger < 0.05,
    pval_pass_median = pval_Weighted_median < 0.05,
    pval_pass_ivw = pval_Inverse_variance_weighted < 0.05,
    pval_pass_mode = pval_Simple_mode < 0.05,
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

#------------ Results for BDEP ------------------------

# Load data
coloc_bdep <- vroom("merged_coloc.txt", col_names = F)
gsmr_bdep <- vroom("gsmr_filtered_genes.txt")
tsmr_hetero_bdep <- vroom("merged_heterogeneity.csv", col_names = F)
tsmr_steiger_bdep <- vroom("merged_steiger.csv", col_names = F)
tsmr_pleiotropy_bdep <- read.table("merged_pleiotropy.csv")
tsmr_metrics_bdep <- vroom("merged_metrics.csv", col_names = F)

# Name columns
colnames(gsmr_bdep) <- c("gene", "outcome","gsmr_beta", "gsmr_se", "gsmr_pval", "gsmr_nsnp", "gsmr_padj")
colnames(coloc_bdep) <- c("gene", "H3", "H4")
colnames(tsmr_metrics_bdep) <- c("gene", "nsnp", "b", "se", "pval", "padj")
colnames(tsmr_pleiotropy_bdep) <- c("gene", "pleiotropy_egger_intercept", "pleiotropy_se", "pleiotropy_pval")
colnames(tsmr_steiger_bdep) <- c("gene", "steiger_pval")
colnames(tsmr_hetero_bdep) <- c("gene", "Q", "Q_df", "Q_pval")

#Split method columns
coloc_bdep <- tidyr::separate(data = coloc_bdep, col = "H", into = c("H3", "H4"), sep = "\t")
tsmr_metrics_bdep <- tidyr::separate(data = tsmr_metrics_bdep, col = "gene", into = c("gene", NA, "analysis"))
tsmr_steiger_bdep <- tidyr::separate(data = tsmr_steiger_bdep, col = "gene", into = c("gene", "analysis"))
tsmr_hetero_bdep <- tidyr::separate(data = tsmr_hetero_bdep, col = "gene", into = c("gene", NA, "method"))
tsmr_pleiotropy_bdep <- tidyr::separate(data = tsmr_pleiotropy_bdep, col = "gene", into = c("gene", NA))
coloc_bdep$gene <- stringr::str_remove(coloc_bdep$gene, "\\_coloc_input")
tsmr_steiger_bdep$gene <- stringr::str_remove(tsmr_steiger_bdep$gene, "\\_steiger")


# Spread dataframes
wide_hetero_bdep <- pivot_wider(tsmr_hetero_bdep, names_from = "method", values_from = c("Q", "Q_df", "Q_pval"))
wide_hetero_bdep <- na.omit(wide_hetero_bdep)
tsmr_metrics_bdep$padj <- NULL
tsmr_metrics_bdep <- tsmr_metrics_bdep[tsmr_metrics_bdep$gene != "ZZZ3",]
tsmr_metrics_bdep <- tsmr_metrics_bdep[!duplicated(tsmr_metrics_bdep), ]
wide_metrics_bdep <- pivot_wider(tsmr_metrics_bdep, names_from = "analysis", values_from = c("b", "se", "pval"))
wide_metrics_bdep <- na.omit(wide_metrics_bdep)


# Join results
results_mr_bdep <- gsmr_bdep %>%
  inner_join(wide_hetero_bdep, by = "gene") %>%
  inner_join(wide_metrics_bdep, by = "gene") %>%
  inner_join(tsmr_steiger_bdep, by = "gene") %>%
  inner_join(coloc_bdep, by = "gene") %>%
  inner_join(tsmr_pleiotropy_bdep, by = "gene")

# Create inclusion filter
is_candidate_bdep <- results_mr_bdep %>%
  filter(Q_pval_Egger > 0.05 | Q_pval_variance > 0.05) %>%
  filter(nsnp > 3) %>%
  filter(steiger_pval == 0) %>%
  filter(H4 > 0.8) %>%
  filter(pleiotropy_pval > 0.05) %>%
  mutate(
    pval_pass_egger = pval_Egger < 0.05,
    pval_pass_median = pval_median < 0.05,
    pval_pass_ivw = pval_variance < 0.05,
    pval_pass_mode = pval_mode < 0.05,
  ) %>% 
  rowwise() %>% 
  mutate(
    pass = sum(pval_pass_egger, pval_pass_median, pval_pass_mode, pval_pass_ivw)
  ) %>% 
  filter(pass >= 2)

# Add column indicating significant genes
results_mr_bdep <- results_mr_bdep %>% 
  mutate(is_candidate_bdep = ifelse(gene %in% is_candidate_bdep$gene, TRUE, FALSE))

results_mr_bdep$analysis = NULL
results_mr_bdep$analysis.x = NULL
results_mr_bdep$analysis.y = NULL
results_mr_bdep$method = NULL

vroom_write(results_mr_bdep, "mr_merged_results_bdep.csv", delim = ",")

