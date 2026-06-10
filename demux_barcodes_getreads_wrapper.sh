## specify output directory for the dominant barcodes results
demux_source_dir=/user/antwerpen/205/vsc20587/scratch/leishmania_scDNA_mix/results/demux/
barcode_file_source=${demux_source_dir}/dominant_barcodes_merged.txt
data_dir=/user/antwerpen/205/vsc20587/aitg_data/jcdujardin/MRC_singlecell_Atrandi_20260506/01.RawData/
bin_dir=/user/antwerpen/205/vsc20587/scratch/leishmania_scDNA_mix/bin/

barcode_file=${demux_source_dir}/barcodes_input_jobarray.txt
tail -n +2 "${barcode_file_source}" | cut -f 1 > "${barcode_file}"

## loop over all _1.fq.gz files
for fastq_file_R1 in $(find ${data_dir} -name "*_1.fq.gz"); do 

    ## do renaming of the fastq_file to get the corresponding R2 file and the output file name
    fastq_file_R2=${fastq_file_R1/_1.fq.gz/_2.fq.gz}
    fastq_prefix=$(basename $fastq_file_R1 _1.fq.gz)

    ## create output dir per batch to save the fastq files per barcode
    output_dir=${demux_source_dir}/${fastq_prefix}_demux/

    ## run sbatch for all barcodes to get the fastq files per barcode and per fastq file. Merging of the 
    ## fastq files over the different fastqfiles will happen at a later stage. Using the script demux_barcodes_getreads.slurm
    echo $barcode_file
    echo $fastq_file_R1
    echo $fastq_file_R2
    echo $output_dir
    sbatch \
        --array=1-$(wc -l < ${barcode_file}) \
        --export=fastq_file_R1=${fastq_file_R1},fastq_file_R2=${fastq_file_R2},barcode_file=${barcode_file},demux_dir=${output_dir} \
        ${bin_dir}/demux_barcodes_getreads.slurm
done

