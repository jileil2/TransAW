# Supplementary Figure S1. Source-weight penalty sensitivity at n_k = 100.
source("figures/plot-device.R")
source("figures/Supplement-Figure-S1/plot-sensitivity.R")

records <- readRDS("figures/Supplement-Figure-S1/Supplement-Figure-S1.rds")
folder <- file.path(Sys.getenv("TRANSAW_WORKDIR", "results"), "Supplement-Figure-S1")
dir.create(folder, recursive = TRUE, showWarnings = FALSE)
plot_sensitivity(records, 100, file.path(folder, "Supplement-Figure-S1.tex"))
