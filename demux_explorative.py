#!/usr/bin/env python3

import gzip
from collections import defaultdict

barcode_file = '/user/antwerpen/205/vsc20587/scratch/leishmania_scDNA_atrandi/data/atrandi/atrandi_whitelist_barcodes.csv'
# fastq_file = '/user/antwerpen/205/vsc20587/scratch/leishmania_scDNA_atrandi/data/fastq/scDNA_AT_01_2.fq.gz'
fastq_file = '/user/antwerpen/205/vsc20587/scratch/leishmania_scDNA_atrandi/data/fastq/scDNA_AT_02_2.fq.gz'
barcode_out_file = fastq_file.replace("_2.fq.gz", "_barcodes_whitelist.txt")

count_barcode_D = defaultdict(int)
count_barcode_C = defaultdict(int)
count_barcode_B = defaultdict(int)
count_barcode_A = defaultdict(int)

count = 0

with gzip.open(fastq_file, 'rt') as f:
    for i, line in enumerate(f, start=1):
        if (i - 2) % 4 == 0:
            count += 1
            read = line.strip()
            
            
            barcode_D = read[:8]
            if 'N' not in barcode_D:
                count_barcode_D[barcode_D] += 1
        
            barcode_C = read[12:20]
            if 'N' not in barcode_C:
                count_barcode_C[barcode_C] += 1
        
            barcode_B = read[24:32]
            if 'N' not in barcode_B:
                count_barcode_B[barcode_B] += 1

            barcode_A = read[36:44]
            if 'N' not in barcode_A:
                count_barcode_A[barcode_A] += 1

        if count > 10000000:
            break

# Sort the dictionary by count (from high to low) and print
sorted_barcodes = sorted(count_barcode_D.items(), key=lambda x: x[1], reverse=True)

for barcode, count in sorted_barcodes:
    if count > 100:
        print(f"[D]'{barcode}': {count}")

sorted_barcodes = sorted(count_barcode_C.items(), key=lambda x: x[1], reverse=True)
for barcode, count in sorted_barcodes:
    if count > 250:
        print(f"[C]'{barcode}': {count}")

sorted_barcodes = sorted(count_barcode_B.items(), key=lambda x: x[1], reverse=True)
for barcode, count in sorted_barcodes:
    if count > 250:
        print(f"[B]'{barcode}': {count}")

sorted_barcodes = sorted(count_barcode_A.items(), key=lambda x: x[1], reverse=True)
for barcode, count in sorted_barcodes:
    if count > 250:
        print(f"[A]'{barcode}': {count}")


## check the overlap with the barcode in the Atrandi file
barcode_fh = open(barcode_file, 'r')
barcode_out = open(barcode_out_file, 'w')
for line in barcode_fh:
    line = line.rstrip()
    if line.startswith("pos"):
        continue

    data = line.split("\t")
    barcode_pos = data[0]
    well = data[1]
    barcode = data[2]

    line_out = f"{line}\t{count_barcode_A[barcode]}\t{count_barcode_B[barcode]}\t{count_barcode_C[barcode]}\t{count_barcode_D[barcode]}\n"
    barcode_out.write(line_out)
    print(line_out)





