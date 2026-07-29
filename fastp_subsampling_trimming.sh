#!/usr/bin/bash
source /lustrehome/nitika/miniconda3/bin/activate


conda activate pipeline


mkdir -p fastp_subsampling_trimmed_results


fastp  -i /lustrehome/nitika/bash_script/fastq_file/subsampled_reads/SRR25132914_R1*.fastq -I /lustrehome/nitika/bash_script/fastq_file/subsampled_reads/SRR25132914_R2*.fastq -o SRR25132914_R1_trimmed*.fastq.gz -O SRR25132914_R2_trimmed*.fastq.gz --detect_adapter_for_pe --length_required 45 -q 20 -t 16 -h SRR25132914_fastp_report.html -j SRR25132914_fastp_report.json

conda deactivate pipeline
