#!/usr/bin/bash 

#SBATCH --ntasks=1 --cpus-per-task=4
#SBATCH --time=10:50:00
#SBATCH --job-name=specied_ID
#SBATCH -A ap_itg_mpu
#SBATCH --job-name=flagstat

## load modules
module load SAMtools

## encapsulation should be passed in the sbatch command
# encaps=encaps1
bwa_dir=/user/antwerpen/205/vsc20587/scratch/leishmania_scDNA_mix/results/bwa/${encaps}_split_bams/

## remove the summary file if it already exists
rm ${bwa_dir}/flagstat_summary.txt

## check the flagstat of all bam files
for bam_file in ${bwa_dir}/*.bam; do
    echo "Processing ${bam_file}..."
    
    ## run samtools flagstat
    samtools flagstat ${bam_file} > ${bam_file%.bam}_flagstat.txt
    barcode=$(basename ${bam_file%.bam})

    ## extract the total number of reads, the number of mapped reads, and the percentage of mapped reads
    total_reads=$(grep "in total" ${bam_file%.bam}_flagstat.txt | awk '{print $1}')
    mapped_reads=$(grep "+ 0 mapped (" ${bam_file%.bam}_flagstat.txt | awk '{print $1}')
    mapped_percentage=$(grep "+ 0 mapped (" ${bam_file%.bam}_flagstat.txt | awk '{print $5}' | tr -d '()%')
    proper_reads=$(grep "properly paired (" ${bam_file%.bam}_flagstat.txt | awk '{print $1}')
    proper_percentage=$(grep "properly paired (" ${bam_file%.bam}_flagstat.txt | awk '{print $6}' | tr -d '()%')

    ## write the results to a summary file
    # echo -e "${barcode}\t${total_reads}\t${mapped_reads}\t${mapped_percentage}\t${proper_reads}\t${proper_percentage}" >> ${bwa_dir}/flagstat_summary.txt
    echo -e "${barcode}\t${total_reads}\t${mapped_reads}\t${mapped_percentage}\t${proper_reads}\t${proper_percentage}" >> ${bwa_dir}/flagstat_summary.txt

done

## loop over all encapsulations and run the script for each one
# for encaps in encaps1 encaps2 encaps3 encaps4; do
#     sbatch --export=encaps=${encaps} /user/antwerpen/205/vsc20587/scratch/leishmania_scDNA_mix/bin/input_QC_check_flagstat.slurm
# done