process TWOSAMPLEMR {
  """
  Parse TwoSampleMR reports into CSV tables
  """

  label 'process_medium'
  label 'ERRO'

  container "docker://jvfe/parse_2mr_report:0.1.0"

  input:
    tuple val(meta), path(report)

  output:
    tuple val(meta), path("*_metrics.csv")        , emit: results_metrics
    tuple val(meta), path("*_steiger.csv")        , emit: results_steiger
    tuple val(meta), path("*_pleiotropy.csv")        , emit: results_pleiotropy
    tuple val(meta), path("*_heterogeneity.csv")        , emit: results_heterogeneity

  when:
  task.ext.when == null || task.ext.when

  script:
  prefix = task.ext.prefix ?: meta

  """
  process_twosamplemr_reports.py \\
    $report \\
    $prefix
  """
}
