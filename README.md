**Shotgun metagenomics pipeline for gut microbiome analysis**
This pipeline evaluates how sequencing depth affects taxonomic profiling and metagenome-assembled genome (MAG) recovery in shotgun metagenomics. Using mock community shotgun sequencing reads generated in a prior benchmarking study, reads were subsampled at ten increasing depths (10% through 100%, in 10% increments) using seqkit, with one subsampled dataset generated per fraction. For each subsampled dataset, taxonomic classification and MAG assembly were performed to assess how output quality and accuracy scale with read depth.

**Workflow Overview**
<img width="4828" height="5945" alt="Christmas Shopping Decision-2026-08-18-145725" src="https://github.com/user-attachments/assets/5c23d9bf-d32f-409b-8125-2b80ef669ff0" />

**Subsampling Strategy**
To evaluate the effect of sequencing depth on taxonomic classification and MAG recovery, raw reads were subsampled at ten increasing fractions of the original dataset: **10%, 20%, 30%, 40%, 50%, 60%, 70%, 80%, 90%, and 100%**.

**Tool used:** [`seqkit sample`](https://bioinf.shenwei.me/seqkit/usage/#sample)
**Purpose:** Simulate varying sequencing effort and assess how downstream results (assembly quality, MAG recovery, taxonomic accuracy) scale with read depth
the shell script I used- https://github.com/nitikamjn23/Shotgun_Metagenomics/blob/main/subsampling.sh 

## Tools & Dependencies

## Tools & Dependencies

| Tool (Version) | Files | Purpose | Reference |
|-----------------|-------|---------|-----------|
| Miniconda |  | Environment and package management | [Miniconda Docs](https://docs.conda.io/en/latest/miniconda.html) |
| FastQC (v0.12.1) | `fastqc.sh` | Raw read quality control | [FastQC](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/) |
| MultiQC (⏳ ) |  | Aggregated QC report across samples | [MultiQC](https://multiqc.info/) |
| seqkit (v2.13.0) | `subsampling.sh` | Read subsampling (depth simulation) | [seqkit](https://bioinf.shenwei.me/seqkit/) |
| fastp (0.23.4) | `fastp.sh`, 'fastp_subsampling_trimming.sh', '/fastp_trimming_one_sample.sh' | Adapter/quality trimming of subsampled reads | [fastp](https://github.com/OpenGene/fastp) |
| Bowtie2 (2.5.5) | `bowtie2` | Host read removal (alignment to host genome) | [Bowtie2](https://bowtie-bio.sourceforge.net/bowtie2/index.shtml) |
| SPAdes/metaSPAdes (v4.2.0) | SPAdes.sh | Metagenomic assembly | [SPAdes](https://github.com/ablab/spades) |
| QUAST/metaQUAST (v5.3.0 ) | `quast.sh` | Assembly quality evaluation | [QUAST](https://quast.sourceforge.net/) |
| MetaWRAP (⏳ ) |  | Contig binning and bin refinement | [MetaWRAP](https://github.com/bxlab/metaWRAP) |
| CheckM (⏳ ) |  | MAG completeness/contamination assessment | [CheckM](https://github.com/Ecogenomics/CheckM) |
| Kraken2 (2.1.2) | `kraken2.sh`, 'kraken2_jupyter_visualisation.py' | Taxonomic classification (read-based) | [Kraken2](https://github.com/DerekyRK/Kraken2) |
| MetaPhlAn4 (⏳ ) | `MetaPhlAn.sh`, MetaPhlAn.py | Taxonomic profiling (marker-gene based) | [MetaPhlAn4](https://github.com/biobakery/MetaPhlAn) |



**Spades output analysis:
**
#to check the lists all the assemblies in spades output directory.

for f in spades_output_*/assembly_graph_with_scaffolds.gfa; do
    echo "$f"
done


#to combine the spades .gfa files
for d in spades_output_; do
    f="$d/assembly_graph_with_scaffolds.gfa"
    if [ -f "$f" ]; then
        echo "### $d"
        cat "$f"
    fi
done > combined_spades.gfa

then
ls -lh combined_spades.gfa




Kraken2
#to run single sample:
**./kraken2.sh** SRR25132914_sub_0.8



#quast (statistical package)
QUAST (QUality ASsessment Tool) is a software toolkit used to assess the quality of genome and metagenome assemblies based on various assembly metrics. It includes QUAST for standard genome assemblies, MetaQUAST for metagenomic datasets, QUAST-LG for large genomes such as mammalian genomes, and Icarus, an interactive visualization tool for exploring the results.
