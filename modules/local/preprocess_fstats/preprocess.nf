process PREPROCESS {
  """
  Preprocess MetaBrain data to run MR
  """

  label 'process_medium'
  label 'ERRO'

  container "docker://ubuntu:22.04"

  input:
    path(qtl)

  output:
    path("*MR.txt.gz")        , emit: qtl_sumstats

  when:
  task.ext.when == null || task.ext.when

  script:
  """
  preprocess_metabrain.sh $qtl
  """
}
