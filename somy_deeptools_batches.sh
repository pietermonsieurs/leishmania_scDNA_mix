## split the bam files into text files of bam files of 100 files each
batch_size=100

# for encaps in encaps1 encaps2 encaps3 encaps4; do
for encaps in encaps3; do
    encaps_dir=/user/antwerpen/205/vsc20587/scratch/leishmania_scDNA_mix/results/bwa/${encaps}_split_bams/
    bam_files=($(ls ${encaps_dir}/*.bam))
    total_files=${#bam_files[@]}
    num_batches=$(( (total_files + batch_size - 1) / batch_size ))

    for ((i=0; i<num_batches; i++)); do
        start_index=$((i * batch_size))
        end_index=$((start_index + batch_size))
        if [ $end_index -gt $total_files ]; then
            end_index=$total_files
        fi

        batch_files=("${bam_files[@]:start_index:end_index-start_index}")
        batch_file_name=${encaps_dir}/${encaps}_batch_$((i+1)).txt
        printf "%s\n" "${batch_files[@]}" > "$batch_file_name"
    done    
done

## loop over all the text files in the different encaps directories and run the deeptools commands
# for encaps in encaps1 encaps2 encaps3 encaps4; do
# for encaps in encaps1 encaps2 encaps4; do
for encaps in encaps3; do
    ## specify directories
    encaps_dir=/user/antwerpen/205/vsc20587/scratch/leishmania_scDNA_mix/results/bwa/${encaps}_split_bams/
    output_dir=/user/antwerpen/205/vsc20587/scratch/leishmania_scDNA_mix/results/deeptools/${encaps}/

    ## loop over all the batch files and submit a job for each batch file
    batch_files=($(ls ${encaps_dir}/*batch*.txt))
    for batch_file in "${batch_files[@]}"; do
        mkdir -p ${output_dir}

        echo $batch_file
        sbatch \
            --export=batch_file=${batch_file},output_dir=${output_dir} \
            /user/antwerpen/205/vsc20587/scratch/leishmania_scDNA_mix/bin/somy_deeptools.slurm

    done
done


## check the file sizes
cd /user/antwerpen/205/vsc20587/scratch/leishmania_scDNA_mix/results/bwa/

module load SAMtools

## check number of reads in the bam file
samtools view -c encaps2.cb.bam

## check the number of reads in the split bam files
find encaps2_split_bams -name "*.bam" -print0 |
xargs -0 -I{} samtools view -c "{}" |
awk '{sum+=$1} END {print sum}'