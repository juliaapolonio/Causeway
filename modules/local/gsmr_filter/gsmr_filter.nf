process GSMR_FILTER {
  """
  Concatenate GSMR results, calculate padj and filter genes to output significant genelist
  """

  label 'process_medium'
  label 'ERRO'

  container "docker://juliaapolonio/coloc:5.2.3"

  input:
    path(res_file)

  output:
    path("genelist.txt")        , emit: genelist

  when:
  task.ext.when == null || task.ext.when

  script:
  """
  extract_gene_list.R \\
    $res_file \\
  """
}
