#!/usr/bin/env python3

import pysam
import os
import sys
import argparse

## parser command line arguments with flags for the different inputs
parser = argparse.ArgumentParser(description="extract barcode from read name and add as CB tag in the bam file")
parser.add_argument("-bamfile", help="Encapsulation number to be processed. This will be used to name the output bam file.")
parser.add_argument("-outdir", help="This is the output directory which is stored in the RAM of the compute node. Needs to be copied afterwards to the final output directory in the scratch of the user.")
parser.add_argument("-batchfile", help="This is the batch file which contains the list of barcodes to be processed. For each barcode a list of file handles will be created")


## read in arguments from the command line
args = parser.parse_args()
bam_file = args.bamfile
out_dir = args.outdir
batch_file = args.batchfile



## create input bam file (and open it) and output directory (and create it)
# bam_file = f"{data_dir}/{encaps}.cb.bam"
# out_dir = f"{data_dir}/{encaps}_barcodebams/"
bam = pysam.AlignmentFile(bam_file, "rb")
os.makedirs(out_dir, exist_ok=True)

writers = {}
count = 0 

## create file handles for each barcode in the batch file
with open(batch_file, "r") as f:
    barcodes = [line.strip() for line in f]

writers = {}

for cb in barcodes:
    writers[cb] = pysam.AlignmentFile(
        f"{out_dir}/{cb}.bam",
        "wb",
        template=bam
    )
  

for read in bam:
    count += 1
    try:
        cb = read.get_tag("CB")
    except KeyError:
        continue

    # create writer if first time seeing this barcode
    if cb not in writers:
        continue # skip barcodes not in the batch file - only keep barcodes present in the batch file

    writers[cb].write(read)

    if count % 100000 == 0:
        print(f"Processed {count} reads...")
        # break

# close all files
for w in writers.values():
    w.close()

bam.close()