## load atools module
module load atools

## specify output directory for the dominant barcodes results
demux_source_dir=/user/antwerpen/205/vsc20587/scratch/leishmania_scDNA_mix/results/demux/
data_dir=/user/antwerpen/205/vsc20587/aitg_data/jcdujardin/MRC_singlecell_Atrandi_20260506/01.RawData/
bin_dir=/user/antwerpen/205/vsc20587/scratch/leishmania_scDNA_mix/bin/

## loop over all _1.fq.gz files
for fastq_file_R1 in $(find ${data_dir} -name "*_1.fq.gz"); do 

    ## do renaming of the fastq_file to get the corresponding R2 file and the output file name
    fastq_file_R2=${fastq_file_R1/_1.fq.gz/_2.fq.gz}
    fastq_prefix=$(basename $fastq_file_R1 _1.fq.gz)
    barcodes_dominant_file=${demux_source_dir}/${fastq_prefix}_dominant_barcodes.txt

    ## only select the first column (second column contains the count of the barcodes and is
    ## not needed for the next steps) and write the dominant barcodes to a file but in batches
    ## of 1000 barcodes to avoid memory issues in the next steps
    barcode_file=${demux_source_dir}/${demux_source_dir}_dominant_barcodes.txt
    cut -f1 ${barcodes_dominant_file} | split -l 1000 -d --additional-suffix=.txt - ${demux_source_dir}/${fastq_prefix}_batch_ 
    
    ## create output dir per batch to save the fastq files per barcode
    output_dir=${demux_source_dir}/${fastq_prefix}_demux/

    ## run sbatch for each batch of barcodes to get the fastq files per barcode, using the script demux_barcodes_getreads.slurm
    for barcode_batch_file in ${demux_source_dir}/${fastq_prefix}_batch_*.txt; do       
        echo $barcode_batch_file
        echo $fastq_file_R1
        echo $fastq_file_R2
        echo $output_dir
        sbatch \
            --array $(arange --no_sniffer --data $barcode_file) \
            --export=fastq_file_R1=${fastq_file_R1},fastq_file_R2=${fastq_file_R2},barcode_file=${barcode_file},demux_dir=${output_dir} \
            /user/antwerpen/205/vsc20587/scratch/leishmania_scDNA_atrandi/bin/demux_barcodes_getreads.slurm
    done
done

demux_dir=/user/antwerpen/205/vsc20587/scratch/leishmania_scDNA_atrandi/results/demux/scDNA_AT_02/
fastq_file_R1=/user/antwerpen/205/vsc20587/scratch/leishmania_scDNA_atrandi/data/fastq/scDNA_AT_02_1.fq.gz
fastq_file_R2=/user/antwerpen/205/vsc20587/scratch/leishmania_scDNA_atrandi/data/fastq/scDNA_AT_02_2.fq.gz
source <(aenv --no_sniffer --data /user/antwerpen/205/vsc20587/scratch/leishmania_scDNA_atrandi/results/demux/scDNA_AT_02_barcodes.txt)

