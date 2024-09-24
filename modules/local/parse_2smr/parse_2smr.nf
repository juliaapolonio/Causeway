process PARSE_2SMR {
  """
  Parse TwoSampleMR reports into CSV tables
  """

  label 'process_medium'
  label 'ERRO'

  container "biocontainers/pandas:1.5.1_cv1"

  input:
    each(report)

  output:
    path("*_metrics.csv")        , emit: results_metrics
    path("*_steiger.csv")        , emit: results_steiger
    path("*_pleiotropy.csv")        , emit: results_pleiotropy
    path("*_heterogeneity.csv")        , emit: results_heterogeneity

  when:
  task.ext.when == null || task.ext.when

  script:
  
  """
  parse_twosamplemr_reports.py \\
    $report \\
  """
}
