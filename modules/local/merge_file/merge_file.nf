process MERGE {
  scratch true
  
  """
  Merges files with names containing "chrX" (where X is 1-22)
  from each subdirectory into a single .txt file
  """

  label 'process_medium'
  label "merge"

  container 'ubuntu:22.04'
  
  input:
    path(untar_file)

  output:
    path("*.txt"), emit: merged

  when:
  task.ext.when == null || task.ext.when  

  script:
    """
    #!/bin/bash
      for subdir in \$(ls -d */)
        do zcat \$(find "\$subdir" -name "*chr[1-22]*") > "\${subdir%/}.txt"
        done
    """
}
