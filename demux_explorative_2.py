#!/usr/bin/env python3

#SBATCH --ntasks=1 --cpus-per-task=1
#SBATCH --time=0:50:00
#SBATCH --job-name=count
#SBATCH -A ap_itg_mpu

import gzip
import os
from collections import defaultdict

## read the fastq file name from the command line argument using the --export flag of sbatch
fastq_file = os.environ.get("fastq_file")

# fastq_file = '/user/antwerpen/205/vsc20587/scratch/leishmania_scDNA_atrandi/data/fastq/scDNA_AT_01_2.fq.gz'
# fastq_file = '/user/antwerpen/205/vsc20587/scratch/leishmania_scDNA_atrandi/data/fastq/scDNA_AT_02_2.fq.gz'
output_dir = '/user/antwerpen/205/vsc20587/scratch/leishmania_scDNA_mix/results/demux/'

## create the barcdode count file name by replacing the _2.fq.gz suffix with _barcode_counts.txt and 
## use another output directory so replace the directory of the fastq_file
prefix = fastq_file.split('/')[-1]
barcode_count_file = prefix.replace("_2.fq.gz", "_barcode_counts.txt")
barcode_count_file = f"{output_dir}/{barcode_count_file}"
count_barcode = defaultdict(int)
count = 0

with gzip.open(fastq_file, 'rt') as f:
    for i, line in enumerate(f, start=1):
        if (i - 2) % 4 == 0:
            count += 1
            read = line.strip()
            
            
            barcode = f"{read[:8]}_{read[12:20]}_{read[24:32]}_{read[36:44]}"
            if 'N' not in barcode:
                count_barcode[barcode] += 1
            if count % 1000000 == 0:
                break
                # print(count)
                
# Sort the dictionary by count (from high to low) and print
sorted_barcodes = sorted(count_barcode.items(), key=lambda x: x[1], reverse=True)


out_fh = open(barcode_count_file, 'w')
for barcode, count in sorted_barcodes:
#     if count > 100:
    print(f"'{barcode}': {count}")
    line_out = f"{barcode}\t{count}\n"
    out_fh.write(line_out)


## loop over the different R2 fastq files in a directory and all its subdirectories. This 
## is a bash line - commented out - that can be used to run the above code for all R2 fastq
## files in a directory and its subdirectories. This should be for loop to run the different 
## commands using sbatch with --export flag
# for file in $(find /user/antwerpen/205/vsc20587/aitg_data/jcdujardin/MRC_singlecell_Atrandi_20260506/01.RawData -name "*_2.fq.gz"); do sbatch --export=fastq_file=$file /user/antwerpen/205/vsc20587/scratch/leishmania_scDNA_mix/bin/demux_explorative_2.py; done