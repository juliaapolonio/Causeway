# Frequently Asked Questions

## General Questions

#### What is the purpose of this pipeline?

Causeway was built to perform Mendelian Randomization and sensitivity analysis for a large number of exposure-outcome phenotype combinations.

#### Who is the intended audience for this pipeline?

The intended audience of this pipeline are bioinformaticians and Epidemiologists/Geneticists familiarized with command-line tools.

#### What input data formats does the pipeline accept?

It accepts only summary statistics in GCTA-Cojo format. For more info about inputs, check [the usage input section](https://juliaapolonio.github.io/Causeway/usage/#inputs).

#### What are the key outputs of the pipeline?

The key output is a report with the main analysis findings. You can check more about this and the other outputs at [the outputs section](https://juliaapolonio.github.io/Causeway/output/#introduction).

## Installation and Setup

#### What are the minimum system requirements to run the pipeline?

You will need a  system with a minimum of 4 cores, 8GB RAM, 20GB of storage and Linux, MacOS or Windows Subsystem for Linux (WSL) with Nextflow and a container manager installed. More information this can be found at [the system requirements section](https://juliaapolonio.github.io/Causeway/usage/#system-requirements).

#### Do I need to install any specific software or dependencies before running the pipeline?

Apart from Nextflow and a container manager, you won't need to install any dependencies.

#### How do I install and configure the pipeline on my system?

You can download, install and set the pipeline with a single command: 

```bash
nextflow pull juliaapolonio/Causeway
```

## Usage

#### How do I execute the pipeline with example input data?

To execute the pipeline with minimal test data, you will need this command:

```bash
nextflow run juliaapolonio/Causeway -profile test,YOURPROFILE --outdir <OUTDIR>
```
Where YOURPROFILE will be the container executor you have in your machine.

#### What command-line options are available for customizing the pipeline?

A list of optional flags can be found in [the optional flags section](https://juliaapolonio.github.io/Causeway/usage/#optional-flags).

#### How do I specify a custom configuration file?

You can add your own configuration file as a profile in the [conf](https://github.com/juliaapolonio/Causeway/tree/master/conf) directory. Alternatively, you can check if there is an existing configuration profile for your institution at [nf-core/configs documentation](https://github.com/nf-core/configs#documentation).

#### Can the pipeline be run on a cluster or cloud environment?

Yes, Nextflow can handle lots of cluster and cloud computing environments, such as Slurm, Google Cloud, AWS. More information about it can be found at [Nextflow executor documentation](https://www.nextflow.io/docs/latest/executor.html).

#### What should I do if my pipeline run is interrupted?

You can run it again with the same parameters and adding the -resume option, which will search for the execution cache.

## Troubleshooting

#### What should I check if the pipeline fails with an error?



#### Where can I find detailed logs of the pipeline execution?

For logs of the whole pipeline execution, you can check the `pipeline_info` folder on the output directory. If you want a log of specific task, you can check its hash in the work directory.
See [Nextflow documentation on execution reports](https://www.nextflow.io/docs/latest/reports.html#execution-log) for more details.

#### Why is the pipeline taking longer than expected to execute?

This pipeline should take a while to finish if using large data (e.g. the application analysis took 58 hours using 50GB of RAM in a cluster). If it is abnormally longing to finish, you can check the input data of the tasks that are running.

#### What does it mean if some outputs are missing from the results directory?

It probably means that a silent error happened. You can check the log files from the task to see if anything went wrong with the execution.

#### How can I debug issues with specific modules (e.g., rendering reports, statistical analyses)?

For each task, Nextflow has a hash that can be found in the work directory. Inside the task folder, you can check the `.command.log` or `.command.err` to see if there's anything unusual.

## Results and Outputs

#### What do the output files in each directory mean and how do I interpret the metrics and visualizations produced by the pipeline?

A comprehensive description of the outputs and its interpretations can be found at the [outputs section](https://juliaapolonio.github.io/Causeway/output/).

#### What should I do if I suspect a bug in the output files?

This tool is still under testing and bugs can happen. If you feel that something went wrong with the analysis, please leave an [issue](https://github.com/juliaapolonio/Causeway/issues) with a reproductible example.

#### Can I customize the report generated by the pipeline?

You can edit the report by directly editing the report module script.


## Customization
#### Can I add new analysis modules to the pipeline?

Yes! Since the pipeline is all built based on modules, you can add your own analysis and integrate with the pipeline at [main.nf](https://github.com/juliaapolonio/Causeway/blob/master/main.nf), or use this pipeline as a subworkflow.

#### How do I use my own scripts or tools within the pipeline?

You will have to build a module and integrate it to the main workflow.

#### Is it possible to change the default parameter values?

Not yet. Only by editing the source code for now.

#### How can I incorporate additional datasets into the analysis?

You can use any exposure/outcome/reference you want, it just need to follow the [usage input guidelines](https://juliaapolonio.github.io/Causeway/usage/#inputs).

## Performance and Optimization

#### What steps can I take to optimize pipeline performance?

Nextflow already does that to you! But if you feel that you need something more custom, you can change [nextflow.config](https://github.com/juliaapolonio/Causeway/blob/master/nextflow.config) or [conf/modules.config](https://github.com/juliaapolonio/Causeway/blob/master/conf/modules.config) files.

#### Can I run specific modules independently?

Yes, you can use Causeway modules to build your own workflow.


## Support and Contributions

#### Where can I report bugs or request new features?

You can do these requests by raising an [issue](https://github.com/juliaapolonio/Causeway/issues).

#### Is there a user community or forum for pipeline-related discussions?

For Nextflow users, there's the [nf-core community](https://nf-co.re/)! For this specific pipeline, there's no discussion forum.

#### How can I contribute to the development of the pipeline?

If you want to make an improvement in the code, you can open a Pull Request at the [Causeway's repository](https://github.com/juliaapolonio/Causeway). If you want to be a continuous collaborator, please reach one of the authors.

#### Is there a citation for this pipeline?

The paper is in reviewing process but you can cite our BioarXiv preprint: 

#### Can I use the pipeline for commercial purposes?

Yes, Causeway's license allows the use for commercial purposes.
