library(ggplot2)

sample = 'scDNA_AT_01'

for (sample_id in 1:2) {
  sample = paste0('scDNA_AT_0', sample_id)
  count_file = paste0('/Users/pmonsieurs/programming/leishmania_scDNA_atrandi/results/qc/kneeplots/', sample, '_barcode_counts.txt')
  count_data = read.table(count_file)
  colnames(count_data) = c('barcode', 'count')        
  
  ## put a minimum on the number of reads per cell to reduce the number of rows
  ## and add the order to the data frame
  min_count = 10
  sum(count_data$count > min_count)
  count_data = count_data[count_data$count > min_count,]
  count_data$order_pos = seq(1,nrow(count_data))
  count_data$sample = sample
  head(count_data)
  
  if (sample_id == 1) {
    count_data_all = count_data
  }else{
    count_data_all = rbind.data.frame(count_data_all, count_data)
  }
}


knee_plot <- ggplot(data = count_data_all, aes(x = order_pos, y = count)) + 
  geom_line(aes(color = sample), linewidth = 1.2) +  # Increase line width in the plot
  theme_bw() + 
  coord_cartesian(xlim = c(1, 60000)) +  # Limit X-axis to 60000, starting from 1 for log scale
  scale_x_log10(labels = scales::trans_format("log10", scales::math_format(10^.x))) +  # X-axis as integers
  scale_y_log10() + 
  # facet_wrap(~ sample, ncol = 3) + 
  guides(color = guide_legend(override.aes = list(size = 5))) +  # Increase line width in legend
  labs(x = "Rank order (log 10)", y = "reads per cell (log10)") +  # Update axis labels
  theme(
    plot.title = element_text(size = 24),
    strip.text = element_text(size = 18),  # Increase facet wrap title size
    axis.text.x = element_text(size = 14), # Increase x-axis text size
    axis.text.y = element_text(size = 14), # Increase y-axis text size
    legend.title = element_text(size = 20), 
    legend.text = element_text(size = 20),
    axis.title.x = element_text(size = 15),  # Increase x-axis title font size
    axis.title.y = element_text(size = 15),  # Increase y-axis title font size
  ) + 
  geom_hline(yintercept = 10000, linetype="dashed", color="gray", linewidth=2) + 
  geom_hline(yintercept = 50000, linetype="dotted", color="gray", linewidth=2) + 
    geom_vline(xintercept = 2500, linetype="dashed", color="gray", linewidth=2)

knee_plot

kneeplot_file = paste0(out_dir, 'kneeplot.png')
ggsave(width = 16,
       height = 9,
       plot = knee_plot,
       file = kneeplot_file)


## make boxplot of the amount of reads per cell
ggplot(data = count_data_all, aes(x=sample, y=log10(count))) + 
  geom_violin(aes(fill=sample)) + 
  theme_bw()


## check the percentage of reads that is in a "cell" and which one is not

## what is the minimum number of reads per cell if we take the first 2500 cells, 
## as this is the theoretical amount of cells added
sort(count_data_all[count_data_all$sample == "scDNA_AT_01",]$count, decreasing=TRUE)[2500]
sort(count_data_all[count_data_all$sample == "scDNA_AT_02",]$count, decreasing=TRUE)[2500]

## what if we put the minimum coverage to 10000
min_coverage = 50000

sum(count_data_all[count_data_all$sample == "scDNA_AT_01",]$count > min_coverage)
sum(count_data_all[which(count_data_all[count_data_all$sample == "scDNA_AT_01",]$count > min_coverage),]$count)

sum(count_data_all[count_data_all$sample == "scDNA_AT_02",]$count > min_coverage)
sum(count_data_all[which(count_data_all[count_data_all$sample == "scDNA_AT_02",]$count > min_coverage),]$count)

