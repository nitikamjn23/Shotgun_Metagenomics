#!/usr/bin/bash
source /lustrehome/nitika/miniconda3/bin/activate

set -euo pipefail

# ---- EDIT THESE ----
INPUT_DIR="/lustrehome/nitika/bash_script/fastp_subsampling_trimmed_results"
OUTPUT_DIR="/lustrehome/nitika/bash_script"
SAMPLE_PREFIX="SRR25132914"
SAMPLE=0.1
THREADS=64
KMER_LIST="21,29,39,59,79,99,119"
# ---------------------

mkdir -p "${OUTPUT_DIR}"

R1="${INPUT_DIR}/${SAMPLE_PREFIX}_sub_${SAMPLE}_R1_trimmed.fastq.gz"
R2="${INPUT_DIR}/${SAMPLE_PREFIX}_sub_${SAMPLE}_R2_trimmed.fastq.gz"
OUT="${OUTPUT_DIR}/spades_output_${SAMPLE}"

    echo ">>> Running sample ${SAMPLE}"

    ~/miniconda3/envs/pipeline/bin/spades.py --meta \
        -1 "${R1}" \
        -2 "${R2}" \
        -k "${KMER_LIST}" \
        -t "${THREADS}" \
        -o "${OUT}"
done
