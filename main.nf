/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    CONFIG FILES
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

data = Channel.fromPath("/storages/acari/julia.amorim/qtls/eqtl/eQTLGen_fstats/teste/*txt.gz")

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT NF-CORE MODULES/SUBWORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/


include { TWOSAMPLEMR } from "./modules/local/twosamplemr/tsmr.nf"
include { COLOC } from "./modules/local/coloc/coloc.nf"
include { GCTA_GSMR } from "./modules/local/gsmr/gsmr.nf"
include { RESULT } from "./modules/local/merge_results/results.nf"
include { PREPROCESS } from "./modules/local/preprocess_fstats/preprocess.nf"
include { PROCESS_REF } from "./modules/local/process_ref/process_ref.nf"
include { PARSE_2SMR } from "./modules/local/parse_2smr/parse_2smr.nf"
include { GSMR_FILTER } from "./modules/local/gsmr_filter/gsmr_filter.nf"
include { GENE_LIST } from "./modules/local/gene_list/gene_list.nf"
include { ADD_COLUMN as ADD_H_COLUMN } from "./modules/local/add_column/add_column.nf"
include { ADD_COLUMN as ADD_S_COLUMN } from "./modules/local/add_column/add_column.nf"
include { ADD_COLUMN as ADD_P_COLUMN } from "./modules/local/add_column/add_column.nf"
include { ADD_COLUMN as ADD_M_COLUMN } from "./modules/local/add_column/add_column.nf"
include { FINAL_REPORT } from "./modules/local/final_report/final_report.nf"

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/


workflow {

    if (params.run_vignette) {
        PREPROCESS ()
        
        PROCESS_REF (
           params.psam_url,
           params.pgen_url,
           params.pvar_url
            )
    }

    GCTA_GSMR (
	  data,
	  params.ref,
	  params.outcome
    )

    GSMR_FILTER (
	    GCTA_GSMR.out.gsmr_res.collect()
	    )

    GENE_LIST (
            data.collect(),
	    GSMR_FILTER.out.genelist
	    )

    TWOSAMPLEMR (
            GENE_LIST.out.filtered,
            params.outcome,
            params.ref
            )

    COLOC (
	    GENE_LIST.out.filtered,
	    params.outcome
	    )

    COLOC.out.merged_coloc
         .collectFile(name: 'concatenated_coloc.csv', storeDir: "${params.outdir}/collected_files/")
         .set { concatenated_coloc }

    TWOSAMPLEMR.out.mrpresso
        .collectFile(name: 'concatenated_mrpresso.txt', storeDir: "$params.outdir}/collected_files/")
        .set { concatenated_mrpresso }

    PARSE_2SMR (
	    TWOSAMPLEMR.out.report
	    )

    ADD_H_COLUMN (
	    PARSE_2SMR.out.results_heterogeneity,
    )
    ADD_H_COLUMN.out.formatted_report
        .collectFile(name: 'concatenated_h.csv', skip: 1, storeDir: "${params.outdir}/collected_files/")
        .set { concatenated_h }

    ADD_S_COLUMN (
	    PARSE_2SMR.out.results_steiger,
    )
    ADD_S_COLUMN.out.formatted_report
        .collectFile(name: 'concatenated_s.csv', skip: 1, storeDir: "${params.outdir}/collected_files/")
        .set { concatenated_s }

    ADD_P_COLUMN (
	    PARSE_2SMR.out.results_pleiotropy,
    )
    ADD_P_COLUMN.out.formatted_report
        .collectFile(name: 'concatenated_p.csv', skip: 1, storeDir: "${params.outdir}/collected_files/")
        .set { concatenated_p }

    ADD_M_COLUMN (
	    PARSE_2SMR.out.results_metrics,
    )
    ADD_M_COLUMN.out.formatted_report
        .collectFile(name: 'concatenated_m.csv', skip: 1, storeDir: "${params.outdir}/collected_files/")
        .set { concatenated_m }

    RESULT (
	    concatenated_coloc,
            GSMR_FILTER.out.filtered_genes,
            concatenated_h,
            concatenated_s,
            concatenated_p,
            concatenated_m,
            concatenated_mrpresso
    )

    FINAL_REPORT (
            GSMR_FILTER.out.results_gsmr,
            RESULT.out.final_results            
    )
}
