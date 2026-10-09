#!/usr/bin/env Rscript
## ============================================================
## Eenmalig uit te voeren op het HPC (NIET in de array job zelf!)
## Run dit interactief of als 1 losse (niet-array) job:
##   Rscript install_qdnaseqCRAM.R
## ============================================================
 
if (!requireNamespace("BiocManager", quietly = TRUE))
  install.packages("BiocManager", repos = "https://cloud.r-project.org")
 
BiocManager::install(c("QDNAseq", "QDNAseq.mm10"), update = FALSE, ask = FALSE)
 
if (!requireNamespace("Cairo", quietly = TRUE))
  install.packages("Cairo", repos = "https://cloud.r-project.org")
 
cat("Installatie voltooid.\n")