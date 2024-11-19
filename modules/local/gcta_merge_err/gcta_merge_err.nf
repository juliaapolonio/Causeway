process GCTA_MERGE_ERR {
    publishDir "${params.outdir}/GCTA_GSMR/", mode: 'copy'

    input:
    path err_files

    output:
    path "gcta_error_genes.txt"

    script:
    """
    echo "# GCTA could not finish the analysis for the following
# molecular QTLs due to insufficient number of IVs: " > gcta_error_genes.txt
    cat ${err_files} >> gcta_error_genes.txt
    """
}