#!/usr/bin/env bash

#SBATCH --ntasks=1 --cpus-per-task=4
#SBATCH --time=70:50:00
#SBATCH --job-name=CB_tag
#SBATCH -A ap_itg_mpu

module load Pysam

/user/antwerpen/205/vsc20587/scratch/leishmania_scDNA_mix/bin/demux2_barcodes_BWA_addCBtag.py --encaps ${encaps}

## run over all encaps
# for encaps in encaps1 encaps2 encaps3 encaps4; do sbatch --export=encaps=${encaps} /user/antwerpen/205/vsc20587/scratch/leishmania_scDNA_mix/bin/demux2_barcodes_BWA_addCBtag.slurm; done