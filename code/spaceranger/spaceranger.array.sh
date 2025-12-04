#!/bin/bash --login

#SBATCH --job-name=spacerangerarray
#SBATCH --output=%x.%j-%a.log
#SBATCH --mail-user=sarah.shah@sahmri.com
#SBATCH --mail-type=FAIL
#SBATCH --account=pawsey1247
#SBATCH --partition=work

#SBATCH --time=24:00:00
#SBATCH --mem=60G
#SBATCH --cpus-per-task=24
#SBATCH --array=1-4

LOGFILE=${SLURM_JOB_NAME}.${SLURM_JOB_ID}.resources.log

# Extract slide list from file list for array
filelist=slidelist.txt
quote=$(awk -v ArrayTaskID=$SLURM_ARRAY_TASK_ID '$1==ArrayTaskID {print $2}' $filelist)
sample=$(awk -v ArrayTaskID=$SLURM_ARRAY_TASK_ID '$1==ArrayTaskID {print $3}' $filelist)
area=$(awk -v ArrayTaskID=$SLURM_ARRAY_TASK_ID '$1==ArrayTaskID {print $4}' $filelist)
micid=$(awk -v ArrayTaskID=$SLURM_ARRAY_TASK_ID '$1==ArrayTaskID {print $5}' $filelist)
slideid=$(awk -v ArrayTaskID=$SLURM_ARRAY_TASK_ID '$1==ArrayTaskID {print $6}' $filelist)

export PATH=/software/projects/pawsey1247/sshah/manual/spaceranger-4.0.1/bin:$PATH

id="${quote}_${sample}_${area}_${micid}"
micimage="/scratch/pawsey1247/sshah/spaceranger_wd/${quote}/Microscopy_lossless/${slideid}_${area}_${sample}_${micid}.ome.tif"
cytaimage=$(ls /scratch/pawsey1247/sshah/spaceranger_wd/${quote}/CytAssist/*${slideid}_${area}_${sample}.tif)
fastqdir="/scratch/pawsey1247/sshah/spaceranger_wd/${quote}/fastqdir"
transcriptome="/software/projects/pawsey1247/sshah/manual/spaceranger-ref/refdata-gex-GRCh38-2020-A"
probes="/software/projects/pawsey1247/sshah/manual/spaceranger-ref/Visium_Human_Transcriptome_Probe_Set_v2.0_GRCh38-2020-A.csv"
outDir="/scratch/pawsey1247/sshah/spaceranger_wd/${quote}/spaceranger_${id}_outDir"

spaceranger count \
	--fastqs $fastqdir \
	--transcriptome $transcriptome \
	--id $id \
	--sample $sample \
	--image $micimage \
	--cytaimage $cytaimage \
	--slide $slideid \
	--area $area \
	--probe-set $probes \
	--jobmode local \
	--create-bam false \
	--output-dir $outDir \
	--localcores ${SLURM_CPUS_PER_TASK} \
	--localvmem ${SLURM_MEM_PER_NODE}

