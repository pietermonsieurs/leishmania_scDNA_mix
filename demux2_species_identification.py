#!/usr/bin/env python3

import os
import sys
import argparse

src_dir = "/user/antwerpen/205/vsc20587/scratch/leishmania_scDNA_mix/results/bwa/"

## decide which species a read is mapped to based on how the chromosome is named in the reference genome
chrom_prefix_list = {
    "TcDm28c": "Tcruzi",
    "chr": "Tbg",
    "Tb927": "Tbb",
    "tco": "Tcongo", 
    "JBRIL": "Lperuv",
    "LbrM": "Lbraz"
}


## loop over all encaps directories
for encaps in os.listdir(src_dir):
    if encaps.startswith("encaps") and os.path.isdir(os.path.join(src_dir, encaps)):
        
        print(f"Processing encapsulation directory: {encaps}")

        ## creating output file to write the species counts for each barcode
        output_file_path = os.path.join(src_dir, f"{encaps}_species_counts.txt")
        with open(output_file_path, "w") as output_file:
            output_file.write("Barcode\t" + "\t".join(chrom_prefix_list.values()) + "\n")

        for idxstats_file in os.listdir(os.path.join(src_dir, encaps)):
            
            if not idxstats_file.endswith("_idxstats.txt"):
                continue

            barcode = idxstats_file.replace("_idxstats.txt", "")
            print(f"Processing {encaps} -- {barcode}")

            ## sum over idxstats, where first column contains the chromosome name
            ## and the third column the number of mapped reads. sum per species based
            ## on the chromosome name prefix all counts of mapped reads per species
            species_counts = {species: 0 for species in chrom_prefix_list.values()}

            with open(os.path.join(src_dir, encaps, idxstats_file), "r") as f:
                for line in f:
                    parts = line.strip().split("\t")
                    if len(parts) < 3:
                        continue
                    chrom_name = parts[0]
                    mapped_reads = int(parts[2])

                    for prefix, species in chrom_prefix_list.items():
                        if chrom_name.startswith(prefix):
                            species_counts[species] += mapped_reads
                            break
            
            print(species_counts)
            output_line = barcode + "\t" + "\t".join(str(species_counts[species]) for species in chrom_prefix_list.values()) + "\n"
            with open(output_file_path, "a") as output_file:
                output_file.write(output_line)            

