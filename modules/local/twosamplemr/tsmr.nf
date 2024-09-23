process TWOSAMPLEMR {
  """
  Run TwoSampleMR on sumstats data
  """

  label 'process_medium'
  label 'ERRO'

  container "jvfe/twosamplemr:0.5.11"
  container "jvfe/twosamplemr:0.5.11"

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
