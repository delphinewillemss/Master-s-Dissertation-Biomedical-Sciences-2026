library(ggplot2)

input_dir <- "/scratch/gent/vo/002/gvo00207/vsc52059/FREEC_all"

output_dir <- file.path(input_dir, "hmmcopy_plots")

dir.create(output_dir, showWarnings = FALSE)

files <- list.files(
  path = input_dir,
  pattern = "_ratio\\.txt$",
  recursive = TRUE,
  full.names = TRUE
)

for (f in files) {

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

  if (nrow(Y) == 0)
    next

  Y$log2Ratio <- log2(Y$Ratio)

  sample_name <- basename(f)
  sample_name <- sub("_sorted.bam_ratio.txt", "", sample_name)

  p <- ggplot(
    Y,
    aes(x = Start/1e6, y = log2Ratio)
  ) +
    geom_point(size = 1.5) +
    geom_line() +
    theme_bw() +
    labs(
      title = sample_name,
      x = "Position on chrY (Mb)",
      y = "log2(Ratio)"
    )

  ggsave(
    filename = file.path(
      output_dir,
      paste0(sample_name, "_chrY.png")
    ),
    plot = p,
    width = 8,
    height = 4,
    dpi = 300
  )
}

cat("Finished\n")