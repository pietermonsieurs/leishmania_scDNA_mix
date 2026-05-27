#!/usr/bin/bash

module load SAMtools

## copy all fasta files to a single directory in the data folder
cd /user/antwerpen/205/vsc20587/scratch/leishmania_scDNA_mix/data/refgenomes/

## look for already download or high-quality reference genomes obtained from internal assembly 
## or from collaborators. If not available, download from TriTrypDB or NCBI.
cp /user/antwerpen/205/vsc20587/scratch/leishmania_cruzi/data/ref_genome/TcDm28cT2T.contigs.fa ./  # T. cruzi
cp /user/antwerpen/205/vsc20587/scratch/trypanosoma_nanopore/results/assembly_QC/manual_assembly.fasta ./ # T.b. gambiense homemade
cp /user/antwerpen/205/vsc20587/scratch/trypanosoma_nanopore/data/refgenomes/TriTrypDB-67_TbruceiTREU927_Genome.fasta ./ # T. brucei
cp /user/antwerpen/205/vsc20587/scratch/trypanosoma_sofi_10x/data/refgenome/glasgow/tco_il3000_v0.47.fasta ./ # T. congolense IL3000
cp /user/antwerpen/205/vsc20587/scratch/leishmania_susl/data/refgenomes/TriTrypDB-57_LbraziliensisMHOMBR75M2904_2019_Genome.fasta ./ # L. braziliensis

## download Peruvian L. braziliensis reference genome from NCBI: https://www.ncbi.nlm.nih.gov/datasets/genome/?taxon=5681
ll GCA_055690285.1_ASM5569028v1_genomic.fna # L. braziliensis MHOMPE75M2904, Peruvian strain, from NCBI

## create separate directory for competitve mapping
mkdir competitive_mapping
cd competitive_mapping

## concatenate all reference genomes into a single fasta file
cat ../*.fasta ../*.fa ../*.fna > competitive_refgenome.fasta

## index the competitive reference genome for BWA
bwa index competitive_refgenome.fasta


