process RESULT {
  """
  Merge and resume all results and find candidate genes
  """

  label 'process_medium'
  label 'ERRO'

  container "docker://juliaapolonio/coloc:5.2.3"

  input:
    path(gsmr_out)
    path(2smr_out)
    path(coloc_out)

  output:
    path("genelist.txt")        , emit: genelist
    path("final_results.txt")        , emit: merged_results

  when:
  task.ext.when == null || task.ext.when

  script:
  """
  mr_final_results.R \\
    $gsmr_out \\
    $2smr_out \\
    $coloc_out
  """
}
