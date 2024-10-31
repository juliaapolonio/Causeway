process PARSE_2SMR {
  """
  Parse TwoSampleMR reports into CSV tables
  """

  label 'process_medium'
  label 'ERRO'

  container "${ workflow.containerEngine == 'singularity' ? 'docker://biocontainers/pandas:1.5.1_cv1':
            'docker.io/biocontainers/pandas:1.5.1_cv1' }"

  input:
    path(report)

  output:
    path("*metrics.csv")        , emit: results_metrics
    path("*steiger.csv")        , emit: results_steiger
    path("*pleiotropy.csv")        , emit: results_pleiotropy
    path("*heterogeneity.csv")        , emit: results_heterogeneity

  when:
  task.ext.when == null || task.ext.when

  script:
  
  """
  parse_twosamplemr_reports.py \\
    $report
 
  """
}
