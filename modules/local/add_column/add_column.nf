process ADD_COLUMN {

container 'biocontainers/seaborn:0.12.2_cv1'

input:
  path(table)
  
output:
  path("*_formatted.csv"), emit: formatted_report
  
script:
  nome_do_gene = table.getSimpleName()
  """
  add_column.py $table $nome_do_gene ${nome_do_gene}_formatted.csv
  """
}
