process GCTA_GSMR {
    label 'GSMR'

    container "${ workflow.containerEngine == 'singularity' ? 'docker://quay.io/biocontainers/gcta:1.94.1--h9ee0642_0':
              'quay.io/biocontainers/gcta:1.94.1--h9ee0642_0' }"

    input: 
    tuple val(meta), path(exposure), val(meta2), path(outcome)
    path(reference)

    output:
    path "${meta.id}_${meta2.id}.log", emit: gsmr_log
    path "${meta.id}_${meta2.id}.gsmr", emit: gsmr_res, optional: true
    path "${meta.id}_${meta2.id}.err", emit: gsmr_err, optional: true

    script:
    """
    set +e
    ulimit -c 0

    if [[ $exposure == *.gz ]]; then
        gunzip "$exposure"
    fi

    echo "${meta.id} ${exposure.getBaseName(1)}" > ${meta.id}.input.txt
    echo "${meta2.id} $outcome" > outcome.txt
    echo "$reference/1KG_phase3_EUR" > reference.txt

    gcta  \
    --mbfile reference.txt  \
    --gsmr-file ${meta.id}.input.txt outcome.txt \
    --gsmr-direction 0   \
    --gsmr-snp-min 1   \
    --diff-freq 0.5   \
    --gwas-thresh 5e-8   \
    --clump-r2 0.05   \
    --heidi-thresh 0.01   \
    --out "${meta.id}_${meta2.id}"

    if [[ -f "${meta.id}_${meta2.id}.log" ]]; then
        # Check if the error message exists in the log file
        if [[ \$(grep -c "Error: not enough SNPs" "${meta.id}_${meta2.id}.log") -gt 0 ]]; then
            echo "${meta.id}" > ${meta.id}_${meta2.id}.err
            exit 0
        fi
    else
        # If the error message is not found, return the original exit code
        echo "No error found, or file does not exist."
        exit 1  # Or replace 1 with the actual exit code you want in this case
    fi
    """
}

