#!/usr/bin/env python3

#SBATCH --ntasks=1 --cpus-per-task=4
#SBATCH --time=70:50:00
#SBATCH --job-name=CB_tag
#SBATCH -A ap_itg_mpu

## module load Pysam

import pysam
import re
import argparse

## parser command line arguments with flags for the different inputs
parser = argparse.ArgumentParser(description="extract barcode from read name and add as CB tag in the bam file")
parser.add_argument("--encaps", help="Encapsulation number to be processed. This will be used to name the output bam file.")
args = parser.parse_args()
encaps = args.encaps

bam_dir = "/user/antwerpen/205/vsc20587/scratch/leishmania_scDNA_mix/results/bwa/"
bam_file_in = f"{bam_dir}/{encaps}.tagged.bam"
bam_file_out = f"{bam_dir}/{encaps}.cb.bam"


bam = pysam.AlignmentFile(bam_file_in, "rb")
out = pysam.AlignmentFile(bam_file_out, "wb", template=bam)

for read in bam:

    m = re.search(r'_CB:(.*)$', read.query_name)

    if m:
        barcode = m.group(1)

        read.query_name = read.query_name.split("_CB:")[0]
        read.set_tag("CB", barcode, value_type="Z")

    out.write(read)

bam.close()
out.close()

## run over all encaps
# for encaps in encaps1 encaps2 encaps3 encaps4; do sbatch /user/antwerpen/205/vsc20587/scratch/leishmania_scDNA_mix/bin/demux2_barcodes_BWA_addCBtag.py --encaps $encaps; done