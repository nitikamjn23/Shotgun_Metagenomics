**Shotgun metagenomics pipeline for gut microbiome analysis**
This pipeline evaluates how sequencing depth affects taxonomic profiling and metagenome-assembled genome (MAG) recovery in shotgun metagenomics. Using mock community shotgun sequencing reads generated in a prior benchmarking study, reads were subsampled at ten increasing depths (10% through 100%, in 10% increments) using seqkit, with one subsampled dataset generated per fraction. For each subsampled dataset, taxonomic classification and MAG assembly were performed to assess how output quality and accuracy scale with read depth.

**Workflow Overview**
<img width="4828" height="5945" alt="Christmas Shopping Decision-2026-08-18-145725" src="https://github.com/user-attachments/assets/5c23d9bf-d32f-409b-8125-2b80ef669ff0" />

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
