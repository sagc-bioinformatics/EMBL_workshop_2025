#!/bin/bash --login

#SBATCH --job-name=spacerangertut
#SBATCH --output=%x.%j.log
#SBATCH --mail-user=sarah.shah@sahmri.com
#SBATCH --mail-type=FAIL
#SBATCH --account=pawsey1247
#SBATCH --partition=work

#SBATCH --time=12:00:00
#SBATCH --mem=60G
#SBATCH --cpus-per-task=12

# Set all the variables
quote=tutorial
sample=Visium_HD_Mouse_Embryo
area=D1
slideid=H1-CQWQN2G
id="${quote}_${sample}_${area}_${slideid}"
micimage="/scratch/pawsey1247/sshah/spaceranger_wd/tutorial/mouseinputs/Visium_HD_Mouse_Embryo_tissue_image.btf"
cytaimage="/scratch/pawsey1247/sshah/spaceranger_wd/tutorial/mouseinputs/Visium_HD_Mouse_Embryo_image.tif"
fastqdir="/scratch/pawsey1247/sshah/spaceranger_wd/tutorial/mouseinputs/Visium_HD_Mouse_Embryo_fastqs"
transcriptome="/software/projects/pawsey1247/sshah/manual/spaceranger-ref/refdata-gex-GRCm39-2024-A"
probes="/scratch/pawsey1247/sshah/spaceranger_wd/tutorial/mouseinputs/Visium_HD_Mouse_Embryo_probe_set.csv"
outDir="/scratch/pawsey1247/sshah/spaceranger_wd/${quote}/spaceranger_${id}_outDir"

export PATH=/software/projects/pawsey1247/sshah/manual/spaceranger-4.0.1/bin:$PATH

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

