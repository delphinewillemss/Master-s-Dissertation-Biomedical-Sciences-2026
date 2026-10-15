input_dir <- "/scratch/gent/vo/002/gvo00207/vsc52059/FREEC_all"

window_size <- 1000000

files <- list.files(
  path = input_dir,
  pattern = "_ratio\\.txt$",
  recursive = TRUE,
  full.names = TRUE
)

for (f in files) {

  cat("Processing:", basename(f), "\n")

  df <- read.table(
    f,
    header = TRUE,
    sep = "\t"
  )

  sample_name <- sub("_ratio\\.txt$", "", basename(f))

  df$Sample <- sample_name
  df$End <- df$Start + window_size - 1
  df$Log2Ratio <- log2(df$Ratio)
  df$Log2MedianRatio <- log2(df$MedianRatio)

  df2 <- df[, c(
    "Sample",
    "Chromosome",
    "Start",
    "End",
    "Ratio",
    "MedianRatio",
    "Log2Ratio",
    "Log2MedianRatio"
  )]

  outfile <- sub(
    "_ratio\\.txt$",
    "_log2.txt",
    f
  )

  write.table(
    df2,
    outfile,
    sep = "\t",
    quote = FALSE,
    row.names = FALSE
  )
}