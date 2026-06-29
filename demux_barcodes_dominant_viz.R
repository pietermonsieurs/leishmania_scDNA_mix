library(ggplot2)
library(ComplexHeatmap)
library(reshape2)

## parameter settings
data_dir = '/Users/pmonsieurs/programming/leishmania_scDNA_mix/results/demux/'
barcode_count_file = paste0(data_dir, 'dominant_barcodes_merged_detailed.txt')
barcode_df <- read.table(barcode_count_file, header=TRUE)

colnames(barcode_df)[-1] <- gsub("_MKDL2600063...1A_23HK37LT4", "", colnames(barcode_df)[-1])
colnames(barcode_df)[-1] <- gsub("_Undetermined_23HK37LT4", "", colnames(barcode_df)[-1])
head(barcode_df)
dim(barcode_df)

## create empty dataframe to store the overlap between the different samples. As
## column names, drop the first column (barcode) and last 2 columns (barcode1 and encapsulation)
overlap <- matrix(0, nrow = ncol(barcode_df) - 3, ncol = ncol(barcode_df) - 3)
colnames(overlap) <- colnames(barcode_df)[2:(ncol(barcode_df)-2)]
rownames(overlap) <- colnames(barcode_df)[2:(ncol(barcode_df)-2)]
head(overlap)
dim(overlap)
table(barcode_df$encapsulation)

## create a heatmap with the overlap between the different samples
combi = 0
for (sample1 in colnames(barcode_df)[2:(ncol(barcode_df) - 2)]) {
  print(sample1)
  for (sample2 in colnames(barcode_df)[2:(ncol(barcode_df) - 2)]) {
    print(sample2)
    combi = combi + 1
    overlap_count <- sum(barcode_df[[sample1]] > 0 & barcode_df[[sample2]] > 0)
    overlap[sample1, sample2] <- overlap_count
    print(paste("count combi", combi, sample1, sample2, overlap_count))
  }
}

## create a heatmap with the overlap between the different samples. Also show
## the number of overlapping barcodes
dist_mat <- as.dist(1 - (overlap / max(overlap)))
Heatmap(overlap,
        name = "Overlap",
        clustering_distance_rows = dist_mat,
        clustering_distance_columns = dist_mat,
        #col = colorRamp2(c(0, max(overlap)), c("white", "red")),
        cluster_rows = TRUE,
        cluster_columns = TRUE,
        show_row_names = TRUE,
        show_column_names = TRUE,
        cell_fun = function(j, i, x, y, width, height, fill) {
          grid.text(overlap[i, j], x, y)
        })


## create a heatmap with all barcode
Heatmap(log10(barcode_df[,2:(ncol(barcode_df)-2)]+1),
        name = "Barcode Count",
        #col = colorRamp2(c(0, max(barcode_df[,-1])), c("white", "red")),
        cluster_rows = TRUE,
        cluster_columns = TRUE,
        show_row_names = FALSE,
        show_column_names = TRUE)




## check the spread of the enxapsulation over the different libraries / samples
## using a stacked bar plot
barcode_long <- melt(
  barcode_df,
  id.vars = c("barcode", "barcode1", "encapsulation"),
  measure.vars = 2:11,
  variable.name = "sample",
  value.name = "count"
)

## counting all the barcode separately
ggplot(barcode_long, aes(x = sample, y = count, fill = encapsulation)) +
  geom_bar(stat = "identity", position = "stack") +
  theme_minimal() +
  labs(title = "Distribution of Encapsulation Types Across Samples",
       x = "Sample",
       y = "Count of Barcodes") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

## coverage per sample
head(barcode_long)


## same barplot, but count rather the number of unique barcode instead of taking
## the count of the barcode into account
barcode_long_unique <- barcode_long %>%
  group_by(sample, encapsulation) %>%
  summarise(unique_barcodes = sum(count > 0))

ggplot(barcode_long_unique, aes(x = sample, y = unique_barcodes, fill = encapsulation)) +
  geom_bar(stat = "identity", position = "stack") +
  theme_minimal() +
  labs(title = "Distribution of Unique Barcodes Across Samples",
       x = "Sample",
       y = "Number of Unique Barcodes") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))


## do coverage analysis

barcode_count_file = paste0(data_dir, 'dominant_barcodes_merged.txt')
barcode_df <- read.table(barcode_count_file, header=TRUE)

colnames(barcode_df)[-1] <- gsub("_MKDL2600063...1A_23HK37LT4", "", colnames(barcode_df)[-1])
colnames(barcode_df)[-1] <- gsub("_Undetermined_23HK37LT4", "", colnames(barcode_df)[-1])
head(barcode_df)
dim(barcode_df)

## plot densities based on the number of reads per barcode
ggplot(barcode_df, aes(x=log10(count))) + 
  geom_density(aes(color = encapsulation), size = 1) + 
  theme_bw() + 
  labs(title = "log10 count distribution per encapsulation",
       x = "log 10 counts per barcode",
       y = "density")

## count the number of 

## convert the number to a theoretical "average" coverage starting from a hypothetical 
## genome size of 35Mbp
barcode_df$coverage = (barcode_df$count*250)/35000000
## plot densities based on the number of reads per barcode
ggplot(barcode_df, aes(x=log10(coverage))) + 
  geom_density(aes(color = encapsulation), size = 1) + 
  theme_bw() + 
  labs(title = "Average coverage",
       x = "Average coverage for 35Mbp genome",
       y = "density") + 
  coord_cartesian(xlim=c(0,3))


## get some stats
for (encaps_id in seq(1,4)) {
  encaps = paste0("encaps", encaps_id)
  df_sub = barcode_df[barcode_df$encapsulation == encaps,]
  print(colSums(df_sub[,2:(ncol(df_sub)-2)]))
  
}



