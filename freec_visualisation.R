#Control-Freec cnv visualization
library(dplyr)
library(tidyr)
library(plotly)
library(htmlwidgets)
library(ggplot2)

input_dir <- "/scratch/gent/vo/002/gvo00207/vsc52059/FREEC_all"

threshold <- 0.3

files <- list.files(
  path = input_dir,
  pattern = "_log2\\.txt$",
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

  # chromosome namen opschonen
  df$Chromosome <- sub("^chr", "", as.character(df$Chromosome))

  # verwijder NA en oneindige waarden
  df <- df[
    complete.cases(df) &
    is.finite(df$Log2Ratio) &
    is.finite(df$Log2MedianRatio),
  ]

  # volgorde chromosomen
  chromosome_order <- c(as.character(1:19), "X", "Y")

  chromosome_order <- chromosome_order[
    chromosome_order %in% unique(df$Chromosome)
  ]

  df$Chromosome <- factor(
    df$Chromosome,
    levels = chromosome_order
  )

  # midden van elk venster
  df$Position <- (df$Start + df$End) / 2

  # chromosome grenzen
  chr_boundaries <- aggregate(
    Position ~ Chromosome,
    data = df,
    max
  )

  chr_boundaries <- chr_boundaries[
    order(match(
      chr_boundaries$Chromosome,
      chromosome_order
    )),
  ]

  chr_offset <- c(
    0,
    cumsum(chr_boundaries$Position)[-nrow(chr_boundaries)]
  )

  names(chr_offset) <- chr_boundaries$Chromosome

  df$CumulativePosition <-
    df$Position +
    chr_offset[as.character(df$Chromosome)]

  chr_boundaries$CumulativePosition <-
    chr_boundaries$Position +
    chr_offset[as.character(chr_boundaries$Chromosome)]

  chr_boundaries$Midpoint <-
    (
      c(0, head(chr_boundaries$CumulativePosition, -1)) +
      chr_boundaries$CumulativePosition
    ) / 2

  # gain / neutral / loss
  df$CNV <- cut(
    df$Log2MedianRatio,
    breaks = c(-Inf, -threshold, threshold, Inf),
    labels = c("Loss", "Neutral", "Gain")
  )

  sample_name <- unique(df$Sample)

  p <- ggplot(df, aes(CumulativePosition, Log2Ratio)) +

    geom_point(
      aes(color = CNV),
      size = 0.4,
      alpha = 0.6
    ) +

    geom_point(
      aes(y = Log2MedianRatio),
      colour = "orange",
      size = 0.4
    ) +

    scale_color_manual(
      values = c(
        Loss = "red",
        Neutral = "black",
        Gain = "blue"
      )
    ) +

    scale_x_continuous(
      breaks = chr_boundaries$Midpoint,
      labels = chr_boundaries$Chromosome
    ) +

    geom_vline(
      xintercept = chr_boundaries$CumulativePosition,
      colour = "grey80",
      linewidth = 0.3
    ) +

    coord_cartesian(
      ylim = c(-2, 2)
    ) +

    labs(
      title = paste("FREEC CNV Profile -", sample_name),
      x = "Chromosome",
      y = "Log2 Ratio"
    ) +

    theme_bw() +

    theme(
      legend.position = "none",
      axis.text.x = element_text(
        angle = 90,
        hjust = 1
      )
    )

  outfile <- sub(
    "_log2\\.txt$",
    "_FREEC_plot.png",
    f
  )

  ggsave(
    filename = outfile,
    plot = p,
    width = 14,
    height = 5,
    dpi = 300
  )

  cat("Saved:", outfile, "\n")
}
plot_dir <- file.path(input_dir, "freec_plots")
dir.create(plot_dir, showWarnings = FALSE)

plots <- list.files(
  path = input_dir,
  pattern = "_FREEC_plot\\.png$",
  recursive = TRUE,
  full.names = TRUE
)
plots <- plots[dirname(plots) != plot_dir]

file.copy(plots, plot_dir, overwrite = TRUE)
cat("Done\n")