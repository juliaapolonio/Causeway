process TWOSAMPLEMR {
  """
  Run TwoSampleMR on sumstats data
  """

  label 'process_medium'
  label 'ERRO'

  container "jvfe/twosamplemr:0.5.11"

  input:
    path(exposure)
    path(outcome)
    path(reference)

  output:
    path("*csv")        , emit: harmonised
    path("*md")         , emit: report
    path("figure")      , emit: figures

  when:
  task.ext.when == null || task.ext.when

  script:
  """
  run_twosamplemr.R \\
    $exposure \\
    $outcome \\
    $reference
  """
}
