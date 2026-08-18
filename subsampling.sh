#!/bin/bash
source /lustrehome/nitika/miniconda3/bin/activate
conda activate pipeline

INDIR="/lustrehome/nitika/bash_script/fastq_file"
R1="${INDIR}/SRR25132914.sra_1.fastq"
R2="${INDIR}/SRR25132914.sra_2.fastq"
OUTDIR="${INDIR}/subsampled_reads"
SEED=100
THREADS=16.   # Number of threads for seqkit stats
SUMMARY="${OUTDIR}/read_counts_summary.tsv"


mkdir -p "$OUTDIR"

if [[ ! -f "$R1" || ! -f "$R2" ]]; then
    echo "Error: R1 or R2 file not found. Check paths:"
    echo "  R1: $R1"
    echo "  R2: $R2"
    exit 1
fi

echo "Starting subsampling from 0.1 to 0.9..."
echo "----------------------------------------"

for frac in 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9
do
    echo "Subsampling at fraction: $frac"

    R1_OUT="${OUTDIR}/SRR25132914_R1_sub_${frac}.fastq.gz"
    R2_OUT="${OUTDIR}/SRR25132914_R2_sub_${frac}.fastq.gz"

    seqtk sample -s${SEED} "$R1" "$frac" | gzip > "$R1_OUT"
    seqtk sample -s${SEED} "$R2" "$frac" | gzip > "$R2_OUT"

    echo "  Done -> $R1_OUT and $R2_OUT"
done

echo "----------------------------------------"
echo "All subsampling done. Now running seqkit stats for summary..."
echo "----------------------------------------"

# ==== BUILD TSV SUMMARY USING seqkit stats ====
# -a  : all statistics (extended stats incl. N50, Q20%, Q30%, AvgQual, GC%, etc.)
# -T  : tabular (TSV) output
# -j  : number of threads

ALL_FILES=$(ls ${OUTDIR}/SRR25132914_R*_sub_*.fastq.gz)

seqkit stats -a -T -j ${THREADS} ${ALL_FILES} > "$SUMMARY"

echo "----------------------------------------"
echo "All done! Files saved in: $OUTDIR/"
echo "Read stats summary saved at: $SUMMARY"
