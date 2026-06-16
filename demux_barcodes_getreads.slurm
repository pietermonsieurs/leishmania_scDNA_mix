#!/bin/bash -l

#SBATCH --ntasks=1 --cpus-per-task=1
#SBATCH --time=50:50:00
#SBATCH --job-name=demux_fastq
#SBATCH -A ap_itg_mpu

module load atools
module load Python/3.12.3-GCCcore-13.3.0

## export PATH and specify parameters 
export PYTHONPATH="/user/antwerpen/205/vsc20587/data/software/python_lib/lib/python3.12/site-packages/:${PYTHONPATH}"
export PATH=/user/antwerpen/205/vsc20587/data/software/python_lib/bin/:/user/antwerpen/205/vsc20587/data/software/seqtk/:/user/antwerpen/205/vsc20587/scratch/leishmania_scDNA_mix/bin/:${PATH}

#### do echoing of the parameters for debugging purposes
echo "barcode file ${barcode_file}"
echo "fastq file R1 ${fastq_file_R1}"
echo "fastq file R2 ${fastq_file_R2}"
echo "demux dir ${demux_dir}"

## do the atools magic to get the barcode for this job
# source <(aenv --no_sniffer --data ${barcode_file})
barcode=$(sed -n "${SLURM_ARRAY_TASK_ID}p" ${barcode_file})
echo "processing barcdode ${barcode}"

## extract for the barcode all the read IDs that should be extracted
## from the fastq-files. The output of this is stored in a text file
## that contains all the read IDs that should be extracted for this barcode. 
demux_barcodes_getreads.py --outputdir ${demux_dir} --fastq ${fastq_file_R2} --barcode ${barcode}
read_id_file=${demux_dir}/${barcode}.readids.txt

## construct the output file name of the demux_barcodes_getreads.py command
## and create the output files of the demultiplexing. Write the fastq file to 
## the memory of the compute node and not to the shared file system, as this 
## prevents that the shared file system becomes a bottleneck and slows down the 
## full supercomputer
fastq_prefix=$(basename $fastq_file_R1 _1.fq.gz)
run_dir=/dev/shm/$USER/${fastq_prefix}/
mkdir -p ${run_dir}

fastq_file_barcode_R1=${run_dir}/${barcode}_R1.fastq.gz
fastq_file_barcode_R2=${run_dir}/${barcode}_R2.fastq
fastq_file_barcode_R2_with_bc=${run_dir}/${barcode}_R2_with_bc.fastq.gz

## run seqtk to extract the reads for this barcode from the fastq files. 
seqtk subseq ${fastq_file_R1} ${read_id_file} | gzip > ${fastq_file_barcode_R1}
# seqtk subseq ${fastq_file_R2} ${read_id_file} | seqtk trimfq -b 48 - | gzip > ${fastq_file_barcode_R2}
seqtk subseq ${fastq_file_R2} ${read_id_file} | gzip > ${fastq_file_barcode_R2_with_bc}
cutadapt --cut 48 -o ${fastq_file_barcode_R2} ${fastq_file_barcode_R2_with_bc}
gzip ${fastq_file_barcode_R2}

## create file names on the scratch file system to copy the output files to. This is needed 
## as the output files are currently stored in the memory of the compute node and not on the shared file system.
fastq_file_barcode_R1_scratch=${demux_dir}/${barcode}_R1.fastq.gz
fastq_file_barcode_R2_scratch=${demux_dir}/${barcode}_R2.fastq.gz
fastq_file_barcode_R2_with_bc_scratch=${demux_dir}/${barcode}_R2_with_bc.fastq.gz

cp ${fastq_file_barcode_R1} ${fastq_file_barcode_R1_scratch}
cp ${fastq_file_barcode_R2} ${fastq_file_barcode_R2_scratch}
cp ${fastq_file_barcode_R2_with_bc} ${fastq_file_barcode_R2_with_bc_scratch}

## count the number of reads in the fastq file for this barcode. This is done by counting the 
## number of lines in the fastq file and dividing it by 4
zcat ${fastq_file_barcode_R1_scratch} | wc -l | awk '{print $1/4}' > ${demux_dir}/${barcode}.read_count.txt

## installation of cutadapt
# module load Python/3.12.3-GCCcore-13.3.0
# cd /user/antwerpen/205/vsc20587/data/software/python_lib/lib
# mkdir -p python3.12/site-packages/
# export PYTHONPATH="/user/antwerpen/205/vsc20587/data/software/python_lib/lib/python3.12/site-packages/:${PYTHONPATH}"
# pip3 install --prefix=/user/antwerpen/205/vsc20587/data/software/python_lib/ cutadapt

