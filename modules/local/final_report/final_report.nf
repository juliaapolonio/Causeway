process FINAL_REPORT {
  """
  Plot volcano and forest plots based on GSMR and final MR results
  """

  label 'process_medium'

  container "${ workflow.containerEngine == 'singularity' ? 'docker://juliaapolonio/my-tidyverse-ggrepel:latest':
            'docker.io/juliaapolonio/my-tidyverse-ggrepel:latest' }"

  input:
    path(gsmr_path)
    path(mr_final_path)

  output:
    path("volcano.png")          , emit: volcano_plot
    path("volcano_plot.rds")     , emit: volcano_rds
    path("forest.png")           , emit: forest_plot
    path("forest_plot.rds")      , emit: forest_rds

  when:
  task.ext.when == null || task.ext.when

  script:
  """
  final_report.R \\
    $gsmr_path \\
    $mr_final_path \\

  """
}

