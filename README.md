# leishmania_scDNA_mix

## Input data 
* fastq files of the atrandi output are stored in the directory /user/antwerpen/205/vsc20587/aitg_data/jcdujardin/MRC_singlecell_Atrandi_20260506/01.RawData/. The library contains 4 libraries, each with a mixture of 8 different strains. Those 4 libraries are distributed over two different Illumina lanes, so we get 2 pairs of fastq files (R1 and R2) for each library. The 4 libraries are named as follows: PTA01UDI5, PTA02UDI6, PTA03UDI7, PTA04UDI8. The one where indexes could not be correctly read, are stored as Undetermined
    * the first barcode gives an indication on which pair of strains are mixed in that encapsulated droplet. This barcode can be used to filter out the four different encapsulated droplet mixtures, and defined which reference genomes to use for mapping
* | Encapsulation | Strain A | Strain B | Wells of round 1 barcoding |
    |---|---|---|---|
    | SPC-#1 | T. cruzi MBM1466 cl3 | T. b. gambiense LiTat 1.3 | A1-B3 |
    | SPC-#2 | T. cruzi DM28c | T. b. brucei AnTat 1.1 | C1-D3 |
    | SPC-#3 | T. congolense MSOROM7 | L. peruviana LCA08 cl2 | E1-F3 |
    | SPC-#4 | T. cruzi THY4326 cl1 | L. braziliensis LC2043 cl8 | G1-H3 |
* `demux_explorative_2.py` is an exploratory script that reads up to 1 million R2 records from a gzipped FASTQ file, builds 4-part barcodes from fixed positions in each read, and writes a sorted barcode count table to `results/demux/` for quick inspection of barcode composition.