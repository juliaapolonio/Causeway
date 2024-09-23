process RESULT {
  """
  Merge and resume all results and find candidate genes
  """

  label 'process_medium'
  label 'ERRO'

  container "juliaapolonio/coloc:5.2.3"
  container "juliaapolonio/coloc:5.2.3"

  input:
    path(coloc_path)
    path(gsmr_path)
    path(tsmr_hetero_path)
    path(tsmr_steiger_path)
    path(tsmr_pleiotropy_path)
    path(tsmr_metrics_path)

  output:
    path("genelist.txt")        , emit: genelist
    path("final_results.txt")        , emit: merged_results

  when:
  task.ext.when == null || task.ext.when

  script:
  """
  mr_final_results.R \\
    $coloc_path \\
    $gsmr_path \\
    $tsmr_hetero_path \\
    $tsmr_steiger_path \\
    $tsmr_pleiotropy_path \\
    $tsmr_metrics_path
  """
}
