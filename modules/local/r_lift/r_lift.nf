process R_LIFT {
  scratch true
  
  """
  Runs an Rscript on the merged .txt file
  """

  label 'process_medium'
  label "r_lift"

  container "juliaapolonio/mungesumstats:v1"

  input:
    path(merged)
    path(sumstats)

  output:
    path("${merged}_format.txt"), emit: lifted

  when:
  task.ext.when == null || task.ext.when  

  script:
    """
    #!/bin/bash
    Rscript ${workflow.projectDir}/bin/format_pqtl.R $merged ${merged}_format.txt $sumstats
    """
}
