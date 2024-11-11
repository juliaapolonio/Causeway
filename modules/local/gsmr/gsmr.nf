process GCTA_GSMR {
    label 'GSMR'
    publishDir "${params.outdir}/results", mode: 'copy'

    container "${ workflow.containerEngine == 'singularity' ? 'docker://quay.io/biocontainers/gcta:1.94.1--h9ee0642_0':
              'quay.io/biocontainers/gcta:1.94.1--h9ee0642_0' }"

    input: 
    tuple val(meta), path(exposure), val(meta2), path(outcome)
    path(reference)

    output:
    path "${exposure.getBaseName(2)}_${outcome.baseName}.log", emit: gsmr_log
    path "${exposure.getBaseName(2)}_${outcome.baseName}.gsmr", emit: gsmr_res, optional: true
    path "${exposure.getBaseName(2)}_${outcome.baseName}.eff_plot.gz", emit: gsmr_effplt, optional: true

    script:
    """
    ulimit -c 0

    if [[ $exposure == *.gz ]]; then
        gunzip "$exposure"
    fi

    echo  "${exposure.getBaseName(2)} ${exposure.getBaseName(1)}" > ${exposure.getBaseName(2)}.input.txt
    echo "${outcome.baseName} $outcome" > outcome.txt
    echo "$reference/1KG_phase3_EUR" > reference.txt

    gcta  \
    --mbfile reference.txt  \
    --gsmr-file ${exposure.getBaseName(2)}.input.txt outcome.txt \
    --gsmr-direction 0   \
    --gsmr-snp-min 1   \
    --diff-freq 0.5   \
    --gwas-thresh 5e-8   \
    --clump-r2 0.05   \
    --heidi-thresh 0.01   \
    --effect-plot   \
    --out "${exposure.getBaseName(2)}_${outcome.baseName}"
    """
}

