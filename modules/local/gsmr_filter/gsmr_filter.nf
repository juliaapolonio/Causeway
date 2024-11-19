process GSMR_FILTER {
  """
  Concatenate GSMR results, calculate padj and filter genes to output significant genelist
  """

  label 'process_medium'

  container "${ workflow.containerEngine == 'singularity' ? 'docker://jvfe/twosamplemr:0.5.11':
            'docker.io/jvfe/twosamplemr:0.5.11' }"

  input:
    path(res_file)

  output:
    path("genelist.txt")        , emit: genelist
    path("filtered_genes.txt")  , emit: filtered_genes   
    path("results_gsmr.txt")    , emit: results_gsmr

  when:
  task.ext.when == null || task.ext.when

  script:
  """
  for file in $res_file; do sed -n '2p' \$file >> "results_gsmr.txt"; done

  extract_gene_list.R \\
    results_gsmr.txt \\
  """
}
