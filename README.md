**Shotgun metagenomics pipeline for gut microbiome analysis
**

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
