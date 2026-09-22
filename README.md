**Shotgun metagenomics pipeline for gut microbiome analysis**
This pipeline evaluates how sequencing depth affects taxonomic profiling and metagenome-assembled genome (MAG) recovery in shotgun metagenomics. Using mock community shotgun sequencing reads generated in a prior benchmarking study, reads were subsampled at ten increasing depths (10% through 100%, in 10% increments) using seqkit, with one subsampled dataset generated per fraction. For each subsampled dataset, taxonomic classification and MAG assembly were performed to assess how output quality and accuracy scale with read depth.

**Workflow Overview**

<img width="1964" height="2513" alt="Incomplete_pipeline_workflow (3)_page-0001" src="https://github.com/user-attachments/assets/053e5f90-1f88-4a6c-9297-fb0d4a230a2d" />
Figure Overview of metagenomic pipeline used in this study. The workflow begins with downloading the raw sequencing data, followed by read-quality assessment with FastQC and MultiQC, and adapter and quality trimming with fastp. The analysis is then divided into two approaches: the yellow section represents the de novo assembly-based approach, including assembly, binning, MAG recovery, and quality assessment, and the red section represents the reference-based taxonomic classification approach, using Kraken2 and MetaPhlAn4 for direct taxonomic profiling of sequencing reads.


**Subsampling Strategy**
To evaluate the effect of sequencing depth on taxonomic classification and MAG recovery, raw reads were subsampled at ten increasing fractions of the original dataset: **10%, 20%, 30%, 40%, 50%, 60%, 70%, 80%, 90%, and 100%**.

**Tool used:** [`seqkit sample`](https://bioinf.shenwei.me/seqkit/usage/#sample)
**Purpose:** Simulate varying sequencing effort and assess how downstream results (assembly quality, MAG recovery, taxonomic accuracy) scale with read depth
the shell script I used- https://github.com/nitikamjn23/Shotgun_Metagenomics/blob/main/subsampling.sh 

## Tools & Dependencies

## Tools & Dependencies

Table 1 Bioinformatics tools used in metagenomic analysis, including their respective purposes and key parameters/databases.
## Software and Computational Tools

| Tool                         | Purpose                                                                                                                             | Key parameters / usage                                                                                  |
| ---------------------------- | ----------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------- |
| **MobaXterm**                | Remote access to the ReCaS-Bari computing environment and command-line execution                                                    | SSH / remote server access; `condor_submit -i submission_file`                                          |
| **Miniconda (v26.3.2)**      | Package, environment, and dependency management                                                                                     | Separate environments for bioinformatics tools                                                          |
| **SRA Toolkit (v3.4.1)**     | Download raw sequencing reads                                                                                                       | `prefetch`; default settings                                                                            |
| **Seqtk (v1.5-r133)**        | Generation of subsampled datasets                                                                                                   | `sample -s100`; fractions 0.1–0.9; seed = 100; paired R1/R2 processed separately                        |
| **Seqkit (v2.13.0)**         | Calculation of read statistics for subsampled datasets                                                                              | `seqkit stats`; N50, Q20%, Q30%, mean quality, and GC content                                           |
| **FastQC (v0.12.1)**         | Quality assessment of raw sequencing reads                                                                                          | Default parameters                                                                                      |
| **MultiQC (v1.25)**          | Aggregation and visualization of quality-control reports                                                                            | `multiqc .`; summarized FastQC results                                                                  |
| **Fastp (v0.23.4)**          | Read preprocessing, quality filtering, adapter trimming, and removal of low-quality reads                                           | `--detect_adapter_for_pe`, `-q 20`, `--length_required 45`, `-h`, `-j`; paired-end input                |
| **Kraken2 (v2.1.2)**         | Taxonomic classification of metagenomic reads using k-mer-based matching                                                            | `--db`, `--paired`, `--gzip-compressed`, `--report`, `--output`; 16 threads; UHGG v2.0.2                |
| **MetaPhlAn4 (v4.2.6)**      | Taxonomic profiling based on clade-specific marker genes                                                                            | `--input_type fastq`, `--db_dir`, `--mapout`, `--nproc 8`, `-o`; paired-end FASTQ                       |
| **SPAdes (v4.2.0)**          | De novo assembly of quality-filtered metagenomic reads                                                                              | `--meta`, `--only-assembler`, `-1`, `-2`, `-k 21,29,39,59,79,99,119`, `-t 64`, `-o`                     |
| **QUAST (v5.3.0)**           | Evaluation of genome assembly quality                                                                                               | Reference-free; `-o`, `-t 16`, `--labels`; 10 assemblies compared                                       |
| **BWA-MEM (v0.7.15, r1140)** | Alignment of sequencing reads to assembled contigs to generate coverage profiles for binning                                        | Default BWA-MEM settings; 16 threads                                                                    |
| **MetaBAT2 (v2.18)**         | Binning of contigs into groups representing potential microbial genomes using tetranucleotide composition and differential coverage | Minimum contig length: 1500 bp; 16 threads                                                              |
| **MaxBin2 (v2.2.7)**         | Binning of contigs based on coverage and marker genes using an expectation–maximization approach                                    | Minimum contig length: 1000 bp; 16 threads; marker genes used internally                                |
| **CONCOCT (v1.1.0)**         | Binning of contigs using composition and coverage, dimensionality reduction, and Gaussian mixture modelling                         | Contig fragments: 10 kb; minimum contig length: 1000 bp; 16 threads                                     |
| **DAS Tool (v1.1.7)**        | Consolidation of MetaBAT2, MaxBin2, and CONCOCT binning results and selection of non-redundant bins                                 | `-i` bin sets; `-l` labels; `-c` contigs; `--write_bins`; 16 threads (`-t 16`); marker-gene information |
| **CheckM2 (v1.1.0)**         | Estimation of MAG completeness and contamination using a machine-learning model                                                     | Default parameters; database: `uniref100.KO.1.dmnd`                                                     |
| **Python (v3.14.7)**         | Data processing, calculations, and visualization                                                                                    | Used for downstream analysis and plotting                                                               |

