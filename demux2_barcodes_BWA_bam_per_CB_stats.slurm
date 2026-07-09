#!/bin/bash -l

#SBATCH --ntasks=1 --cpus-per-task=1
#SBATCH --time=0:50:00
#SBATCH --job-name=splitBC
#SBATCH -A ap_itg_mpu


module load SAMtools

# bam_file=/user/antwerpen/205/vsc20587/scratch/leishmania_scDNA_mix/results/bwa/encaps1_split_bams/CAACTTGC_AACGATGG_TCCAGTCT_GTAACCGA.bam
bam_file_sorted=${bam_file%.bam}.sorted.bam

samtools index ${bam_file}
samtools sort -o ${bam_file_sorted} ${bam_file}
samtools index ${bam_file_sorted}
samtools idxstats ${bam_file_sorted} > ${bam_file_sorted%.bam}.idxstats.txt
samtools flagstat ${bam_file_sorted} > ${bam_file_sorted%.bam}.flagstat.txt

