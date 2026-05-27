#!/usr/bin/bash

#SBATCH --ntasks=1 --cpus-per-task=28
#SBATCH --time=0:50:00
#SBATCH --job-name=count
#SBATCH -A ap_itg_mpu

module load BWA
module load SAMtools

## parameter settings
results_dir=/user/antwerpen/205/vsc20587/scratch/leishmania_scDNA_mix/results/demux/competive_mapping/
fastq_dir=${results_dir}/fastq_truncated/

## create a combined reference genome
ref_genome=/user/antwerpen/205/vsc20587/scratch/leishmania_scDNA_mix/data/refgenomes/competitive_mapping/competitive_refgenome.fasta

## run for the first read of the fastq file - second read not yet available as 
## the second read still contains the barcode, which is not yet split of
# fastq_file=/user/antwerpen/205/vsc20587/aitg_data/jcdujardin/MRC_singlecell_Atrandi_20260506/01.RawData/PTA01UDI5/PTA01UDI5_MKDL260006321-1A_23HK37LT4_L7_1.fq.gz

## only select the first part of the prefix, before first _
prefix=$(basename ${fastq_file} _1.fq.gz)
prefix=${prefix%%_*}
echo $prefix

## only select the first 10 millions reads for testing from the fastq file
zcat ${fastq_file} | head -n 40000000 > ${fastq_dir}/${prefix}_R1_truncated.fq

## run BWA-MEM for competitive mapping
bwa mem -t 28 ${ref_genome} ${fastq_dir}/${prefix}_R1_truncated.fq | samtools view -bS - > ${results_dir}/${prefix}_R1_truncated.bam
samtools idxstats ${results_dir}/${prefix}_R1_truncated.bam > ${results_dir}/${prefix}_R1_truncated_stats.txt

## loop over all fastq files in the directory and start sbatch for each of them
# data_dir=/user/antwerpen/205/vsc20587/aitg_data/jcdujardin/MRC_singlecell_Atrandi_20260506/01.RawData/
# for fastq_file in $(find ${data_dir} -name "*_1.fq.gz"); do sbatch --export=fastq_file=${fastq_file} /user/antwerpen/205/vsc20587/scratch/leishmania_scDNA_mix/bin/input_QC_BWA_competive_mapping.slurm; done