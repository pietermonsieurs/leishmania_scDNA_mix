## specify output directory for the dominant barcodes results
demux_source_dir=/user/antwerpen/205/vsc20587/scratch/leishmania_scDNA_mix/results/demux/
barcode_file_source=${demux_source_dir}/dominant_barcodes_merged.txt
data_dir=/user/antwerpen/205/vsc20587/aitg_data/jcdujardin/MRC_singlecell_Atrandi_20260506/01.RawData/
bin_dir=/user/antwerpen/205/vsc20587/scratch/leishmania_scDNA_mix/bin/

barcode_file=${demux_source_dir}/barcodes_input_jobarray.txt
tail -n +2 "${barcode_file_source}" | cut -f 1 > "${barcode_file}"

# head -n 10 ${barcode_file} > ${demux_source_dir}/barcodes_input_jobarray_test.txt
# barcode_file=/user/antwerpen/205/vsc20587/scratch/leishmania_scDNA_mix/results/demux//barcodes_input_jobarray_test.txt


## loop over all _1.fq.gz files
for fastq_file_R1 in $(find ${data_dir} -name "*_1.fq.gz"); do 
    ## dummy fastq file for testing
    # fastq_file_R1=/user/antwerpen/205/vsc20587/aitg_data/jcdujardin/MRC_singlecell_Atrandi_20260506/01.RawData/PTA01UDI5/PTA01UDI5_MKDL260006321-1A_23HK37LT4_L7_1.fq.gz

    ## do renaming of the fastq_file to get the corresponding R2 file and the output file name
    fastq_file_R2=${fastq_file_R1/_1.fq.gz/_2.fq.gz}
    fastq_prefix=$(basename $fastq_file_R1 _1.fq.gz)

    ## create output dir per batch to save the fastq files per barcode
    output_dir=${demux_source_dir}/${fastq_prefix}_demux/
    mkdir -p ${output_dir}

    ## run sbatch for all barcodes to get the fastq files per barcode and per fastq file. Merging of the 
    ## fastq files over the different fastqfiles will happen at a later stage. Using the script demux_barcodes_getreads.slurm
    echo $barcode_file
    echo $fastq_file_R1
    echo $fastq_file_R2
    echo $output_dir

    ## only 1000 jobs can be submitted at once, so we need to split array into field running from 1 - 1000, 1001 - 2000, etc. 
    N_max=$(wc -l < ${barcode_file})
    batch_size=1000
    echo "Submitting ${N_max} jobs for ${fastq_prefix} with batch size ${batch_size}"
    
    ## loop over the number of jobs to submit and create sub batches of 1000 jobs each
    split -l 1000 -d -a 2 "${barcode_file}" ${demux_source_dir}/${fastq_prefix}_demux/barcode_chunk_

    for f in ${demux_source_dir}/${fastq_prefix}_demux/barcode_chunk_*; do

        # count lines in this chunk (for last partial batch)
        n=$(wc -l < "$f")
        
        ## run sbatch script
        sbatch \
            --array=1-${n} \
            --export=fastq_file_R1=${fastq_file_R1},fastq_file_R2=${fastq_file_R2},barcode_file=${f},demux_dir=${output_dir} \
            ${bin_dir}/demux_barcodes_getreads.slurm

    done

done

