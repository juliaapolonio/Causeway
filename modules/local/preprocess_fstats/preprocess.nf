process PREPROCESS {
  """
  Preprocess MetaBrain data to run MR
  """

  label 'process_medium'
  label 'ERRO'

  container "docker://juliaapolonio/coloc:5.2.3"

  input:
    path(qtl)

  output:
    path("*txt.gz")        , emit: qtl_sumstats

  when:
  task.ext.when == null || task.ext.when

  script:
  """
  preprocess_metabrain.sh \\
    $qtl \\
  """
}
