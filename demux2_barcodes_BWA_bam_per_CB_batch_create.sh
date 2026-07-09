## get from the dominant barcodes file those barcodes that belong to encaps3 and 
## split them into batches of 1000 barcodes each, then create a BWA bam file for each batch of barcodes
encaps=encaps3

## define some parameters + put the batch size (number of barcodes per batch) in a variable
src_dir=/user/antwerpen/205/vsc20587/scratch/leishmania_scDNA_mix/results/demux/
batch_dir=${src_dir}/batches_${encaps}
dominant_file=${src_dir}/dominant_barcodes_merged.txt
batch_size=1000

## create the batch directory if it does not exist yet
mkdir -p ${batch_dir}

## select barcodes that belong to the encaps3 (present in column 4), and create a file that 
## belongs to the encaps3 barcodes only
awk -v encaps=${encaps} 'NR>1 && $4==encaps {print $1}' ${dominant_file} > ${batch_dir}/dominant_barcodes_${encaps}.txt

## the text file contains now all barcodes that belong to the encaps3, but they are ordered
## by the number of reads per barcode (column 2), which would mean that the first 1000 barcodes
## would be the most abundant barcodes, and the last 1000 barcodes would be the least abundant barcodes.
## so do randomisation of the order of the barcodes in the file, so that the batches will contain a random selection of barcodes
shuf ${batch_dir}/dominant_barcodes_${encaps}.txt > ${batch_dir}/dominant_barcodes_${encaps}_shuffled.txt

## split the shuffled barcodes file into batches of 1000 barcodes each. Do call the batches
## like 01, 02, 03, etc. so that they are sorted in the correct order when doing a ls command
split -l ${batch_size} --suffix-length=2 -d  ${batch_dir}/dominant_barcodes_${encaps}_shuffled.txt ${batch_dir}/dominant_barcodes_${encaps}_batch_
