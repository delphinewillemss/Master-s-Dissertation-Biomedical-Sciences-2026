library(dplyr)
input_dir <- "/scratch/gent/vo/002/gvo00207/vsc52059/FREEC_all"

files <- list.files(
  path = input_dir,
  pattern = "_ratio\\.txt$",
  recursive = TRUE,
  full.names = TRUE
)

results <- lapply(files, function(f){

  df <- read.table(
    f,
    header = TRUE,
    sep = "\t",
    stringsAsFactors = FALSE
  )

  Y <- subset(
    df,
    Chromosome == "Y" & Ratio > 0
  )

  sample_name <- basename(f)
  sample_name <- sub("sorted.bam_ratio.txt", "", sample_name)

  if(nrow(Y) == 0){

    return(
      data.frame(
        Sample = sample_name,
        N_bins = 0,
        Median_Ratio = NA,
        Mean_Ratio = NA,
        Median_log2Ratio = NA,
        Mean_log2Ratio = NA
      )
    )
  }

  data.frame(
    Sample = sample_name,
    N_bins = nrow(Y),
    Median_Ratio = median(Y$Ratio),
    Mean_Ratio = mean(Y$Ratio),
    Median_log2Ratio = median(log2(Y$Ratio)),
    Mean_log2Ratio = mean(log2(Y$Ratio))
  )
})

results_df <- do.call(rbind, results) 

write.table(
  results_df,
  "chrY_summary.txt",
  sep = "\t",
  quote = FALSE,
  row.names = FALSE
)

cat("Finished\n")