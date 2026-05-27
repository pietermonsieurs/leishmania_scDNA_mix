## specify output directory for the dominant barcodes results
output_dir=/user/antwerpen/205/vsc20587/scratch/leishmania_scDNA_mix/results/demux/
data_dir=/user/antwerpen/205/vsc20587/aitg_data/jcdujardin/MRC_singlecell_Atrandi_20260506/01.RawData/
bin_dir=/user/antwerpen/205/vsc20587/scratch/leishmania_scDNA_mix/bin/


## OPTION 1: run for one directory containing all the fastq files (this 
## will run the script for all fastq files in that directory)
sbatch ${bin_dir}/demux_barcodes_dominant.py \
    --fastq ${data_dir}/ \
    --output ${output_dir}/dominant_barcodes_all.txt \
    --mincount 10000

## OPTION 2: loop over all _2.fq.gz files, in case you want to do this fastq file
# per fastq file
for file in $(find ${data_dir} -name "*_2.fq.gz"); do 
    output_file=$(basename $file _2.fq.gz)
    output_file=${output_dir}/${output_file}_dominant_barcodes.txt
    sbatch ${bin_dir}/demux_barcodes_dominant.py \
        --fastq $file \
        --output $output_file \
        --mincount 1000 
done