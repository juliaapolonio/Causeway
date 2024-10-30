
process RENDER_REPORT {
    label 'process_low'
    container "${workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ? 'https://depot.galaxyproject.org/singularity/mulled-v2-b2ec1fea5791d428eebb8c8ea7409c350d31dada:a447f6b7a6afde38352b24c30ae9cd6e39df95c4-1' : 'quay.io/biocontainers/mulled-v2-b2ec1fea5791d428eebb8c8ea7409c350d31dada:a447f6b7a6afde38352b24c30ae9cd6e39df95c4-1'}"

    input:
    path report_template
    path report_styles
    path report_logo
    path forest_plot
    path volcano_plot
    path final_results

    output:
    path ("summary_report.html"), emit: report

    when:
    task.ext.when == null || task.ext.when

    script:
    // USE JSON DATA AS PARAM FOR QUARTO REPORT
    def params_list_named = ["css='${report_styles}'", "report_logo='${report_logo}'", "workflow_manifest_version='${workflow.manifest.version}'", "forest_plot='${forest_plot}'", "volcano_plot='${volcano_plot}'", "final_results='${final_results}'"]
    params_list_named_string = params_list_named.findAll().join(',').trim()
    """
    #!/usr/bin/env Rscript
    library(rmarkdown)

    # Work around  https://github.com/rstudio/rmarkdown/issues/1508
    # If the symbolic link is not replaced by a physical file
    # output- and temporary files will be written to the original directory.
    file.copy("./${report_template}", "./template.Rmd", overwrite = TRUE)

    rmarkdown::render("template.Rmd", output_file = "summary_report.html", params = list(${params_list_named_string}), envir = new.env())
    """
}
