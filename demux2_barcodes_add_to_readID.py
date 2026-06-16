#!/usr/bin/env python3

#SBATCH --ntasks=1 --cpus-per-task=1
#SBATCH --time=70:50:00
#SBATCH --job-name=count
#SBATCH -A ap_itg_mpu

## parse the barcode from read2 and add this to the readID of read1 
## and read2

import gzip
import argparse

def extract_barcode(seq):
    return (
        seq[0:8] + "_" +
        seq[12:20] + "_" +
        seq[24:32] + "_" +
        seq[36:44]
    )

## main
def main():

    ## parser command line arguments with flags for the different inputs
    parser = argparse.ArgumentParser(description="Add barcode ID to the fastq read ID for both R1 and R2 files.")
    parser.add_argument("--fastq_file", help="R1 file which uses as basis to form the other file names. The R2 file should be in the same directory and have the same name but with R2 instead of R1.")
    args = parser.parse_args()

    ## extract fastq-file
    fastq_file_R1 = args.fastq_file

    ## create the file names based on the input file name
    fastq_file_R2 = fastq_file_R1.replace("R1", "R2")
    fastq_file_R2_with_bc = fastq_file_R1.replace("R1", "R2_with_bc")
    fastq_file_R1_out = fastq_file_R1.replace(".fq.gz", ".tagged.fq.gz")
    fastq_file_R2_out = fastq_file_R2.replace(".fq.gz", ".tagged.fq.gz")

    count = 0

    with gzip.open(fastq_file_R1, "rt") as r1_in, \
        gzip.open(fastq_file_R2, "rt") as r2_in, \
        gzip.open(fastq_file_R1_out, "wt") as r1_out, \
        gzip.open(fastq_file_R2_out, "wt") as r2_out, \
        gzip.open(fastq_file_R2_with_bc, "rt") as r2_with_bc_in:

        while True:

            count = count + 1
            if count % 100000 == 0:
                print(f"Processed {count} reads...")

            h1 = r1_in.readline()
            if not h1:
                break

            s1 = r1_in.readline()
            p1 = r1_in.readline()
            q1 = r1_in.readline()

            h2 = r2_in.readline()
            s2 = r2_in.readline()
            p2 = r2_in.readline()
            q2 = r2_in.readline()

            h3 = r2_with_bc_in.readline()
            s3 = r2_with_bc_in.readline()
            p3 = r2_with_bc_in.readline()
            q3 = r2_with_bc_in.readline()

            ## barcode is only present in the file R2_with_bc.fastq.gz, so we extract it from there
            barcode = extract_barcode(s3.strip())

            ## create new header by adding the barcode to the read ID (first part of the header)
            read_id = h1.split()[0]
            new_header = f"{read_id}_CB:{barcode}\n"

            r1_out.write(new_header)
            r1_out.write(s1)
            r1_out.write(p1)
            r1_out.write(q1)

            r2_out.write(new_header)
            r2_out.write(s2)
            r2_out.write(p2)
            r2_out.write(q2)


if __name__ == "__main__":
    main()

## run for all R1 files

# cd /user/antwerpen/205/vsc20587/scratch/leishmania_scDNA_mix/results/demux
# for dir in PTA* Und*; do
#     for fastq_file_R1 in ${PWD}/${dir}/*R1.fq.gz; do
#         echo $fastq_file_R1
#         sbatch /user/antwerpen/205/vsc20587/scratch/leishmania_scDNA_mix/bin/demux2_barcodes_add_to_readID.py --fastq_file ${fastq_file_R1}
#     done
# done
# cd /user/antwerpen/205/vsc20587/scratch/leishmania_scDNA_mix/results/demux/concat/
# for fastq_file_R1 in ${PWD}/*R1.fq.gz; do sbatch /user/antwerpen/205/vsc20587/scratch/leishmania_scDNA_mix/bin/demux2_barcodes_add_to_readID.py --fastq_file ${fastq_file_R1}; done



# for dir in PTA* Und*; do
#     [ -d "$dir" ] || continue

#     find "$dir" -name "*.tagged.fq.gz" | while read -r file; do
#     # find "$dir" -name "*R1.fq.gz" | while read -r file; do
#         echo ${file}
#         if gzip -t "$file" 2>/dev/null; then
#             echo "OK        $file"
#         else
#             echo "CORRUPTED $file"
#         fi
#     done
# done