#!/usr/bin/env bash
# ============================================================================
# MAG Recovery Workflow — Binning + Quality Assessment
# Sample: SRR25132914
#
# USAGE:
#   ./binning_workflow.sh <subsample_fraction>
#   e.g.  ./binning_workflow.sh 0.1
#         ./binning_workflow.sh 0.5
#         ./binning_workflow.sh 1.0
#
# Tools & versions targeted (per protocol):
#   MetaBAT2   (metabat2_env)
#   MaxBin2    v2.2.x, min contig length = 1000   (assembly env)
#   CONCOCT    v1.x,   min contig length = 1000   (concoct_env)
#   DAS_Tool   (das_env)                          — bin consolidation
#   CheckM2    v1.1.0  (checkm2 env)                — quality assessment
#     High quality:   completeness >= 90% AND contamination <= 5%
#     Medium quality:  completeness >= 50% AND contamination <= 10%
#     Low quality:     everything else
#
# NOTE: your installed MaxBin2/CONCOCT builds may be newer than the exact
# versions cited in the protocol (2.2.4 / 1.0.0) — behavior for -min_contig
# 1000 is unchanged across these versions, but if exact version-matching
# matters for your methods section, note the installed versions in your
# writeup (captured automatically below in the report).
#
# Everything printed by this script (stdout + stderr) is also saved to:
#   ${ROOT_DIR}/binning_SRR25132914_1.0/logs/full_run.log
# ============================================================================
set -euo pipefail

# Capture the subsample-fraction argument FIRST, then clear positional
# params — otherwise 'source .../activate' below silently inherits $1
# and conda's activate script misreads it as an environment name.
SUBSAMPLE_FRAC="${1:?Usage: $0 <subsample_fraction e.g. 0.1, 0.2 ... 1.0>}"
set --

source /lustrehome/babluuniba2022/miniconda3/bin/activate

activate_env () {
    set +u
    conda activate "$1"
    set -u
    echo ">>> [ENV] Active environment: ${CONDA_DEFAULT_ENV}"
}

activate_env assembly

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------
ROOT_DIR="/lustre/home/babluuniba2022/nitika_project"
SAMPLE="SRR25132914"
THREADS=16
MIN_CONTIG_LEN=1000     # per protocol: MaxBin2 and CONCOCT min contig length

FASTA_TO_CONTIG2BIN="${ROOT_DIR}/DAS_Tool/src/Fasta_to_Contig2Bin.sh"

ASSEMBLY_DIR="${ROOT_DIR}/spades_output_${SAMPLE}/spades_output_${SUBSAMPLE_FRAC}"
CONTIGS="${ASSEMBLY_DIR}/contigs.fasta"

READS_DIR="${ROOT_DIR}/fastp_subsampling_trimmed_results"
READS_R1="${READS_DIR}/${SAMPLE}_sub_${SUBSAMPLE_FRAC}_R1_trimmed.fastq.gz"
READS_R2="${READS_DIR}/${SAMPLE}_sub_${SUBSAMPLE_FRAC}_R2_trimmed.fastq.gz"

OUTDIR="${ROOT_DIR}/binning_${SAMPLE}_${SUBSAMPLE_FRAC}"
mkdir -p "${OUTDIR}"/{mapping,metabat2,maxbin2,concoct,dastool,checkm,logs,reports}

# ---------------------------------------------------------------------------
# Full-run logging: tee everything (stdout + stderr) to a single log file,
# in addition to printing it to the terminal as before.
# ---------------------------------------------------------------------------
MASTER_LOG="${OUTDIR}/logs/full_run.log"
exec > >(tee -a "${MASTER_LOG}") 2>&1

echo "============================================================"
echo " MAG Workflow started: $(date)"
echo " Sample: ${SAMPLE} | Fraction: ${SUBSAMPLE_FRAC}"
echo " Log file: ${MASTER_LOG}"
echo "============================================================"

REPORT="${OUTDIR}/reports/pipeline_report.md"
{
    echo "# MAG Recovery Report — ${SAMPLE} (fraction ${SUBSAMPLE_FRAC})"
    echo ""
    echo "Run started: $(date)"
    echo ""
} > "${REPORT}"

# ---------------------------------------------------------------------------
# Step 1: Filter contigs < MIN_CONTIG_LEN bp
# ---------------------------------------------------------------------------
echo ">>> [Step 1] Filtering contigs < ${MIN_CONTIG_LEN} bp..."
FILTERED_CONTIGS="${OUTDIR}/contigs_filtered.fasta"
seqkit seq -m "${MIN_CONTIG_LEN}" "${CONTIGS}" > "${FILTERED_CONTIGS}"

{
    echo "## Step 1: Contig filtering (min length = ${MIN_CONTIG_LEN} bp)"
    echo '```'
    seqkit stats -a "${FILTERED_CONTIGS}"
    echo '```'
    echo ""
} >> "${REPORT}"

# ---------------------------------------------------------------------------
# Step 2: Map reads to assembly (for coverage/depth)
# ---------------------------------------------------------------------------
echo ">>> [Step 2] Indexing contigs and mapping reads with bwa-mem..."
bwa index "${FILTERED_CONTIGS}"

bwa mem -t "${THREADS}" "${FILTERED_CONTIGS}" "${READS_R1}" "${READS_R2}" \
    | samtools sort -@ "${THREADS}" -o "${OUTDIR}/mapping/${SAMPLE}.sorted.bam" -
samtools index "${OUTDIR}/mapping/${SAMPLE}.sorted.bam"

{
    echo "## Step 2: Read mapping (bwa-mem)"
    echo '```'
    samtools flagstat "${OUTDIR}/mapping/${SAMPLE}.sorted.bam"
    echo '```'
    echo ""
} >> "${REPORT}"

# ---------------------------------------------------------------------------
# Step 3: Generate depth file
# ---------------------------------------------------------------------------
activate_env metabat2_env
echo ">>> [Step 3] Generating depth file..."
jgi_summarize_bam_contig_depths \
    --outputDepth "${OUTDIR}/mapping/depth.txt" \
    "${OUTDIR}/mapping/${SAMPLE}.sorted.bam"

# ---------------------------------------------------------------------------
# Step 4: Run MetaBAT2
# ---------------------------------------------------------------------------
echo ">>> [Step 4] Running MetaBAT2..."
metabat2 \
    -i "${FILTERED_CONTIGS}" \
    -a "${OUTDIR}/mapping/depth.txt" \
    -o "${OUTDIR}/metabat2/bin" \
    -t "${THREADS}" \
    -m 1500

N_METABAT2=$(ls "${OUTDIR}/metabat2/"bin*.fa 2>/dev/null | wc -l)
{
    echo "## Step 4: MetaBAT2 binning"
    echo "- Bins produced: ${N_METABAT2}"
    echo "- Tool version: $(metabat2 --help 2>&1 | head -n1)"
    echo ""
} >> "${REPORT}"

# ---------------------------------------------------------------------------
# Step 5: Run MaxBin2 (min contig length 1000, per protocol)
# ---------------------------------------------------------------------------
activate_env assembly
echo ">>> [Step 5] Preparing abundance file and running MaxBin2..."
awk 'NR>1 {print $1"\t"$3}' "${OUTDIR}/mapping/depth.txt" > "${OUTDIR}/mapping/abundance.txt"

run_MaxBin.pl \
    -contig "${FILTERED_CONTIGS}" \
    -abund "${OUTDIR}/mapping/abundance.txt" \
    -out "${OUTDIR}/maxbin2/bin" \
    -min_contig_length "${MIN_CONTIG_LEN}" \
    -thread "${THREADS}"

N_MAXBIN2=$(ls "${OUTDIR}/maxbin2/"bin.*.fasta 2>/dev/null | wc -l)
{
    echo "## Step 5: MaxBin2 binning (min contig length = ${MIN_CONTIG_LEN})"
    echo "- Bins produced: ${N_MAXBIN2}"
    echo "- Tool version: $(run_MaxBin.pl -v 2>&1 | head -n1)"
    echo ""
} >> "${REPORT}"

# ---------------------------------------------------------------------------
# Step 6: Run CONCOCT (default internal cutoff is 1000 bp, matching protocol)
# ---------------------------------------------------------------------------
activate_env concoct_env
echo ">>> [Step 6] Running CONCOCT..."
cut_up_fasta.py "${FILTERED_CONTIGS}" -c 10000 -o 0 --merge_last \
    -b "${OUTDIR}/concoct/contigs_10K.bed" > "${OUTDIR}/concoct/contigs_10K.fasta"

concoct_coverage_table.py \
    "${OUTDIR}/concoct/contigs_10K.bed" \
    "${OUTDIR}/mapping/${SAMPLE}.sorted.bam" \
    > "${OUTDIR}/concoct/coverage_table.tsv"

concoct \
    --composition_file "${OUTDIR}/concoct/contigs_10K.fasta" \
    --coverage_file "${OUTDIR}/concoct/coverage_table.tsv" \
    -b "${OUTDIR}/concoct/" \
    -t "${THREADS}"

merge_cutup_clustering.py \
    "${OUTDIR}/concoct/clustering_gt1000.csv" \
    > "${OUTDIR}/concoct/clustering_merged.csv"

mkdir -p "${OUTDIR}/concoct/fasta_bins"
extract_fasta_bins.py \
    "${FILTERED_CONTIGS}" \
    "${OUTDIR}/concoct/clustering_merged.csv" \
    --output_path "${OUTDIR}/concoct/fasta_bins"

N_CONCOCT=$(ls "${OUTDIR}/concoct/fasta_bins/"*.fa 2>/dev/null | wc -l)
{
    echo "## Step 6: CONCOCT binning (min contig length = ${MIN_CONTIG_LEN}, tool default)"
    echo "- Bins produced: ${N_CONCOCT}"
    echo "- Tool version: $(concoct --version 2>&1 | head -n1)"
    echo ""
} >> "${REPORT}"

# ---------------------------------------------------------------------------
# Step 7: Consolidate bins with DAS_Tool
# ---------------------------------------------------------------------------
activate_env das_env
echo ">>> [Step 7] Converting bin sets to DAS_Tool format..."

if [ ! -f "${FASTA_TO_CONTIG2BIN}" ]; then
    echo "ERROR: ${FASTA_TO_CONTIG2BIN} not found."
    echo "Clone it first: git clone https://github.com/cmks/DAS_Tool.git ${ROOT_DIR}/DAS_Tool && chmod +x ${ROOT_DIR}/DAS_Tool/src/*.sh"
    exit 1
fi

"${FASTA_TO_CONTIG2BIN}" -e fa \
    -i "${OUTDIR}/metabat2" > "${OUTDIR}/dastool/metabat2.contig2bin.tsv"

"${FASTA_TO_CONTIG2BIN}" -e fasta \
    -i "${OUTDIR}/maxbin2" > "${OUTDIR}/dastool/maxbin2.contig2bin.tsv"

"${FASTA_TO_CONTIG2BIN}" -e fa \
    -i "${OUTDIR}/concoct/fasta_bins" > "${OUTDIR}/dastool/concoct.contig2bin.tsv"

echo ">>> [Step 7b] Running DAS_Tool..."
DAS_Tool \
    -i "${OUTDIR}/dastool/metabat2.contig2bin.tsv,${OUTDIR}/dastool/maxbin2.contig2bin.tsv,${OUTDIR}/dastool/concoct.contig2bin.tsv" \
    -l metabat2,maxbin2,concoct \
    -c "${FILTERED_CONTIGS}" \
    -o "${OUTDIR}/dastool/${SAMPLE}_DASTool" \
    --write_bins \
    -t "${THREADS}"

DASTOOL_BINS_DIR="${OUTDIR}/dastool/${SAMPLE}_DASTool_DASTool_bins"
N_DASTOOL=$(ls "${DASTOOL_BINS_DIR}/"*.fa 2>/dev/null | wc -l)

{
    echo "## Step 7: DAS_Tool consolidation"
    echo "- Final consolidated bins: ${N_DASTOOL}"
    echo "- Bin directory: ${DASTOOL_BINS_DIR}"
    echo "- Tool version: $(DAS_Tool --version 2>&1 | head -n1)"
    echo ""
} >> "${REPORT}"

# ---------------------------------------------------------------------------
# Step 8: Quality assessment with CheckM
# ---------------------------------------------------------------------------
activate_env checkm2
echo ">>> [Step 8] Running CheckM2 predict..."

CHECKM2_DB="/lustrehome/babluuniba2022/database/CheckM2_database/uniref100.KO.1.dmnd"
CHECKM_OUT="${OUTDIR}/checkm/checkm2_out"

checkm2 predict \
    --threads "${THREADS}" \
    --input "${DASTOOL_BINS_DIR}" \
    --output-directory "${CHECKM_OUT}" \
    --database_path "${CHECKM2_DB}" \
    -x fa

CHECKM_TSV="${CHECKM_OUT}/quality_report.tsv"

echo ">>> [Step 8b] Classifying bins by MIMAG-style quality thresholds..."
QUALITY_TSV="${OUTDIR}/reports/mag_quality_summary.tsv"

python3 - "${CHECKM_TSV}" "${QUALITY_TSV}" <<'PYEOF'
import csv, sys

in_path, out_path = sys.argv[1], sys.argv[2]

with open(in_path) as f:
    reader = csv.DictReader(f, delimiter='\t')
    rows = list(reader)

def find_col(fieldnames, needle):
    for fn in fieldnames:
        if needle.lower() in fn.lower():
            return fn
    raise KeyError(f"Column containing '{needle}' not found in {fieldnames}")

comp_col = find_col(rows[0].keys(), "Completeness")
cont_col = find_col(rows[0].keys(), "Contamination")
# CheckM2's quality_report.tsv uses "Name" for the bin id (CheckM v1 used "Bin Id")
try:
    binid_col = find_col(rows[0].keys(), "Bin Id")
except KeyError:
    binid_col = find_col(rows[0].keys(), "Name")

with open(out_path, "w", newline="") as out:
    writer = csv.writer(out, delimiter='\t')
    writer.writerow(["Bin", "Completeness(%)", "Contamination(%)", "Quality"])
    counts = {"High": 0, "Medium": 0, "Low": 0}
    for r in rows:
        comp = float(r[comp_col])
        cont = float(r[cont_col])
        if comp >= 90 and cont <= 5:
            quality = "High"
        elif comp >= 50 and cont <= 10:
            quality = "Medium"
        else:
            quality = "Low"
        counts[quality] += 1
        writer.writerow([r[binid_col], f"{comp:.2f}", f"{cont:.2f}", quality])
    writer.writerow([])
    writer.writerow(["TOTAL", "", "", f"High={counts['High']} Medium={counts['Medium']} Low={counts['Low']}"])

print(f"Wrote quality summary: {out_path}")
for line in open(out_path):
    print("  " + line.rstrip())
PYEOF

{
    echo "## Step 8: CheckM2 quality assessment"
    echo ""
    echo "Thresholds used:"
    echo "- High quality: completeness >= 90% AND contamination <= 5%"
    echo "- Medium quality: completeness >= 50% AND contamination <= 10%"
    echo "- Low quality: everything else"
    echo ""
    echo "Full CheckM2 table: ${CHECKM_TSV}"
    echo "Quality summary: ${QUALITY_TSV}"
    echo ""
    echo '```'
    cat "${QUALITY_TSV}"
    echo '```'
    echo ""
} >> "${REPORT}"

# ---------------------------------------------------------------------------
# Done
# ---------------------------------------------------------------------------
{
    echo "---"
    echo "Run finished: $(date)"
} >> "${REPORT}"

echo "============================================================"
echo " DONE."
echo " Final consolidated bins : ${DASTOOL_BINS_DIR}"
echo " CheckM full table       : ${CHECKM_TSV}"
echo " Quality summary         : ${QUALITY_TSV}"
echo " Pipeline report (MD)    : ${REPORT}"
echo " Full run log            : ${MASTER_LOG}"
echo "============================================================"
