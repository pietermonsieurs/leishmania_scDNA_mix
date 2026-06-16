## create output directory
cd /user/antwerpen/205/vsc20587/scratch/leishmania_scDNA_mix/data/refgenomes/
mkdir -p encapsulations

## create reference genome index for BWA per encapsulation
cat TcDm28cT2T.contigs.fa manual_assembly.fasta > encapsulations/encaps1.fasta
cat TcDm28cT2T.contigs.fa TriTrypDB-67_TbruceiTREU927_Genome.fasta > encapsulations/encaps2.fasta
cat tco_il3000_v0.47.fasta GCA_055690285.1_ASM5569028v1_genomic.fna > encapsulations/encaps3.fasta
cat TcDm28cT2T.contigs.fa TriTrypDB-57_LbraziliensisMHOMBR75M2904_2019_Genome.fasta > encapsulations/encaps4.fasta

## index reference genomes for BWA
module load BWA
bwa index encapsulations/encaps1.fasta
bwa index encapsulations/encaps2.fasta
bwa index encapsulations/encaps3.fasta
bwa index encapsulations/encaps4.fasta


