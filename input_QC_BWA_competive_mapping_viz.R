library(ggplot2)

data_dir = '/Users/pmonsieurs/programming/leishmania_scDNA_mix/results/demux/competive_mapping/'
stat_files = list.files(data_dir, pattern="*_stats.txt")

stats = do.call(rbind, lapply(stat_files, function(file) {
  df = read.table(paste0(data_dir, file), header=FALSE, sep="\t")
  colnames(df) = c("chrom", "length", "mapped_reads", "dummy")
  df$sample = gsub("_stats.txt", "", file)
  print(df)
  return(df)
}))

## assigns species
stats$species = "Tbb" # default to Tbrucei
stats$species[grep("^chr", stats$chrom)]= "Tbg" # gambiense inhouse simply starts with chr
stats$species[grep("tco", stats$chrom)] = "Tco" # Tcongolense
stats$species[grep("JBRILI0", stats$chrom)] = "Lper" # Leishmania peruviana
stats$species[grep("TcDm28", stats$chrom)] = "Tcru" # Leishmania major
stats$species[grep("LbrM", stats$chrom)] = "Lbra" # Leishmania braziliensis

## simplify the sample names
stats$sample <- gsub("_MKDL2600063..-1A_23HK37LT4", "", stats$sample) 
stats$sample <- gsub("_Undetermined_23HK37LT4", "", stats$sample)
unique(stats$sample)

## create stacked barplot based on the "mapped reads" column, and colour per
## species
ggplot(stats, aes(x=sample, y=mapped_reads, fill=species)) +
  geom_bar(stat="identity") +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) +
  labs(x="Library", y="Mapped Reads", title="Competitive Mapping of scDNA-seq data")

