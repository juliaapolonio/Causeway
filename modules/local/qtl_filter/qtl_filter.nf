process QTL_FILTER {
    label 'process_low'

    container "${ workflow.containerEngine == 'singularity' ? 'docker://juliaapolonio/qtl_filter:v1.0':
            'docker.io/juliaapolonio/qtl_filter:v1.0' }"

    input:
    tuple val(meta), path(sumstats)
    val(p_clump)

    output:
    tuple val(meta), path(sumstats), env(pass_filter), emit: filtered_sumstats

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    
    """
    #!/usr/bin/env bash
    set -euo pipefail


    # Check if the file is gzipped
    if file ${sumstats} | grep -q gzip; then
        cat_cmd="zcat"
    else
        cat_cmd="cat"
    fi

    # Find the minimum p-value in the 7th column
    min_pval=\$(\$cat_cmd ${sumstats} | awk 'NR>1 && \$7!="" {if(\$7+0<min || min=="") min=\$7+0} END {print (min==""?"NA":min)}')

    # Check if the minimum p-value is smaller than p_clump
    if [ "\$min_pval" != "NA" ] && (( \$(echo "\${min_pval} < ${p_clump}" | bc -l) )); then
        pass_filter="true"
    else
        pass_filter="false"
    fi

    echo "pass_filter=\$pass_filter"

    """

}
