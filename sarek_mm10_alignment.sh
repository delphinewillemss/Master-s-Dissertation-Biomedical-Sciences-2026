#!/bin/bash -l
#SBATCH --job-name=sarek_mm10_alignment
#SBATCH --nodes=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
#SBATCH --time=48:00:00
#SBATCH --mail-type=all
#SBATCH --output=/scratch/gent/vo/002/gvo00207/vsc52059/Nextflow_pipeline/logs/%x_%j.log
# indienen met: sbatch sarek_mm10_alignment.sh
## Nextflow pipeline om automatisch aligment uit te voeren op files

cd $SLURM_SUBMIT_DIR

module load Nextflow/26.04.3

FASTQ_DIR=/data/gent/vo/002/gvo00207/shared/ResolveDNA_20260319_2
OUTDIR=/scratch/gent/vo/002/gvo00207/vsc52059/Nextflow_pipeline
SAMPLESHEET=$OUTDIR/samplesheet.csv
PARAMS=$OUTDIR/params.yaml

# ---- Samplesheet aanmaken ----
echo "patient,sample,lane,fastq_1,fastq_2" > $SAMPLESHEET
for R1 in $FASTQ_DIR/*_R1_001.fastq.gz; do
    R2=${R1/_R1_001.fastq.gz/_R2_001.fastq.gz}
    SAMPLE=$(basename $R1 _R1_001.fastq.gz)
    echo "${SAMPLE},${SAMPLE},1,${R1},${R2}" >> $SAMPLESHEET
done

# ---- Controle: stop als iets ontbreekt ----
[ -s "$PARAMS" ] || { echo "params.yaml ontbreekt: $PARAMS"; exit 1; }
[ "$(wc -l < $SAMPLESHEET)" -eq 13 ] || { echo "Samplesheet heeft niet 13 regels"; exit 1; }

# ---- Pipeline ----
nextflow run nf-core/sarek \
-r 3.10.0 \
-params-file $PARAMS \
-work-dir $OUTDIR/work \
-profile vsc_ugent \
-resume 