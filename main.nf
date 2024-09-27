/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    CONFIG FILES
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

data = Channel.fromPath("/storages/acari/julia.amorim/qtls/eqtl/eQTLGen_fstats/teste/*")
outcome = file("/storages/acari/julia.amorim/qtls/SDEP_rsID.txt")
//psam_url = "www.dropbox.com/s/6ppo144ikdzery5/phase3_corrected.psam"
//pgen_url = "www.dropbox.com/s/y6ytfoybz48dc0u/all_phase3.pgen.zst"
//pvar_url = "www.dropbox.com/s/odlexvo8fummcvt/all_phase3.pvar.zst"
true_ref_folder = file("/storages/acari/julia.amorim/references/tsmr_ref/")
//params.urlFile = "/home/jamorim/scratch/MR_workflow/teste.txt"

// Channel to read URLs from the file
//urls_ch = Channel
//    .fromPath(params.urlFile)
//    .splitText()
//    .filter { it.trim() }

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT NF-CORE MODULES/SUBWORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/


include { TWOSAMPLEMR } from "./modules/local/twosamplemr/tsmr.nf"
include { COLOC } from "./modules/local/coloc/coloc.nf"
include { GCTA_GSMR } from "./modules/local/gsmr/gsmr.nf"
include { RESULT } from "./modules/local/merge_results/results.nf"
//include { PREPROCESS } from "./modules/local/preprocess_fstats/preprocess.nf"
//include { PROCESS_REF } from "./modules/local/process_ref/process_ref.nf"
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

//    PROCESS_REF (
//	    psam_url,
//	    pgen_url,
//	    pvar_url
//	    )

//    PREPROCESS (
//	    urls_ch
//	    )

    GCTA_GSMR (
	  data,
	  true_ref_folder,
	  outcome,
          ref_file
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
            outcome,
            true_ref_folder
            )

    COLOC (
	    GENE_LIST.out.filtered,
	    outcome
	    )

   COLOC.out.merged_coloc
         .collectFile(name: 'concatenated_coloc.csv', storeDir: "${params.outdir}/collected_files/")
         .set { concatenated_coloc }


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
    )

    FINAL_REPORT (
            GSMR_FILTER.out.results_gsmr,
            RESULT.out.final_results            
    )
}
