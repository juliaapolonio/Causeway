# juliaapolonio/Causeway: Usage

## Inputs

Causeway needs 3 different inputs:

### Exposure samplesheet

It is a .csv file containing the exposure phenotype name (i.e. gene name in eQTL) and path to the summary statistics file. It must have a header `sample,path` and should have one line per phenotype. [Check the test data file](https://github.com/juliaapolonio/Causeway/blob/master/testdata/samplesheet_exposure.csv) for an example of an exposure samplesheet.

### Outcome samplesheet

It is a .csv file containing the outcome phenotype name (i.e. Type2Diabetes) and path to the summary statistics file. It must have a header `sample,path` and should have one line per phenotype. [Check the test data file](https://github.com/juliaapolonio/Causeway/blob/master/testdata/samplesheet_outcome.csv) for an example of an outcome samplesheet.

### Reference folder

Instead of downloading the reference files at each execution (around 2GB of data), you can have the files locally and point to the pipeline a folder where the data is. The reference must not be split by chromosome, and there should be 3 files with the following extensions: .bed, .bim and .fam. The folder should not be zipped as well. Check the [Zenodo reference file](https://zenodo.org/records/14024924/files/ref.tar?download=1) provided for an example of reference folder.

Important note: the example file is a reference for European population. If your data is from another ancestry, provide your reference data accordingly. If you need assistance on how to convert p-files to the required format, check [setup_bfile.sh](https://github.com/juliaapolonio/Causeway/blob/master/bin/setup_bfile.sh) script.

### Exposure and Outcome summary statistics format

All exposure/outcome files should be in [GCTA-Cojo format](https://yanglab.westlake.edu.cn/software/gcta/#COJO), which is:

`SNP A1 A2 freq b se p N`

Columns are SNP (rsID identifier), the effect allele, the other allele, frequency of the effect allele, effect size, standard error, p-value and sample size. Important: "A1" needs to be the effect allele with "A2" being the other allele and "freq" should be the frequency of "A1".

## Replication of the paper analysis

To replicate the analysis, download and untar [the data](linkplaceholder) inside the root of the pipeline. Then, use the following command:

```bash
nextflow run juliaapolonio/Causeway \
  --exposures replicate_analysis/samplesheet_exposure.csv \
  --outdir replication \
  --ref ${pwd}/replicate_analysis/tsmr_ref/ \
  --outcomes replicate_analysis/samplesheet_outcome.csv \
  -profile <docker/singularity/podman/shifter/charliecloud/conda/institute>
```

## Optional flags

Some optional flags can be added to the pipeline execution:

### run_eqtlgen

This flag runs the analysis with [eQTLGen cis-eQTL](https://eqtlgen.org/phase1.html) data. It is still needed to supply the Outcomes samplesheet.

### WIP: create_ref

This flag builds the reference b-files from the [Plink 2 resource p-files](https://www.cog-genomics.org/plink/2.0/resources#1kg_phase3) links.

### WIP: skip_reports

This flag skip the report rendering module

### WIP: skip_twosamplemr

This flag skips the TwoSampleMR process and all subsequent steps

### WIP: skip_coloc

This flag skips the coloc process and all subsequent steps

## System requirements

To ensure smooth execution of the pipeline, the following system requirements must be met:

### Hardware Requirements

- CPU: Minimum of 4 cores (16 or more recommended for faster execution).

- RAM: At least 6 GB (50GB or more recommended for large datasets).

### Storage:

- Minimum of 20 GB of available disk space for intermediate files and outputs.

- Additional space may be required depending on the size of input datasets.

### Operating System

Supported Platforms:

- Linux 

- macOS 

- Windows Subsystem for Linux 

### Software Requirements

- Pipeline Management: [`Nextflow`](https://www.nextflow.io/docs/latest/getstarted.html#installation) (`>=22.10.1`). Note: Nextflow requires Bash 3.2 (or later) and Java 17 (or later, up to 23)

### Dependencies and Package Managers

- You don´t need to install any dependencies apart from Nextflow. 

- Install any of [`Docker`](https://docs.docker.com/engine/installation/), [`Singularity`](https://www.sylabs.io/guides/3.0/user-guide/) (you can follow [this tutorial](https://singularity-tutorial.github.io/01-installation/)), [`Podman`](https://podman.io/), [`Shifter`](https://nersc.gitlab.io/development/shifter/how-to-use/) or [`Charliecloud`](https://hpc.github.io/charliecloud/) for full pipeline reproducibility _(you can use [`Conda`](https://conda.io/miniconda.html) both to install Nextflow itself and also to manage software within pipelines. Please only use it within pipelines as a last resort; see [docs](https://nf-co.re/usage/configuration#basic-configuration-profiles))_.

### Network Access

Required for downloading dependencies and container images during setup.

### Visualization Tools

A software that renders HTML files (such as any web browser) for visualization of the summary report.

### Testing Environment

A small test dataset is included with the pipeline to verify the installation and setup. Ensure the system can successfully execute the test workflow before running large-scale analyses.

## Some Nextflow and nf-core settings

### Updating the pipeline

When you run the above command, Nextflow automatically pulls the pipeline code from GitHub and stores it as a cached version. When running the pipeline after this, it will always use the cached version if available - even if the pipeline has been updated since. To make sure that you're running the latest version of the pipeline, make sure that you regularly update the cached version of the pipeline:

```bash
nextflow pull juliaapolonio/Causeway
```

### Reproducibility

It is a good idea to specify a pipeline version when running the pipeline on your data. This ensures that a specific version of the pipeline code and software are used when you run your pipeline. If you keep using the same tag, you'll be running the same version of the pipeline, even if there have been changes to the code since.

First, go to the [juliaapolonio/causeway releases page](https://github.com/juliaapolonio/causeway/releases) and find the latest pipeline version - numeric only (eg. `1.3.1`). Then specify this when running the pipeline with `-r` (one hyphen) - eg. `-r 1.3.1`. Of course, you can switch to another version by changing the number after the `-r` flag.

This version number will be logged in reports when you run the pipeline, so that you'll know what you used when you look back in the future. For example, at the bottom of the MultiQC reports.

To further assist in reproducbility, you can use share and re-use [parameter files](#running-the-pipeline) to repeat pipeline runs with the same settings without having to write out a command with every single parameter.

:::tip
If you wish to share such profile (such as upload as supplementary material for academic publications), make sure to NOT include cluster specific paths to files, nor institutional specific profiles.
:::

## Core Nextflow arguments

note: These options are part of Nextflow and use a _single_ hyphen (pipeline parameters use a double-hyphen).

### `-profile`

Use this parameter to choose a configuration profile. Profiles can give configuration presets for different compute environments.

Several generic profiles are bundled with the pipeline which instruct the pipeline to use software packaged using different methods (Docker, Singularity, Podman, Shifter, Charliecloud, Apptainer, Conda) - see below.

info: We highly recommend the use of Docker or Singularity containers for full pipeline reproducibility, however when this is not possible, Conda is also supported.

The pipeline also dynamically loads configurations from [https://github.com/nf-core/configs](https://github.com/nf-core/configs) when it runs, making multiple config profiles for various institutional clusters available at run time. For more information and to see if your system is available in these configs please see the [nf-core/configs documentation](https://github.com/nf-core/configs#documentation).

Note that multiple profiles can be loaded, for example: `-profile test,docker` - the order of arguments is important!
They are loaded in sequence, so later profiles can overwrite earlier profiles.

If `-profile` is not specified, the pipeline will run locally and expect all software to be installed and available on the `PATH`. This is _not_ recommended, since it can lead to different results on different machines dependent on the computer enviroment.

- `test`
  - A profile with a complete configuration for automated testing
  - Includes links to test data so needs no other parameters
- `docker`
  - A generic configuration profile to be used with [Docker](https://docker.com/)
- `singularity`
  - A generic configuration profile to be used with [Singularity](https://sylabs.io/docs/)
- `podman`
  - A generic configuration profile to be used with [Podman](https://podman.io/)
- `shifter`
  - A generic configuration profile to be used with [Shifter](https://nersc.gitlab.io/development/shifter/how-to-use/)
- `charliecloud`
  - A generic configuration profile to be used with [Charliecloud](https://hpc.github.io/charliecloud/)
- `apptainer`
  - A generic configuration profile to be used with [Apptainer](https://apptainer.org/)
- `wave`
  - A generic configuration profile to enable [Wave](https://seqera.io/wave/) containers. Use together with one of the above (requires Nextflow ` 24.03.0-edge` or later).

### `-resume`

Specify this when restarting a pipeline. Nextflow will use cached results from any pipeline steps where the inputs are the same, continuing from where it got to previously. For input to be considered the same, not only the names must be identical but the files' contents as well. For more info about this parameter, see [this blog post](https://www.nextflow.io/blog/2019/demystifying-nextflow-resume.html).

You can also supply a run name to resume a specific run: `-resume [run-name]`. Use the `nextflow log` command to show previous run names.

### `-c`

Specify the path to a specific config file (this is a core Nextflow command). See the [nf-core website documentation](https://nf-co.re/usage/configuration) for more information.

## Custom configuration

### Resource requests

Whilst the default requirements set within the pipeline will hopefully work for most people and with most input data, you may find that you want to customise the compute resources that the pipeline requests. Each step in the pipeline has a default set of requirements for number of CPUs, memory and time. For most of the steps in the pipeline, if the job exits with any of the error codes specified [here](https://github.com/nf-core/rnaseq/blob/4c27ef5610c87db00c3c5a3eed10b1d161abf575/conf/base.config#L18) it will automatically be resubmitted with higher requests (2 x original, then 3 x original). If it still fails after the third attempt then the pipeline execution is stopped.

To change the resource requests, please see the [max resources](https://nf-co.re/docs/usage/configuration#max-resources) and [tuning workflow resources](https://nf-co.re/docs/usage/configuration#tuning-workflow-resources) section of the nf-core website.

### Custom Containers

In some cases you may wish to change which container or conda environment a step of the pipeline uses for a particular tool. By default nf-core pipelines use containers and software from the [biocontainers](https://biocontainers.pro/) or [bioconda](https://bioconda.github.io/) projects. However in some cases the pipeline specified version maybe out of date.

To use a different container from the default container or conda environment specified in a pipeline, please see the [updating tool versions](https://nf-co.re/docs/usage/configuration#updating-tool-versions) section of the nf-core website.

### Custom Tool Arguments

A pipeline might not always support every possible argument or option of a particular tool used in pipeline. Fortunately, nf-core pipelines provide some freedom to users to insert additional parameters that the pipeline does not include by default.

To learn how to provide additional arguments to a particular tool of the pipeline, please see the [customising tool arguments](https://nf-co.re/docs/usage/configuration#customising-tool-arguments) section of the nf-core website.

### nf-core/configs

In most cases, you will only need to create a custom config as a one-off but if you and others within your organisation are likely to be running nf-core pipelines regularly and need to use the same settings regularly it may be a good idea to request that your custom config file is uploaded to the `nf-core/configs` git repository. Before you do this please can you test that the config file works with your pipeline of choice using the `-c` parameter. You can then create a pull request to the `nf-core/configs` repository with the addition of your config file, associated documentation file (see examples in [`nf-core/configs/docs`](https://github.com/nf-core/configs/tree/master/docs)), and amending [`nfcore_custom.config`](https://github.com/nf-core/configs/blob/master/nfcore_custom.config) to include your custom profile.

See the main [Nextflow documentation](https://www.nextflow.io/docs/latest/config.html) for more information about creating your own configuration files.

If you have any questions or issues please send us a message on [Slack](https://nf-co.re/join/slack) on the [`#configs` channel](https://nfcore.slack.com/channels/configs).

## Running in the background

Nextflow handles job submissions and supervises the running jobs. The Nextflow process must run until the pipeline is finished.

The Nextflow `-bg` flag launches Nextflow in the background, detached from your terminal so that the workflow does not stop if you log out of your session. The logs are saved to a file.

Alternatively, you can use `screen` / `tmux` or similar tool to create a detached session which you can log back into at a later time.
Some HPC setups also allow you to run nextflow within a cluster job submitted your job scheduler (from where it submits more jobs).

## Nextflow memory requirements

In some cases, the Nextflow Java virtual machines can start to request a large amount of memory.
We recommend adding the following line to your environment to limit this (typically in `~/.bashrc` or `~./bash_profile`):

```bash
NXF_OPTS='-Xms1g -Xmx4g'
```
