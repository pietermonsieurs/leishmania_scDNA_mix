#!/bin/bash -l

#SBATCH --ntasks=1 --cpus-per-task=4
#SBATCH --mem=120G
#SBATCH --time=70:50:00
#SBATCH --job-name=splitBC
#SBATCH -A ap_itg_mpu

module purge
module load calcua/2024a
module load Pysam

## hard coded encapsulation file. Should be read in via the --export flag
# encaps=encaps1
bwa_dir="/user/antwerpen/205/vsc20587/scratch/leishmania_scDNA_mix/results/bwa/"
bam_file=${bwa_dir}/${encaps}.cb.bam

## defined the output directory for the split bam files, which is the RAM of the compute node
out_dir=/dev/shm/$USER/${encaps}_split_bams/

## run python script to split the bam file by cell barcode and output to the RAM of the compute node
/user/antwerpen/205/vsc20587/scratch/leishmania_scDNA_mix/bin/demux2_barcodes_BWA_bam_per_CB.py -bamfile ${bam_file} -outdir ${out_dir} 

## copy the directory with the split bam files from the RAM of the compute node to the scratch directory
cp -r ${out_dir} ${bwa_dir}/${encaps}_split_bams/


## loop over encapsulation files and submit a job for each one
# for encaps in encaps1 encaps2 encaps3 encaps4; do
# for encaps in encaps4; do
#     sbatch --export=encaps=${encaps} /user/antwerpen/205/vsc20587/scratch/leishmania_scDNA_mix/bin/demux2_barcodes_BWA_bam_per_CB.slurm
# done
# for encaps in encaps2 encaps3; do
