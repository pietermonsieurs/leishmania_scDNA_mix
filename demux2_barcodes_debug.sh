## loop with a find over all files in the directory where the subdirectory starts
## with PTA or Undetermined and ends with .fastq.gz
input_dir="/user/antwerpen/205/vsc20587/scratch/leishmania_scDNA_mix/results/demux/"
cd $input_dir

for dir in ./*/; do
    if [[ $dir == *PTA* || $dir == *Undetermined* ]]; then
        dir=${dir#./}   # remove leading ./
        dir=${dir%/}    # remove trailing /   
        for file in ${input_dir}/${dir}/*_R1.tagged.fq.gz; do
            if [[ -f ${file} ]]; then
                echo $dir
                echo $file
                sbatch --export=fastq_file=${file},library=${dir} /user/antwerpen/205/vsc20587/scratch/leishmania_scDNA_mix/bin/demux2_barcodes_debug.slurm
            fi
        done
    fi
done


## something went wrong with extraction of the barcodes of encaps 3 - some fastq files are empty, 
## read ids file is not empty, so it is related to the seqtk command
# PTA01UDI5_MKDL260006321-1A_23HK37LT4_L7,encaps3_R1,1463607832
# PTA01UDI5_MKDL260006321-1A_23HK37LT4_L8,encaps3_R1,1502104004
# PTA02UDI6_MKDL260006322-1A_23HK37LT4_L7,encaps3_R1,0
# PTA02UDI6_MKDL260006322-1A_23HK37LT4_L8,encaps3_R1,0
# PTA03UDI7_MKDL260006323-1A_23HK37LT4_L7,encaps3_R1,0
# PTA03UDI7_MKDL260006323-1A_23HK37LT4_L8,encaps3_R1,0
# PTA04UDI8_MKDL260006324-1A_23HK37LT4_L7,encaps3_R1,0
# PTA04UDI8_MKDL260006324-1A_23HK37LT4_L8,encaps3_R1,0
# Undetermined_Undetermined_23HK37LT4_L7,encaps3_R1,419850840
# Undetermined_Undetermined_23HK37LT4_L8,encaps3_R1,434767596