# juliaapolonio/Causeway: Output

## Introduction

After running a Nextflow pipeline, all the results will be available in an output directory along the pipeline root that can be set using the `--outdir` flag. If no outdir is set, the folder will be named `null`. Inside the folder is expected that you have 6 more folders:

- collected_files: This folder will contain the results of each analysis performed individually, such as heterogeneity test, metrics (TwoSampleMR regressions), Coloc etc.
- coloc: This folder will contain all coloc outputs, that are for each GSMR-significant gene: a regional plot made with locuszoomr, a .txt file with H3, H4 and causal SNP, and another .png file with coloc's default plot.
- final_report: This folder will contain the outputs of all results modules. A detailed explanation of these files, as well as how to interpret the metrics, will be presented in the next section.
- GCTA_GSMR: This folder will contain GSMR's outputs: a .log file with GSMR's execution log; a .err file if the GSMR task fails for that phenotype; a .gsmr file with the analysis results; and a `gcta_error_genes.txt` file, that shows every phenotype that failed because of an insufficient number of IVs. 
- pipeline_info: Nextflow-generated informations about the pipeline run, such as RAM and storage consumption and execution time. You can check more information on what you can do with this data in the [Nextflow's documentation](https://www.nextflow.io/docs/latest/reports.html)
- twosamplemr: This is the folder with most of the files. In a nutshell, it has the TwoSampleMR analysis results separated by phenotype; and the TwoSampleMR's scatter plot for all metrics.

## Final Report folder

This folder contains all merged result files:
- Candidate gene list: a .txt file with all candidate effector phenotypes, separated by newline.
- final results: a .csv file with the analysis results combined for each phenotype, and if the phenotype is a candidate effector or not.
- summary report: an HTML report with the analysis highlights - an interactive volcano plot with candidates highlighted; an interactive forest plot with the candidates; and a table showing a brief of the metrics for each candidate, with the option to show the regional plot and MR scatter plot for each phenotype individually.

## A brief of the summary report

Important note: for the proper renderization of the report, it must be kept along with the pipeline output folder. If moving the HTML report file, ensure to move all the output folder together.

![Navigating an example report](https://i.giphy.com/media/v1.Y2lkPTc5MGI3NjExNzFxdjhpOWVtM2ZweW9wNmVnNDlsYWxmeHF2MmdhczgzYjA5cDZyOCZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/VG0lzESd2o6CxwU7y4/giphy.gif)

## How to interpret the results

#### Volcano plot

#### Forest plot

#### Regional plot

#### Scatter plot

#### GSMR metrics

#### TwoSampleMR regression metrics

#### TwoSampleMR pleiotropy metrics

#### TwoSampleMR direction metrics

#### TwoSampleMR heterogeneity metrics

#### TwoSampleMR rsquared metrics

#### Coloc metrics
