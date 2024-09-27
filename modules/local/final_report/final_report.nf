process FINAL_REPORT {
  """
  Plot volcano and forest plots based on GSMR and final MR results
  """

  label 'process_medium'

  container "juliaapolonio/my-tidyverse-ggrepel:latest"

  input:
    path(gsmr_path)
    path(mr_final_path)

  output:
    path("volcano.png")     , emit: volcano_plot
    path("forest.png")      , emit: forest_plot

  when:
  task.ext.when == null || task.ext.when

  script:
  """
  final_report.R \\
    $gsmr_path \\
    $mr_final_path \\

  """
}

