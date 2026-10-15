#!/usr/bin/env Rscript
#uitvoeren via Rscript install_freec.R

install.packages(
  c(
    "plotly",
    "htmlwidgets",
    "dplyr",
    "tidyr",
    "ggplot2"
  ),
  repos = "https://cloud.r-project.org"
)

cat("Installatie voltooid.\n")