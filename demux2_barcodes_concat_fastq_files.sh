## concatenate all fastq files with encaps1, encaps2, and encaps3 barcodes into one fastq file for 
## both R1 and R2 reads. Find all files in the current directory that match the pattern *_R1_*.fastq.gz
##  and *_R2_*.fastq.gz, and concatenate them into two separate files per encapsulation

data_dir=/user/antwerpen/205/vsc20587/scratch/leishmania_scDNA_mix/results/demux/
output_dir=/user/antwerpen/205/vsc20587/scratch/leishmania_scDNA_mix/results/demux/concat/

cd ${data_dir}
# for encaps in encaps1 encaps2 encaps3 encaps4; do
for encaps in encaps2 encaps3 encaps4; do
    cat PTA*_L*/${encaps}_R1.fq.gz Undetermined*_L*/${encaps}_R1.fq.gz > ${output_dir}/${encaps}_R1.fq.gz
    cat PTA*_L*/${encaps}_R2.fq.gz Undetermined*_L*/${encaps}_R2.fq.gz > ${output_dir}/${encaps}_R2.fq.gz
    cat PTA*_L*/${encaps}_R2_with_bc.fq.gz Undetermined*_L*/${encaps}_R2_with_bc.fq.gz > ${output_dir}/${encaps}_R2_with_bc.fq.gz
    # cat PTA*_L*/${encaps}_read_ids.txt Undetermined*_L*/${encaps}_read_ids.txt > ${encaps}_read_ids.txt
done


## the same but now if the adding of the barcode in the read name has already been done
cd ${data_dir}
for encaps in encaps1 encaps2 encaps3 encaps4; do
    echo "Concatenating files for ${encaps}..."
    cat PTA*_L*/${encaps}_R1.tagged.fq.gz Undetermined*_L*/${encaps}_R1.tagged.fq.gz > ${output_dir}/${encaps}_R1.tagged.fq.gz
    cat PTA*_L*/${encaps}_R2.tagged.fq.gz Undetermined*_L*/${encaps}_R2.tagged.fq.gz > ${output_dir}/${encaps}_R2.tagged.fq.gz
    # cat PTA*_L*/${encaps}_R2_with_bc.fq.gz Undetermined*_L*/${encaps}_R2_with_bc.fq.gz > ${output_dir}/${encaps}_R2_with_bc.fq.gz
    # cat PTA*_L*/${encaps}_read_ids.txt Undetermined*_L*/${encaps}_read_ids.txt > ${encaps}_read_ids.txt
done