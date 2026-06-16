#!/bin/bash -l

#SBATCH --ntasks=1 --cpus-per-task=1
#SBATCH --mem-per-cpu=100G
#SBATCH --time=50:50:00
#SBATCH --job-name=demux_fastq
#SBATCH -A ap_itg_mpu

## add bin directory to the PATH to be able to run the demultiplexing script
module load Python/3.12.3-GCCcore-13.3.0

## export PATH and specify parameters 
export PYTHONPATH="/user/antwerpen/205/vsc20587/data/software/python_lib/lib/python3.12/site-packages/:${PYTHONPATH}"
export PATH=/user/antwerpen/205/vsc20587/scratch/leishmania_scDNA_mix/bin:/user/antwerpen/205/vsc20587/data/software/python_lib/bin/:/user/antwerpen/205/vsc20587/data/software/seqtk/:/user/antwerpen/205/vsc20587/scratch/leishmania_scDNA_mix/bin/:${PATH}

## parameter settings
barcode_file=/user/antwerpen/205/vsc20587/scratch/leishmania_scDNA_mix/results/demux/dominant_barcodes_merged.txt
output_dir_src=/user/antwerpen/205/vsc20587/scratch/leishmania_scDNA_mix/results/demux/
fastq_dir=/user/antwerpen/205/vsc20587/aitg_data/jcdujardin/MRC_singlecell_Atrandi_20260506/01.RawData


## hardcoded for now, but can be easily adapted to loop through all fastq files in the directory
# fastq_file_R1=/user/antwerpen/205/vsc20587/aitg_data/jcdujardin/MRC_singlecell_Atrandi_20260506/01.RawData/PTA01UDI5/PTA01UDI5_MKDL260006321-1A_23HK37LT4_L7_1.fq.gz

## create the second read file name by replacing the R1 with R2
echo "Processing fastq file: ${fastq_file_R1}"
fastq_file_R2=${fastq_file_R1/_1.fq.gz/_2.fq.gz}
fastq_prefix=$(basename $fastq_file_R1 _1.fq.gz)
output_dir=${output_dir_src}/${fastq_prefix}/

## create output diretory to store per fastq file with fastq for each encapsulation
mkdir -p $output_dir

## run the demultiplexing script to get a list of readIDs per encapsulation
echo "Running demultiplexing script to get readIDs per encapsulation"
demux2_barcodes_split_encapsulation.py \
    --barcode_file $barcode_file \
    --output_dir $output_dir \
    --fastq_file $fastq_file_R2


## run seqtk to extract the reads for this barcode from the fastq files for each of the 
## encapsulations, and trim the R2 reads to remove the barcode sequence (48bp) at the start of the read

echo "Extracting reads for each encapsulation and trimming R2 reads to remove barcode sequence"
for encaps in encaps1 encaps2 encaps3 encaps4; do
    ## define files
    read_id_file=${output_dir}/${encaps}_read_ids.txt
    fastq_file_encaps_R1=${output_dir}/${encaps}_R1.fq.gz
    fastq_file_encaps_R2_with_bc=${output_dir}/${encaps}_R2_with_bc.fq.gz
    fastq_file_encaps_R2=${output_dir}/${encaps}_R2.fq.gz

    seqtk subseq ${fastq_file_R1} ${read_id_file} | gzip > ${fastq_file_encaps_R1}
    seqtk subseq ${fastq_file_R2} ${read_id_file} | gzip > ${fastq_file_encaps_R2_with_bc}
    cutadapt --cut 48 -j 0 -o ${fastq_file_encaps_R2} ${fastq_file_encaps_R2_with_bc}
    gzip ${fastq_file_barcode_R2}
done


## loop over the different fastq files
# data_dir=/user/antwerpen/205/vsc20587/aitg_data/jcdujardin/MRC_singlecell_Atrandi_20260506/01.RawData
# for fastq_file_R1 in $(find ${data_dir} -name "*_1.fq.gz"); do sbatch --export=fastq_file_R1=${fastq_file_R1} demux2_barcodes_split_encapsulation.slurm; done
