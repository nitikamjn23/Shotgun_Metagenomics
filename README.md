**# this is myinternship pipline code
**

**Spades output analysis:
**
#to check the lists all the assemblies in spades output directory.

for f in spades_output_*/assembly_graph_with_scaffolds.gfa; do
    echo "$f"
done


**#to combine the spades .gfa files
**for d in spades_output_*; do
    f="$d/assembly_graph_with_scaffolds.gfa"
    if [ -f "$f" ]; then
        echo "### $d"
        cat "$f"
    fi
done > combined_spades.gfa
