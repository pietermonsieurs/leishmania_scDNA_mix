# leishmania_scDNA_mix

## Input data 
* Overview input data & general stats
    * check whether the required amount of data and reads had been delivered by the sequencing facility: [input_check_size.sh](input_check_size.sh)
    * fastq files of the atrandi output are stored in the directory /user/antwerpen/205/vsc20587/aitg_data/jcdujardin/MRC_singlecell_Atrandi_20260506/01.RawData/. The library contains 4 libraries, each with a mixture of 8 different strains. Those 4 libraries are distributed over two different Illumina lanes, so we get 2 pairs of fastq files (R1 and R2) for each library. The 4 libraries are named as follows: PTA01UDI5, PTA02UDI6, PTA03UDI7, PTA04UDI8. The one where indexes could not be correctly read, are stored as Undetermined
        * the first barcode gives an indication on which pair of strains are mixed in that encapsulated droplet. This barcode can be used to filter out the four different encapsulated droplet mixtures, and defined which reference genomes to use for mapping
    * | Encapsulation | Strain A | Strain B | Wells of round 1 barcoding |
        |---|---|---|---|
        | SPC-#1 | T. cruzi MBM1466 cl3 | T. b. gambiense LiTat 1.3 | A1-B3 |
        | SPC-#2 | T. cruzi DM28c | T. b. brucei AnTat 1.1 | C1-D3 |
        | SPC-#3 | T. congolense MSOROM7 | L. peruviana LCA08 cl2 | E1-F3 |
        | SPC-#4 | T. cruzi THY4326 cl1 | L. braziliensis LC2043 cl8 | G1-H3 |
    * `demux_explorative_2.py` is an exploratory script that reads up to 1 million R2 records from a gzipped FASTQ file, builds 4-part barcodes from fixed positions in each read, and writes a sorted barcode count table to `results/demux/` for quick inspection of barcode composition.
* scripts with competitive mapping:
    * `input_QC_BWA_competive_refgenome.sh`
        * collects relevant Trypanosoma and Leishmania reference genomes into one folder
        * concatenates all FASTA files into one `competitive_refgenome.fasta`
        * builds the BWA index for competitive mapping
    * `input_QC_BWA_competive_mapping.slurm`
        * takes one raw R1 FASTQ (`fastq_file`) as input and derives a sample prefix
        * truncates to the first 10 million reads for a quick QC mapping run
        * maps reads against the combined reference with BWA-MEM
        * converts, sorts, and indexes BAM files with SAMtools
        * writes `idxstats` output per sample to `*_stats.txt`
        * can be launched in batch for all R1 FASTQ files via the commented `find ... | sbatch ...` loop
    * `input_QC_BWA_competive_mapping_viz.R`
        * reads all `*_stats.txt` files from the competitive mapping results folder
        * assigns each contig to a species label based on contig-name patterns
        * simplifies sample names and generates a stacked bar plot of mapped reads per library and species

## demultiplexing
* split all the reads per encapsulation based on the first barcode in the R2 reads
    * [demux2_barcodes_split_encapsulation.py](demux2_barcodes_split_encapsulation.py): starts from a list of dominant barcodes (dominant_barcodes_merged.txt) and create per sequencing library a list of read IDs per encapsulation. This list is used in the accompanying script to split the reads per encapsulation [demux2_barcodes_split_encapsulation.slurm](demux2_barcodes_split_encapsulation.slurm) to split up the reads per encapsulation using the seqtk tool, which has as output a fastq file for each encapsulation, containing all reads that have the same first barcode in the R2 read. For the R2 fastq file this contains both a fastq file with and without the barcode (_with_bc.fq.gz)
    * add for each fastq file the R2-derived barcode to the read ID in all fastq files, so that we can make a per-barcode (= single cell bam file) for each cell using [demux2_barcodes_add_to_readID.py](demux2_barcodes_add_to_readID.py), and write this per library
    * over all libraries, concatenate the fastq files and make one fastq file per encapsulation in the concat directory [demux2_barcodes_concat_fastq_files.sh](demux2_barcodes_concat_fastq_files.sh)
* Run BWA
    * create reference genomes for the different settings of mixed strains, based on the first barcode in the R2 reads
        * combine the two strains per encapsulation and create a reference genome for each encapsulation (= containing 2 strains)
        * [demux2_barcodes_BWA_refgenomes.sh](demux2_barcodes_BWA_refgenomes.sh) creates the reference genomes for the 4 different encapsulations, and builds the BWA index for each of them
    * run BWA and map all reads per encapsulation against the corresponding reference genome, using [demux2_barcodes_BWA.slurm](demux2_barcodes_BWA.slurm)
    * add the CB tag to the BAM files, using [demux2_barcodes_BAM_addCBtag.slurm](demux2_barcodes_BAM_add_CB_tag.slurm) and the corresponding python script [demux2_barcodes_BAM_addCBtag.py](demux2_barcodes_BAM_addCBtag.py). This script parses the cellular barcode from the fastq file and adds it to the BAM file as a CB tag. The output is a BAM file per encapsulation, with the CB tag added to each read.
    