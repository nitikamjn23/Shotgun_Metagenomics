#!/usr/bin/bash
source /lustrehome/nitika/miniconda3/bin/activate

conda activate pipeline

mkdir -p fastp_results

fastp -i /lustrehome/nitika/bash_script/output_dir/SRR25132914.sra_1.fastq -I /lustrehome/nitika/bash_script/output_dir/SRR25132914.sra_2.fastq -o SRR25132914_trimmed_r1.fastq.gz -O SRR25132914_trimmed_r2.fastq.gz --detect_adapter_for_pe --length_required 45 -q 20 -h fastp_report.html -j fastp_report.json

conda deactivate pipeline
