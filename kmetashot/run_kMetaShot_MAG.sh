```bash
#!/bin/bash

# ============================================================
# kMetaShot MAG Classification
# ============================================================
# Classifies DASTool-refined MAGs using kMetaShot.
#
# Usage:
#   bash run_kMetaShot_MAG.sh binning_SRR25132914_0.1
#
# Required:
#   - kMetaShot installed in the "kmetashot" Conda environment
#   - kMetaShot bacterial/archaeal reference database
#   - MetaWRAP DASTool MAG directory
# ============================================================

set -euo pipefail

# -----------------------------
# Input sample
# -----------------------------

if [ "$#" -ne 1 ]; then
    echo "Usage: bash $0 <sample_directory>"
    echo "Example: bash $0 binning_SRR25132914_0.1"
    exit 1
fi

SAMPLE="$1"

# -----------------------------
# Paths
# -----------------------------

BASE="/lustrehome/nitika/metawrap_results"

REFERENCE="/lustrehome/nitika/kMetaShot_reference/kMetaShot_bacteria_archaea_2025-05-22.h5"

BIN_DIR="${BASE}/${SAMPLE}/dastool/SRR25132914_DASTool_DASTool_bins"

OUT_DIR="${BASE}/kMetaShot_MAG_results/${SAMPLE}"

# -----------------------------
# Activate Conda environment
# -----------------------------

source /lustrehome/nitika/miniconda3/etc/profile.d/conda.sh
conda activate kmetashot

echo "Conda environment: ${CONDA_DEFAULT_ENV}"

# -----------------------------
# Check input files
# -----------------------------

if [ ! -d "$BIN_DIR" ]; then
    echo "ERROR: MAG directory not found:"
    echo "$BIN_DIR"
    exit 1
fi

if [ ! -f "$REFERENCE" ]; then
    echo "ERROR: kMetaShot reference not found:"
    echo "$REFERENCE"
    exit 1
fi

# -----------------------------
# Create output directory
# -----------------------------

mkdir -p "$OUT_DIR"

# -----------------------------
# Print configuration
# -----------------------------

echo "=========================================="
echo "kMetaShot MAG Classification"
echo "=========================================="
echo "Sample:       $SAMPLE"
echo "MAG directory:"
echo "$BIN_DIR"
echo "Reference:"
echo "$REFERENCE"
echo "Output:"
echo "$OUT_DIR"
echo "Processes:    10"
echo "=========================================="

# -----------------------------
# Run kMetaShot
# -----------------------------

kMetaShot_classifier_NV.py \
    -b "$BIN_DIR" \
    -r "$REFERENCE" \
    -p 10 \
    -o "$OUT_DIR"

STATUS=$?

# -----------------------------
# Check status
# -----------------------------

if [ "$STATUS" -eq 0 ]; then
    echo "=========================================="
    echo "kMetaShot completed successfully"
    echo "Sample: $SAMPLE"
    echo "Results: $OUT_DIR"
    echo "=========================================="
else
    echo "=========================================="
    echo "ERROR: kMetaShot failed"
    echo "Sample: $SAMPLE"
    echo "=========================================="
fi

exit "$STATUS"
```
