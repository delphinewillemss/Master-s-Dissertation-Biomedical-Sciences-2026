#!/usr/bin/env Rscript
## ============================================================
## QDNAseq analyse voor 1 BAM-bestand (mm10)
## Wordt aangeroepen vanuit QDNAseq.job met:
##   Rscript mm10_qdnaseqCRAM.R <bamfile> <outdir> <binsize>
## ============================================================

args <- commandArgs(trailingOnly = TRUE)

bamfile <- args[1]
outdir  <- args[2]
binsize <- as.numeric(args[3])

if (!dir.exists(outdir)) dir.create(outdir, recursive = TRUE)

suppressMessages({
  library(QDNAseq)
  library(QDNAseq.mm10)
  library(Cairo)
})

sample_name <- tools::file_path_sans_ext(basename(bamfile))
cat("Start analyse:", sample_name, "\n")

bins <- getBinAnnotations(binSize = binsize, genome = "mm10")

readCounts <- binReadCounts(bins, bamfiles = bamfile)

readCountsFiltered <- applyFilters(readCounts, residual = TRUE, blacklist = TRUE)
readCountsFiltered <- estimateCorrection(readCountsFiltered)

## chromosoom X behouden, Y blijft uitgesloten
readCountsFiltered <- applyFilters(readCountsFiltered, residual = TRUE,
                                    blacklist = TRUE, chromosomes = "Y")

copyNumbers <- correctBins(readCountsFiltered)
copyNumbersNormalized <- normalizeBins(copyNumbers)
copyNumbersSmooth <- smoothOutlierBins(copyNumbersNormalized)

copyNumbersSegmented <- segmentBins(copyNumbersSmooth, transformFun = "sqrt")
copyNumbersSegmented <- normalizeSegmentedBins(copyNumbersSegmented)

png_file <- file.path(outdir, paste0(sample_name, "_segmentation.png"))

CairoPNG(filename = png_file, width = 4000, height = 3000, res = 300)
plot(copyNumbersSegmented, ylim = c(-1.5, 1.5))
dev.off()

cat("Output:", png_file, "\n")