process COLOC {
  """
  Run Coloc on sumstats data and QTL
  """

  label 'process_medium'
  label 'ERRO'

  container "juliaapolonio/coloc:5.2.3"
  container "juliaapolonio/coloc:5.2.3"

  input:
    each(reads)
    path(outcome)

  output:
    path("*txt")        , emit: results
    path("*png")        , emit: plots

  when:
  task.ext.when == null || task.ext.when

  script:
  """
  colocalization.R \\
    $reads \\
    $outcome \\
  """
}
