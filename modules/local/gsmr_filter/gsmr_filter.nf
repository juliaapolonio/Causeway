process GSMR_FILTER {
  """
  Concatenate GSMR results, calculate padj and filter genes to output significant genelist
  """

  label 'process_medium'
  label 'ERRO'

  container "docker://juliaapolonio/coloc:5.2.3"

  input:
    path(reads)
    path(outcome)
    path(reference)

  output:
    path("*csv")        , emit: harmonised
    path("*md")         , emit: report
    path("figure")      , emit: figures

  when:
  task.ext.when == null || task.ext.when

  script:
  def prefix1 = reads.getBaseName()
  def prefix2 = outcome.getBaseName()
  """
  run_twosamplemr.R \\
    $prefix1 \\
    $prefix2 \\
    $reads \\
    $outcome \\
    $reference
  """
}
