process GENE_LIST {
  """
  Move GSMR significant genes to another folder according to genelist
  """

  label 'process_medium'
  label 'ERRO'

  container "juliaapolonio/coloc:5.2.3"
  container "juliaapolonio/coloc:5.2.3"

  input:
    path(gene_list)

  output:
    path("genelist.txt")        , emit: genelist
    path("filtered/*")            , emit: filtered

  when:
  task.ext.when == null || task.ext.when

  script:
  """
  extract_gene_list.R \\
    $gsmr_result

  move_sign_genes.sh \\
    ${gsmr_result.getBasename(1)}_genelist.txt
  """
}
