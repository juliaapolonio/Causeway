
process RENDER_REPORT {
    label 'process_low'
    container "${workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ? 'oras://community.wave.seqera.io/library/r-dplyr_r-dt_r-formattable_r-ggplot2_pruned:2e69c6685edb51c7' : 'community.wave.seqera.io/library/r-dplyr_r-dt_r-formattable_r-ggplot2_pruned:ce4deb74423a0a8f'}"

    input:
    path forest_plot
    path volcano_plot
    path final_results

    output:
    path ("summary_report.html"), emit: report

    when:
    task.ext.when == null || task.ext.when

    script:
    // USE JSON DATA AS PARAM FOR QUARTO REPORT
    def params_list_named = ["css='$projectDir/assets/report_styles.css'", "report_logo='$projectDir/assets/horizontal_logo.png'", "workflow_manifest_version='${workflow.manifest.version}'", "forest_plot='${forest_plot}'", "volcano_plot='${volcano_plot}'", "final_results='${final_results}'"]
    params_list_named_string = params_list_named.findAll().join(',').trim()
    """
    #!/usr/bin/env Rscript
    library(rmarkdown)

    # Work around  https://github.com/rstudio/rmarkdown/issues/1508
    # If the symbolic link is not replaced by a physical file
    # output- and temporary files will be written to the original directory.
    file.copy("$projectDir/assets/summary_report.Rmd", "./template.Rmd", overwrite = TRUE)

    rmarkdown::render("template.Rmd", output_file = "summary_report.html", params = list(${params_list_named_string}), envir = new.env())
    """
}
