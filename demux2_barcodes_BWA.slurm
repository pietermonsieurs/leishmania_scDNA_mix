#!/bin/bash -l

#SBATCH --ntasks=1 --cpus-per-task=64
#SBATCH --time=70:50:00
#SBATCH --job-name=demux_fastq
#SBATCH -A ap_itg_mpu

module purge
module load calcua/2024a
module load BWA
module load SAMtools

## create refence genome and fastq files based on the encapsulation
# encaps=encaps1
ref_genome_dir=/user/antwerpen/205/vsc20587/scratch/leishmania_scDNA_mix/data/refgenomes/encapsulations/
fastq_dir=/user/antwerpen/205/vsc20587/scratch/leishmania_scDNA_mix/results/demux/concat/
bam_dir=/user/antwerpen/205/vsc20587/scratch/leishmania_scDNA_mix/results/bwa/
seed=30
threads=64

## create variables
ref_genome=${ref_genome_dir}/${encaps}.fasta
# fastq_file_R1=${fastq_dir}/${encaps}_R1.fq.gz
# fastq_file_R2=${fastq_dir}/${encaps}_R2.fq.gz
fastq_file_R1=${fastq_dir}/${encaps}_R1.tagged.fq.gz
fastq_file_R2=${fastq_dir}/${encaps}_R2.tagged.fq.gz

file_prefix=${encaps}
# bam_file_prefix=${bam_dir}/${file_prefix}
bam_file_prefix=${bam_dir}/${file_prefix}.tagged

## echo variables for debugging
echo "Reference genome: $ref_genome"
echo "Fastq file R1: $fastq_file_R1"
echo "Fastq file R2: $fastq_file_R2"
echo "File prefix: $file_prefix"
echo "BAM file prefix: $bam_file_prefix"   

## run BWA mem to align the reads to the reference genome
bwa mem \
    -R "@RG\tID:${file_prefix}\tSM:${file_prefix}\tPL:ILLUMINA" \
    -k $seed \
    -t $threads \
    $ref_genome \
    $fastq_file_R1 $fastq_file_R2 | \
    samtools sort -@$threads -o ${bam_file_prefix}.bam
samtools index ${bam_file_prefix}.bam
samtools flagstat -@$THREADS ${bam_file_prefix}.bam > ${bam_file_prefix}.flagstat

## run for all encapsulations
# for encaps in encaps1 encaps2 encaps3 encaps4; do sbatch --export=encaps=$encaps /user/antwerpen/205/vsc20587/scratch/leishmania_scDNA_mix/bin/demux2_barcodes_BWA.slurm; done


