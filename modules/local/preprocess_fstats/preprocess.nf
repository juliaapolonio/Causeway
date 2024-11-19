process PREPROCESS {
  """
  Preprocess eQTLGen data to run MR
  """

  label 'process_medium'

  container "${ workflow.containerEngine == 'singularity' ? 'docker://juliaapolonio/ubuntu-wget:latest':
            'docker.io/juliaapolonio/ubuntu-wget:latest' }"

  output:
    path("*txt.gz")                                 , emit: qtl_sumstats
    path("eQTLGen_exposure_variants_extract.txt")   , emit: variants_extract

  when:
  task.ext.when == null || task.ext.when

  script:
  """
  setup_eqtlgen.sh
  """
}
