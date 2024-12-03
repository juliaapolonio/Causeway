
include { RENDER_REPORT } from './modules/local/render_report'

// nextflow run render_report.nf --forest_plot report/forest.png --volcano_plot report/volcano.png --final_results report/final_results.csv --outdir results -profile docker

workflow {
    ch_report_template = Channel.fromPath("${params.report_template}", checkIfExists: true)
    ch_report_css = Channel.fromPath("${params.report_css}", checkIfExists: true)
    ch_report_logo = Channel.fromPath("${params.report_logo}", checkIfExists: true)

    ch_forest_plot = Channel.fromPath("${params.forest_plot}", checkIfExists: true)
    ch_volcano_plot = Channel.fromPath("${params.volcano_plot}", checkIfExists: true)
    ch_final_results = Channel.fromPath("${params.final_results}", checkIfExists: true)

    RENDER_REPORT(ch_forest_plot, ch_volcano_plot, ch_final_results)
}
