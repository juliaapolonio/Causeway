<a href="github.com/juliaapolonio/MR_workflow"><img src="assets/horizontal_logo.png" style="display: block; margin: 0 auto" height="298" /></a>


## Overview

**juliaapolonio/MR_workflow** is a pipeline for Mendelian Randomization and sensitivity analysis between a phenotype GWAS sumstats and QTL data.

The pipeline is built using [Nextflow](https://www.nextflow.io), a workflow tool to run tasks across multiple compute infrastructures in a very portable manner. It uses Docker/Singularity containers making installation trivial and results highly reproducible. The [Nextflow DSL2](https://www.nextflow.io/docs/latest/dsl2.html) implementation of this pipeline uses one container per process which makes it much easier to maintain and update software dependencies. 
As a future improvement, when possible, the local modules will be submitted to and installed from [nf-core/modules](https://github.com/nf-core/modules) in order to make them available to all nf-core pipelines, and to everyone within the Nextflow community!

## Pipeline summary

![pipeline summary](https://github.com/juliaapolonio/MR_workflow/blob/master/assets/causeway_diagram.png?raw=true)


### Generalized Summary Mendelian Randomization (GSMR)

This is the main part of the process. It runs [GSMR](https://yanglab.westlake.edu.cn/software/gcta/#MendelianRandomisation) for all Exposures vs the Outcome and returns number of IVs, betas, SEs and p-values for each exposure.

### Significant gene calculation and filtering

With the results from GSMR, this module calculates the FDR p-value for each gene and filters by it and the number of IVs. This step will substantially decrease the number of tasks for the subsequent processes, and therefore, the execution time for the pipeline.

### Two Sample MR (2SMR)

[Two Sample MR](https://mrcieu.github.io/TwoSampleMR/) is an R package that performs Mendelian Randomization and sensitivity analysis. The workflow is configured to run the following 2SMR tests:

- Inverse Variance Weighted regression;
- Simple Median regression;
- Simple mode regression;
- MR Egger regression;
- Heterogeneity Egger;
- Heterogeneity Inverse Variance Weighted;
- Steiger direction test;
- Pleiotropy Egger intercept;
- WIP: MR-PRESSO outlier analysis.

### Coloc

[Coloc](https://chr1swallace.github.io/coloc/) is an R package for colocalization analysis. For this workflow, the information retrieved from Coloc are:

- H3;
- H4;
- Most probable causal variant.

### Generate output report

This set of processes collects all results from the analysis and merges them into a single .csv file and the results are filtered to a list of candidate drug targets. A markdown report is generated with the analysis highlights.

## Quick Start

1. Install [`Nextflow`](https://www.nextflow.io/docs/latest/getstarted.html#installation) (`>=22.10.1`)

2. Install any of [`Docker`](https://docs.docker.com/engine/installation/), [`Singularity`](https://www.sylabs.io/guides/3.0/user-guide/) (you can follow [this tutorial](https://singularity-tutorial.github.io/01-installation/)), [`Podman`](https://podman.io/), [`Shifter`](https://nersc.gitlab.io/development/shifter/how-to-use/) or [`Charliecloud`](https://hpc.github.io/charliecloud/) for full pipeline reproducibility _(you can use [`Conda`](https://conda.io/miniconda.html) both to install Nextflow itself and also to manage software within pipelines. Please only use it within pipelines as a last resort; see [docs](https://nf-co.re/usage/configuration#basic-configuration-profiles))_.

3. Download the pipeline and test it on a minimal dataset with a single command:

```bash
nextflow run juliaapolonio/MR_workflow -profile test,YOURPROFILE --outdir <OUTDIR>
```

This will set up [eQTLGen cis-eQTL](https://eqtlgen.org/phase1.html) data and [1000 Genomes phase 3 dataset (GRCh37)](https://www.cog-genomics.org/plink/2.0/resources#1kg_phase3) genotype [p-file](https://www.cog-genomics.org/plink/2.0/formats#pgen) with [Finngen's Dysthymia or Depression sumstats](https://r11.finngen.fi/pheno/F5_DEPRESSION_DYSTHYMIA). 
Note that some form of configuration will be needed so that Nextflow knows how to fetch the required software. This is usually done in the form of a config profile (`YOURPROFILE` in the example command above).

> - The pipeline comes with config profiles called `docker`, `singularity`, `podman`, `shifter`, `charliecloud` and `conda` which instruct the pipeline to use the named tool for software management. For example, `-profile test,docker`.
> - Please check [nf-core/configs](https://github.com/nf-core/configs#documentation) to see if a custom config file to run nf-core pipelines already exists for your Institute. If so, you can simply use `-profile <institute>` in your command. This will enable either `docker` or `singularity` and set the appropriate execution settings for your local compute environment.
> - If you are using `singularity`, please use the [`nf-core download`](https://nf-co.re/tools/#downloading-pipelines-for-offline-use) command to download images first, before running the pipeline. Setting the [`NXF_SINGULARITY_CACHEDIR` or `singularity.cacheDir`](https://www.nextflow.io/docs/latest/singularity.html?#singularity-docker-hub) Nextflow options enables you to store and re-use the images from a central location for future pipeline runs.
> - If you are using `conda`, it is highly recommended to use the [`NXF_CONDA_CACHEDIR` or `conda.cacheDir`](https://www.nextflow.io/docs/latest/conda.html) settings to store the environments in a central location for future pipeline runs.

- Start running your own analysis!

```bash
nextflow run juliaapolonio/MR_workflow \
  --exposure <EXPOSURE_SAMPLESHEET> \
  --outdir <OUTDIR> \
  --ref <REFERENCE_FOLDER> \
  --outcome <OUTCOME_SAMPLESHEET> \
  -profile <docker/singularity/podman/shifter/charliecloud/conda/institute>
```

## Databases and references

MR_workflow needs 3 inputs to run:

- A reference folder;
- An Exposure sample sheet;
- An Outcome file.

Both Exposure and Outcome files should follow the [GCTA-Cojo format](https://yanglab.westlake.edu.cn/software/gcta/#COJO). The Exposure file should be separated by one gene per file. The reference files should be in [PLINK bfile](https://www.cog-genomics.org/plink/1.9/formats#bed) format.
Neither the Exposure nor the Outcome files should contain multi-allelic SNPs; the frequency (freq) is the Minor Allele Frequency (MAF). If the Outcome has a small number of SNPs (less than 2M) it is expected that a substantial amount of the tasks will fail due to lack or small number of matching IVs between the Exposure and Outcome data. If the Outcome data has a large number of SNPs (more than 10M) it is still expected that around 10% of GSMR tasks will fail.

## Outputs

If successfully run, the workflow should give three files as the main output:

- `summary_report.html` is a html report with all analysis highlights;
- `mr_merged_results.csv` should contain all analyses results for each GSMR significant gene;
- `significant_genes.txt` should give a gene list of all genes that fill the criteria defined in its paper.

Other intermediate outputs are stored in a folder with the corresponding process name.

## Credits

juliaapolonio/MR_workflow was authored by [Julia Apolonio](https://github.com/juliaapolonio/) with [João Cavalcante](https://github.com/jvfe/) and [Diego Coelho](https://github.com/diegomscoelho)'s assistance, under Dr. [Vasiliki Lagou](https://scholar.google.co.uk/citations?user=bjj5KdwAAAAJ&hl=en)'s supervision.


## Citations

> **Causal associations between risk factors and common diseases inferred from GWAS summary data.**
> 
> Zhihong Zhu, Zhili Zheng, Futao Zhang, Yang Wu, Maciej Trzaskowski, Robert Maier, Matthew R. Robinson, John J. McGrath, Peter M. Visscher, Naomi R. Wray & Jian Yang
>
> _Nature Communications_ 2018 Jan 15. doi: [10.1038/s41467-017-02317-2](https://doi.org/10.1038/s41467-017-02317-2)


> **The MR-Base platform supports systematic causal inference across the human phenome.**
>
> Hemani G, Zheng J, Elsworth B, Wade KH, Baird D, Haberland V, Laurin C, Burgess S, Bowden J, Langdon R, Tan VY, Yarmolinsky J, Shihab HA, Timpson NJ, Evans DM, Relton C, Martin RM, Davey Smith G, Gaunt TR, Haycock PC, The MR-Base Collaboration.
>
> _eLife_ 2018 Jul. doi: [10.7554/eLife.34408](https://doi.org/10.7554/eLife.34408)


> **Eliciting priors and relaxing the single causal variant assumption in colocalisation analyses**
>
> Chris Wallace
>
> _PLOS Genetics_ 2020 Apr 20. doi: [10.1371/journal.pgen.1008720](https://doi.org/10.1371/journal.pgen.1008720)


> **The nf-core framework for community-curated bioinformatics pipelines.**
>
> Philip Ewels, Alexander Peltzer, Sven Fillinger, Harshil Patel, Johannes Alneberg, Andreas Wilm, Maxime Ulysse Garcia, Paolo Di Tommaso & Sven Nahnsen.
>
> _Nat Biotechnol._ 2020 Feb 13. doi: [10.1038/s41587-020-0439-x](https://dx.doi.org/10.1038/s41587-020-0439-x).
