process RESULT {
  """
  Merge and resume all results and find candidate genes
  """

  label 'process_medium'

  container "${ workflow.containerEngine == 'singularity' ? 'docker://rocker/tidyverse:latest':
            'docker.io/rocker/tidyverse:latest' }"

  input:
    path(coloc_path)
    path(gsmr_path)
    path(tsmr_hetero_path)
    path(tsmr_steiger_path)
    path(tsmr_pleiotropy_path)
    path(tsmr_metrics_path)
    path(tsmr_mrpresso_path)

  output:
    path("candidate_gene_list.txt")  , emit: genelist
    path("final_results.csv")        , emit: final_results

  when:
  task.ext.when == null || task.ext.when

  script:
  coloc_val = coloc_path ? coloc_path : 10
  """
  mr_final_results.R \\
    $coloc_val \\
    $gsmr_path \\
    $tsmr_hetero_path \\
    $tsmr_steiger_path \\
    $tsmr_pleiotropy_path \\
    $tsmr_metrics_path \\
    $tsmr_mrpresso_path
  """
}
