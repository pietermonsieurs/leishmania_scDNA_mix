#!/usr/bin/env python3

import argparse
import os
import sys
import gzip

def get_barcodes(barcode_file):
    encapsulation_barcodes = {}
    with open(barcode_file, 'r') as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            parts = line.split('\t')
            if len(parts) < 2:
                print(f"Warning: Skipping malformed line: {line}")
                continue
            encapsulation_id = parts[3]
            barcode = parts[0]
            encapsulation_barcodes[barcode] = encapsulation_id

    return encapsulation_barcodes

def process_fastq(fastq_file, encapsulation_barcodes, limit=None):
    ## extract the read ID and the barcode from the R2 fastq file and check whether the barcode exists
    ## in the encapsulation_barcodes dictionary. If it does, store the read ID in a 
    ## dictionary per encapsulation.

    encaps_barcodes = {}
    count = 0
    count_found = 0
    break_while_loop = False

    with gzip.open(fastq_file, 'rt') as f:
        for i, line in enumerate(f, start=1):
            if (i % 4 == 1):  # Process the header line
                read_id = line.strip().split()[0][1:]  # Extract the read ID without the '@' symbol
                # print(f"Processing read ID: {read_id}")
            if (i - 2) % 4 == 0:  # Process the sequence line
                count += 1
                read = line.strip()

                barcode = f"{read[:8]}_{read[12:20]}_{read[24:32]}_{read[36:44]}"
                if barcode in encapsulation_barcodes:
                    encaps_id = encapsulation_barcodes[barcode]
                    # print(f"Found barcode: {barcode} for read ID: {read_id}, encapsulation ID: {encaps_id}")
                    if encaps_id not in encaps_barcodes:
                        encaps_barcodes[encaps_id] = []
                    encaps_barcodes[encaps_id].append(read_id)
                    count_found += 1

                if count > 0 and count % 100000 == 0:
                    print(f"Processed {count} lines | found {count_found} [{int(100*count_found/count)}%] barcodes dominant") 

                # if count > 0 and count % 1000000 == 0:
                #     # return encaps_barcodes
                #     break

    return encaps_barcodes

def main():

    ## parser command line arguments with flags for the different inputs
    parser = argparse.ArgumentParser(description="Split encapsulation files into separate files based on barcodes.")
    parser.add_argument("--barcode_file", help="Path to the input file containing the dominant barcodes")
    parser.add_argument("--fastq_file", help="Path to the input file containing R2 fastq file containing the barcode.")
    parser.add_argument("--output_dir", help="Directory where the text files with the read IDs per encapsulation will be stored.")
    args = parser.parse_args()

    
    if not os.path.isfile(args.barcode_file):
        print(f"Error: Barcode file '{args.barcode_file}' does not exist.")
        sys.exit(1)

    if not os.path.exists(args.output_dir):
        os.makedirs(args.output_dir)

    ## read barcode information and store in a dictionary per encapsulation
    encapsulation_barcodes = get_barcodes(args.barcode_file)
    encaps_readids = process_fastq(args.fastq_file, encapsulation_barcodes)

    ## write the read IDs per encapsulation to separate text files
    for encaps_id, read_ids in encaps_readids.items():
        output_file = os.path.join(args.output_dir, f"{encaps_id}_read_ids.txt")
        with open(output_file, 'w') as f:
            for read_id in read_ids:
                f.write(f"{read_id}\n")

main()