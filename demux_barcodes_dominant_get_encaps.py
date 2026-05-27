#!/usr/bin/env python3

## module load SciPy-bundle

import os
import pandas as pd
import glob


def read_barcode_encapsulation_info(barcode_file):

    ## read in the barcode but only select the first 24 rows, as those 
    ## are the ones that are used in the experiment
    barcode_df = pd.read_csv(barcode_file, sep='\t', header=0)
    barcode_df = barcode_df.head(24)

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

    ## print the full encapsulation info for debugging, so not the first and last
    ## few rows, but the full dataframe, to check if the encapsulation info is correct
    print(encapsulation_info.to_string())  # Print the full encapsulation info for debugging
    # sys.exit()

    return encapsulation_info



def add_encapsulation_info(merged_df, barcode_file):
    ## read in the barcode file and add the encapsulation per barcode
    encapsulation_df = read_barcode_encapsulation_info(barcode_file)

    ## extract the last barcode of the 4 barcode from the barcode column in merged_df
    ## by splitting on "_" and taking the last element of the resulting list
    print(merged_df.head())  # Print the first few rows of merged_df for debugging
    
    merged_df['barcode1'] = merged_df['barcode'].apply(lambda x: x.split('_')[-1])

    ## merge the encapsulation info with the merged_df on the 'barcode' column
    merged_df = merged_df.merge(encapsulation_df, on='barcode1', how='left')
    print(merged_df.head())  # Print the first few rows of the merged DataFrame for debugging

    return merged_df
    



if __name__ == "__main__":
    input_directory = "/user/antwerpen/205/vsc20587/scratch/leishmania_scDNA_mix/results/demux/"
    barcode_file = '/user/antwerpen/205/vsc20587/scratch/leishmania_scDNA_atrandi/data/atrandi/atrandi_whitelist_barcodes.csv'

    ## create empty dataframe to store the encapsulation info for all the demux files
    all_encapsulation_info = pd.DataFrame()

    ## loop over the individual demux files in the input directory, read them in as dataframes, 
    ## and add the encapsulation info to each of them
    for filename in os.listdir(input_directory):
        if filename.endswith("_dominant_barcodes.txt"):

            ## read in file and change the column names
            file_path = os.path.join(input_directory, filename)
            print(f"Processing file: {file_path}")
            merged_df = pd.read_csv(file_path, sep='\t')
            merged_df.columns = ['barcode', 'count']

            merged_df_with_encapsulation = add_encapsulation_info(merged_df, barcode_file)
            print(merged_df_with_encapsulation.head())  # Print the first few rows of the final DataFrame for debugging

            ## get summary of the encapsulation info per library and write it to a new file
            summary_df = merged_df_with_encapsulation.groupby('encapsulation').size().reset_index(name='count')

            ## add the summary_df info for this file to the all_encapsulation_info dataframe as a new 
            ## column with the name of the library (extracted from the filename)
            library_name = filename.split("_")[0]  # Assuming the library name is the first part of the filename
            summary_df = summary_df.rename(columns={'count': library_name})
            if all_encapsulation_info.empty:
                all_encapsulation_info = summary_df
            else:
                all_encapsulation_info = all_encapsulation_info.merge(summary_df, on='encapsulation', how='outer')

    
    ## write the all_encapsulation_info dataframe to a new file
    all_summary_file_path = os.path.join(input_directory, "all_libraries_encapsulation_summary.txt")
    all_encapsulation_info.to_csv(all_summary_file_path, sep='\t', index=False)
    print(f"All encapsulation summary written to: {all_summary_file_path}") 