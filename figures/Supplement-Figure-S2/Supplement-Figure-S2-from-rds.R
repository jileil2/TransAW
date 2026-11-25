# Supplementary Figure S2. Source-weight penalty sensitivity at n_k = 300.
source("figures/plot-device.R")
source("figures/Supplement-Figure-S1/plot-sensitivity.R")

records <- readRDS("figures/Supplement-Figure-S2/Supplement-Figure-S2.rds")
folder <- file.path(Sys.getenv("TRANSAW_WORKDIR", "results"), "Supplement-Figure-S2")
dir.create(folder, recursive = TRUE, showWarnings = FALSE)
plot_sensitivity(records, 300, file.path(folder, "Supplement-Figure-S2.tex"))
