process PROCESS_REF {
  """
  Preprocess 1000 Genomes data to use as MR reference
  """

  label 'process_medium'

  container "${ workflow.containerEngine == 'singularity' ? 'docker://biocontainer/plink2:alpha2.3_jan2020':
            'docker.io/biocontainer/plink2:alpha2.3_jan2020' }"

  input:
    val psam_url
    val pgen_url
    val pvar_url

  output:
    path("ref_folder")        , emit: ref_folder

  when:
  task.ext.when == null || task.ext.when

  script:
  """
  setup_bfile.sh \\
    $psam_url \\
    $pgen_url \\
    $pvar_url \\
  """
}

