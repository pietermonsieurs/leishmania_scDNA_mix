#!/usr/bin/env python3

## module load SciPy-bundle

## In total there are 8 files with the most dominant barcodes per fastq_file (R2), 
## but barcodes can be shared between files. This script merges the 8 files into one, 
## and sums the counts of shared barcodes. The output is a single file with the most
## dominant barcodes across all 8 fastq files, sorted by count.

import pandas as pd
import glob
import os


def merge_dominant_barcodes(input_dir, output_file):
    ## Get all files in the input directory
    files = glob.glob(os.path.join(input_dir, "*_dominant_barcodes.txt"))
    
    ## Initialize an empty DataFrame to store merged results
    merged_df = pd.DataFrame(columns=['barcode', 'count'])
        
    ## Loop through each file and merge counts. This is done by first merging the existing
    ## merged DataFrame with the new DataFrame from the current file, where there are now two
    ## 'count' columns (one from the merged DataFrame and one from the new DataFrame). We then
    ## sum these two 'count' columns to get the total count for each barcode, and drop the 
    ## temporary 'count_new' column.
    for file in files:
        df = pd.read_csv(file, sep='\t', header=None, names=['barcode', 'count'])
        merged_df = merged_df.merge(df, on='barcode', how='outer', suffixes=('', '_new')).fillna(0)
        merged_df['count'] = merged_df['count'] + merged_df['count_new']
        merged_df.drop(columns=['count_new'], inplace=True)
    
    ## sort by count in descending order
    merged_df.sort_values(by='count', ascending=False, inplace=True)
    
    ## filter out only those barcodes with a count > 10000
    merged_df = merged_df[merged_df['count'] > 10000]

    ## convert the count column to integer type
    merged_df['count'] = merged_df['count'].astype(int)

    return merged_df


## also create a merged file with every fastq file as one column, so we can check the 
## distribution of barcodes across the different fastq files. This is done by merging 
##the DataFrames from each file on the 'barcode' column, and keeping the 'count' columns 
## from each file as separate columns in the merged DataFrame. 
def merge_dominant_barcodes_detailed(input_dir, output_file):
    files = glob.glob(os.path.join(input_dir, "*_dominant_barcodes.txt"))
    merged_df = pd.DataFrame(columns=['barcode'])
    
    for file in files:
        df = pd.read_csv(file, sep='\t', header=None, names=['barcode', 'count'])
        print(df.head())  # Print the first few rows of the current file for debugging
        merged_df = merged_df.merge(df, on='barcode', how='outer', suffixes=('', '_new')).fillna(0)
        merged_df.rename(columns={'count': os.path.basename(file).replace('_dominant_barcodes.txt', '')}, inplace=True)
    
    ## only select those barcodes that have a summed count > 10000 across all files. Therefore, 
    ## create an additional column 'total_count' that sums the counts across all files for 
    ##each barcode, and filter on this column. Afterwrds, drop the 'total_count' column.
    merged_df['total_count'] = merged_df.drop(columns=['barcode']).sum(axis=1)
    merged_df = merged_df[merged_df['total_count'] > 10000]
    merged_df.drop(columns=['total_count'], inplace=True)   

    ## convert the count columns to integer type
    for col in merged_df.columns[1:]:  # skip the 'barcode' column
        merged_df[col] = merged_df[col].astype(int)

    return merged_df

def read_barcode_encapsulation_info(barcode_file):

    barcode_df = pd.read_csv(barcode_file, sep='\t', header=0)

    encaps1 = ['A1', 'A2', 'A3', 'B1', 'B2', 'B3']
    encaps2 = ['C1', 'C2', 'C3', 'D1', 'D2', 'D3']
    encaps3 = ['E1', 'E2', 'E3', 'F1', 'F2', 'F3']
    encaps4 = ['G1', 'G2', 'G3', 'H1', 'H2', 'H3']

    def assign_encapsulation(well):
        if any(x in well for x in encaps1):
            return "encaps1"
        elif any(x in well for x in encaps2):
            return "encaps2"
        elif any(x in well for x in encaps3):
            return "encaps3"
        elif any(x in well for x in encaps4):
            return "encaps4"
        else:
            return "unknown"

    barcode_df["encapsulation"] = barcode_df["well"].apply(assign_encapsulation)

    # optional: keep only relevant columns
    encapsulation_info = barcode_df[["seq", "encapsulation"]].rename(
        columns={"seq": "barcode1"}
    )

    print(encapsulation_info.head())

    return encapsulation_info



def add_encapsulation_info(merged_df, barcode_file):
    ## read in the barcode file and add the encapsulation per barcode
    encapsulation_df = read_barcode_encapsulation_info(barcode_file)

    ## extract the last barcode of the 4 barcode from the barcode column in merged_df
    ## by splitting on "_" and taking the last element of the resulting list
    merged_df['barcode1'] = merged_df['barcode'].apply(lambda x: x.split('_')[-1])

    ## merge the encapsulation info with the merged_df on the 'barcode' column
    merged_df = merged_df.merge(encapsulation_df, on='barcode1', how='left')
    print(merged_df.head())  # Print the first few rows of the merged DataFrame for debugging

    return merged_df
    



if __name__ == "__main__":
    input_directory = "/user/antwerpen/205/vsc20587/scratch/leishmania_scDNA_mix/results/demux/"
    barcode_file = '/user/antwerpen/205/vsc20587/scratch/leishmania_scDNA_atrandi/data/atrandi/atrandi_whitelist_barcodes.csv'

    ## define the output files
    output_file = f"{input_directory}/dominant_barcodes_merged.txt"
    output_file_detailed = f"{input_directory}/dominant_barcodes_merged_detailed.txt"

    ## merge the dominant barcodes from all files and add encapsulation info
    merged_df = merge_dominant_barcodes(input_directory, output_file)
    merged_df_detailed = merge_dominant_barcodes_detailed(input_directory, output_file_detailed)

    merged_df = add_encapsulation_info(merged_df, barcode_file)
    merged_df_detailed = add_encapsulation_info(merged_df_detailed, barcode_file)

    ## write to output file
    merged_df.to_csv(output_file, sep='\t', index=False)
    merged_df_detailed.to_csv(output_file_detailed, sep='\t', index=False)