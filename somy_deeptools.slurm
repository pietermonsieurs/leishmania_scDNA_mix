#!/usr/bin/bash 

#SBATCH --ntasks=1 --cpus-per-task=4
#SBATCH --time=10:50:00
#SBATCH --job-name=demux_fastq
#SBATCH -A ap_itg_mpu
#SBATCH --job-name=somy_deeptools


## load moddules and export the PATHs
module load Python/3.13.1-GCCcore-14.2.0
module load scikit-learn
module load SAMtools

export PYTHONPATH="/user/antwerpen/205/vsc20587/data/software/python_lib/lib/python3.13/site-packages/:${PYTHONPATH}"
export PATH=/user/antwerpen/205/vsc20587/data/software/python_lib/bin/:${PATH}

# define the bin size for the coverage calculation. Low coverage so take high enough bin size to avoid too many zeroes in the bedgraph file.
bin_size=10000

# define the number of threads to use for bamCoverage
threads=4

## check input parameters
echo ${batch_file}
echo ${output_dir}

## loop over the batch file containing the bam files and run bamCoverage for each file
while read -r bam_file; do
    echo "Processing $bam_file"
    samtools index ${bam_file}

    # extract the base name of the bam file without the extension
    base_name=$(basename "$bam_file" .bam)

    # define the output file name for the bedgraph file
    output_file=${output_dir}/${base_name}.bedgraph
    echo ${output_file}

    ## run deeptools
    bamCoverage \
        --bam $bam_file \
        --outFileName $output_file \
        --outFileFormat bedgraph \
        --binSize $bin_size \
        --normalizeUsing CPM \
        --numberOfProcessors $threads
        # --skipNonCoveredRegions

done < ${batch_file}

