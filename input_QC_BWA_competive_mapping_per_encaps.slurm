#!/usr/bin/bash

#SBATCH --ntasks=1 --cpus-per-task=28
#SBATCH --time=0:50:00
#SBATCH --job-name=count
#SBATCH -A ap_itg_mpu

module purge
module load calcua/2025a
module load BWA
module load SAMtools

## parameter settings
fastq_dir=/user/antwerpen/205/vsc20587/scratch/leishmania_scDNA_mix/results/demux/concat/
results_dir=${fastq_dir}/competive_mapping_encaps/
mkdir -p ${results_dir}

## create a combined reference genome
ref_genome=/user/antwerpen/205/vsc20587/scratch/leishmania_scDNA_mix/data/refgenomes/competitive_mapping/competitive_refgenome.fasta

## create the R2 fastq file name from the R1 fastq file name
# fastq_file=/user/antwerpen/205/vsc20587/scratch/leishmania_scDNA_mix/results/demux/concat/encaps1_R1.tagged.fq.gz
fastq_file_R2=${fastq_file/_R1.tagged.fq.gz/_R2.tagged.fq.gz}

## only select the first part of the prefix, before first _
prefix=$(basename ${fastq_file} _R1.tagged.fq.gz)
# prefix=${prefix%%_*}
echo $prefix

## only select the first 10 millions reads for testing from the fastq file
zcat ${fastq_file} | head -n 40000000 > ${fastq_dir}/${prefix}_R1_truncated.fq
zcat ${fastq_file_R2} | head -n 40000000 > ${fastq_dir}/${prefix}_R2_truncated.fq

## run BWA-MEM for competitive mapping
bwa mem -t 28 ${ref_genome} ${fastq_dir}/${prefix}_R1_truncated.fq ${fastq_dir}/${prefix}_R2_truncated.fq | samtools view -bS - > ${results_dir}/${prefix}_truncated.bam
samtools sort -@ 28 -o ${results_dir}/${prefix}_truncated_sorted.bam ${results_dir}/${prefix}_truncated.bam
samtools index ${results_dir}/${prefix}_truncated_sorted.bam
samtools idxstats ${results_dir}/${prefix}_truncated_sorted.bam > ${results_dir}/${prefix}_truncated_stats.txt


## loop over all fastq files in the directory and start sbatch for each of them
# data_dir=/user/antwerpen/205/vsc20587/scratch/leishmania_scDNA_mix/results/demux/concat/
# for fastq_file in $(find ${data_dir} -name "*_R1.tagged.fq.gz"); do sbatch --export=fastq_file=${fastq_file} /user/antwerpen/205/vsc20587/scratch/leishmania_scDNA_mix/bin/input_QC_BWA_competive_mapping_per_encaps.slurm; done