#!/bin/bash -l

#SBATCH --ntasks=1 --cpus-per-task=16 --nodes=1 --partition=zen3_512
#SBATCH --mem=480G
#SBATCH --time=70:50:00
#SBATCH --job-name=splitBC
#SBATCH -A ap_itg_mpu

module purge
module load calcua/2024a
module load Pysam

## hard coded encapsulation file. Can also be added via the --export flag is this would
## be needed for future experiments
encaps=encaps3
bwa_dir="/user/antwerpen/205/vsc20587/scratch/leishmania_scDNA_mix/results/bwa/"
bam_file=${bwa_dir}/${encaps}.cb.bam

## split of the last 2 digits (=end of file) from the batch_file variable to get the batch number
batch_num=$(basename ${batchfile} | sed 's/.*_batch_//;s/.txt//')

## defined the output directory for the split bam files, which is the RAM of the compute node
out_dir=/dev/shm/$USER/${encaps}_split_bams_batch_${batch_num}/

## run python script to split the bam file by cell barcode and output to the RAM of the compute node
/user/antwerpen/205/vsc20587/scratch/leishmania_scDNA_mix/bin/demux2_barcodes_BWA_bam_per_CB_batch.py -bamfile ${bam_file} -outdir ${out_dir} -batchfile ${batchfile}

## copy the directory with the split bam files from the RAM of the compute node to the scratch directory
cp -r ${out_dir}/*.bam ${bwa_dir}/${encaps}_split_bams/


## loop over different batch files. This should only be run for encaps3, as for the other ones the 
## non-batch scripts are manageable with the amount of RAM available. 
# encaps=encaps3
# batch_dir=/user/antwerpen/205/vsc20587/scratch/leishmania_scDNA_mix/results/demux/batches_${encaps}/
# for batchfile in ${batch_dir}/*_batch_*; do
#     echo "Processing batch file: ${batchfile}"
#     sbatch --export=batchfile=${batchfile} /user/antwerpen/205/vsc20587/scratch/leishmania_scDNA_mix/bin/demux2_barcodes_BWA_bam_per_CB_batch.slurm
# done