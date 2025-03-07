process QTL_FILTER {
    label 'process_low'

    container "${ workflow.containerEngine == 'singularity' ? 'docker://juliaapolonio/ubuntu-wget:latest':
            'docker.io/juliaapolonio/ubuntu-wget:latest' }"

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


    echo "Debug: Input file is ${sumstats}"
    echo "Debug: p_clump value is ${p_clump}"

    # Check if the file is gzipped
    if file ${sumstats} | grep -q gzip; then
        echo "Debug: File is gzipped"
        cat_cmd="zcat"
    else
        echo "Debug: File is not gzipped"
        cat_cmd="cat"
    fi

    # Print the first few lines of the file for debugging
    echo "Debug: First few lines of the file:"
    \$cat_cmd ${sumstats} | head -n 5

    # Find the minimum p-value in the 7th column
    min_pval=\$(\$cat_cmd ${sumstats} | awk 'NR>1 && \$7!="" {if(\$7+0<min || min=="") min=\$7+0} END {print (min==""?"NA":min)}')

    echo "Debug: Minimum p-value found: \$min_pval"

    # Check if the minimum p-value is smaller than p_clump
    if [ "\$min_pval" != "NA" ] && (( \$(echo "\${min_pval} < ${p_clump}" | bc -l) )); then
        pass_filter="true"
    else
        pass_filter="false"
    fi

    echo "Debug: pass_filter value: \$pass_filter"

    # Output the pass_filter value
    echo "pass_filter=\$pass_filter"

    """

}
