#!/bin/bash -l

#SBATCH --ntasks=1 --cpus-per-task=1
#SBATCH --time=0:50:00
#SBATCH --job-name=QC_demux2
#SBATCH -A ap_itg_mpu

## try out fastq_file
# fastq_file=/user/antwerpen/205/vsc20587/scratch/leishmania_scDNA_mix/results/demux/PTA01UDI5_MKDL260006321-1A_23HK37LT4_L7/encaps1_R1.tagged.fq.gz
# library=PTA01UDI5_MKDL260006321-1A_23HK37LT4_L7

## find the number of lines in the file and write to output file
out_dir=/user/antwerpen/205/vsc20587/scratch/leishmania_scDNA_mix/results/demux/debug/

## define the output file names
prefix=$(basename "$fastq_file" .tagged.fq.gz)
output_file=${out_dir}/${library}_${prefix}_line_count.txt

## check output
echo "Fastq file: ${fastq_file}"
echo "Output file: ${output_file}"
echo "Prefix: ${prefix}"
echo "Library: ${library}"

## count the lines and write the filename and line count to the output file
line_count=$(zcat "$fastq_file" | wc -l)
echo "${library},${prefix},${line_count}" > "${output_file}"


