#!/usr/bin/bash 

#SBATCH --ntasks=1 --cpus-per-task=4
#SBATCH --time=10:50:00
#SBATCH --job-name=specied_ID
#SBATCH -A ap_itg_mpu
#SBATCH --job-name=somy_deeptools


module load SAMtools


## parameter settings
# encaps=encaps1 # if not read via sbatch export
src_dir=/user/antwerpen/205/vsc20587/scratch/leishmania_scDNA_mix/results/bwa/
bwa_dir=${src_dir}/${encaps}_split_bams/

## loop over the bam files and run idxstats
for bam in ${bwa_dir}*.bam; do
    echo "Processing ${bam}"
    samtools idxstats ${bam} > ${bam%.bam}_idxstats.txt
done

## run the command for all encapsulations
# for encaps in encaps1 encaps2 encaps3 encaps4; do
#     sbatch --export=encaps=${encaps} /user/antwerpen/205/vsc20587/scratch/leishmania_scDNA_mix/bin/demux2_species_identification.slurm
# done