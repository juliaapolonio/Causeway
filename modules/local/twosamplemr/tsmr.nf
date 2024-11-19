process TWOSAMPLEMR {
  """
  Run TwoSampleMR on sumstats data
  """

  label 'process_medium'

  container "${ workflow.containerEngine == 'singularity' ? 'docker://juliaapolonio/julia_2smr:latest':
            'docker.io/juliaapolonio/julia_2smr:latest' }"

  input:
    tuple path(exposure), val(meta), path(outcome)
    path(reference)

  output:
    path("*md")              , emit: report
    path("*csv")             , emit: data
    path("figure")           , emit: figures
    path("*png")             , emit: effplot
    path("*mrpresso*")       , emit: mrpresso
  
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
