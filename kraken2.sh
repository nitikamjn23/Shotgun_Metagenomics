https://github.com/jenniferlu717/KrakenTools#kreport2mpapy
Download Database - https://ftp.ebi.ac.uk/pub/databases/metagenomics/mgnify_genomes/human-gut/v2.0.2/kraken2_db_uhgg_v2.0.2/

#kraken2.sh

#!/usr/bin/bash
source /lustrehome/nitika/miniconda3/etc/profile.d/conda.sh
conda activate pipeline

INPUTDIR="/lustrehome/nitika/bash_script_SRR25132914/fastp_subsampling_trimmed_results"
DB="/lustrehome/nitika/bash_script_SRR25132914/kraken2_uhgg_db_v2.0.2"

OUTDIR="kraken2_results"
THREADS=16

mkdir -p "$OUTDIR"

for sample in 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0
do


    kraken2 \
        --db "$DB" \
        --paired \
        --gzip-compressed \
        --report "$OUTDIR/SRR25132914_sub_${sample}_report.txt" \
        --output "$OUTDIR/SRR25132914_sub_${sample}_output.txt" \
        "$INPUTDIR/SRR25132914_sub_${sample}_R1_trimmed.fastq.gz" \
        "$INPUTDIR/SRR25132914_sub_${sample}_R2_trimmed.fastq.gz"
    echo "Finished sample ${sample}"
    echo

done

