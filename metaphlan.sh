#!/usr/bin/env bash
set -euo pipefail
########################
# ---- CONFIG ---------
########################
INPUT_DIR="/lustrehome/nitika/bash_script_SRR25132914/fastp_subsampling_trimmed_results"
OUTPUT_DIR="/lustrehome/nitika/bash_script_SRR25132914/metaphlan4_SRR25132914_results"
DATABASE_DIR="/lustrehome/nitika/miniconda3/envs/metaphlan4/lib/python3.10/site-packages/metaphlan/metaphlan_databases"
SAMPLE_PREFIX="SRR25132914"
TOTAL_CORES=32
N_PARALLEL_JOBS=4
NPROC_PER_JOB=$(( TOTAL_CORES / N_PARALLEL_JOBS ))
if [ "$NPROC_PER_JOB" -lt 1 ]; then
    NPROC_PER_JOB=1
fi
########################
# ---- SETUP ----------
########################
mkdir -p "$OUTPUT_DIR"
echo "=========================================="
echo "MetaPhlAn 4.2.5 profiling"
echo "=========================================="
echo "Input directory : $INPUT_DIR"
echo "Output directory: $OUTPUT_DIR"
echo "Database        : $DATABASE_DIR"
echo "Total cores     : $TOTAL_CORES"
echo "Parallel jobs   : $N_PARALLEL_JOBS"
echo "Threads/job     : $NPROC_PER_JOB"
echo
########################
# ---- CHECK ----------
########################
if ! command -v metaphlan >/dev/null 2>&1; then
    echo "ERROR: metaphlan not found."
    exit 1
fi
echo "MetaPhlAn version:"
metaphlan --version
echo
if [ ! -d "$DATABASE_DIR" ]; then
    echo "ERROR: MetaPhlAn database directory not found:"
    echo "$DATABASE_DIR"
    exit 1
fi
########################
# ---- FUNCTION -------
########################
run_one_pair() {
    local fastq1="$1"
    local fastq2="$2"
    local level="$3"
    local sample_name="${SAMPLE_PREFIX}_sub_${level}"
    local out_profile="${OUTPUT_DIR}/${sample_name}_profiled.txt"
    local mapout="${OUTPUT_DIR}/${sample_name}.mapout"
    local log_file="${OUTPUT_DIR}/${sample_name}.log"
    echo "[START] $sample_name"
    echo "R1: $fastq1"
    echo "R2: $fastq2"
    metaphlan "${fastq1},${fastq2}" \
        --input_type fastq \
        --db_dir "$DATABASE_DIR" \
        --mapout "$mapout" \
        --nproc "$NPROC_PER_JOB" \
        -o "$out_profile" \
        > "$log_file" 2>&1
    if [ -s "$out_profile" ]; then
        echo "[DONE] $sample_name"
        echo "       Profile: $out_profile"
   else
        echo "[ERROR] $sample_name produced no profile!"
        echo "Check:"
        echo "$log_file"
        return 1
    fi
}
export -f run_one_pair
export OUTPUT_DIR
export NPROC_PER_JOB
export SAMPLE_PREFIX
export DATABASE_DIR
########################
# ---- COLLECT PAIRS --
########################
mapfile -t R1_FILES < <(
    find "$INPUT_DIR" \
        -maxdepth 1 \
        -type f \
        -name "${SAMPLE_PREFIX}_sub_*_R1_trimmed.fastq.gz" \
        | sort -V
)
if [ ${#R1_FILES[@]} -eq 0 ]; then
    echo "ERROR: No R1 FASTQ files found."
    echo "Expected files similar to:"
    echo "${SAMPLE_PREFIX}_sub_0.1_R1_trimmed.fastq.gz"
    exit 1
fi
echo "Found ${#R1_FILES[@]} R1 files:"
printf '  %s\n' "${R1_FILES[@]}"
echo
########################
# ---- RUN ------------
########################
for fastq1 in "${R1_FILES[@]}"; do
    filename=$(basename "$fastq1")
    level=$(echo "$filename" | sed -E 's/.*_sub_([0-9.]+)_R1_trimmed\.fastq\.gz/\1/')
    fastq2="${fastq1/R1_trimmed/R2_trimmed}"
    if [ ! -f "$fastq2" ]; then
        echo "ERROR: Matching R2 file not found:"
        echo "$fastq2"
        exit 1
    fi
    echo "Submitting:"
 echo "  Level: $level"
    echo "  R1   : $fastq1"
    echo "  R2   : $fastq2"
    echo
    run_one_pair "$fastq1" "$fastq2" "$level" &
    while [ "$(jobs -rp | wc -l)" -ge "$N_PARALLEL_JOBS" ]; do
        wait -n
    done
done
wait
########################
# ---- FINAL CHECK ----
########################
echo
echo "=========================================="
echo "MetaPhlAn processing finished"
echo "=========================================="
PROFILE_COUNT=$(find "$OUTPUT_DIR" \
    -name "${SAMPLE_PREFIX}_sub_*_profiled.txt" \
    -type f \
    | wc -l)
echo "Profiles produced: $PROFILE_COUNT"
if [ "$PROFILE_COUNT" -eq 0 ]; then
    echo
    echo "ERROR: No MetaPhlAn profiles were produced."
    echo "Check the .log files in:"
    echo "$OUTPUT_DIR"
    exit 1
fi
echo
echo "Profiles:"
find "$OUTPUT_DIR" \
    -name "${SAMPLE_PREFIX}_sub_*_profiled.txt" \
    -type f \
    | sort -V
echo
echo "To merge profiles:"
echo "merge_metaphlan_tables.py ${OUTPUT_DIR}/*_profiled.txt > ${OUTPUT_DIR}/merged_abundance_table.txt"
