# Supplementary Figure S1. Source-weight penalty sensitivity at n_k = 100.
source("figures/plot-device.R")
source("figures/Supplement-Figure-S1/plot-sensitivity.R")
source("figures/Supplement-Figure-S1/fit-sensitivity.R")

records <- fit_sensitivity(100)
folder <- file.path(Sys.getenv("TRANSAW_WORKDIR", "results"), "Supplement-Figure-S1")
dir.create(folder, recursive = TRUE, showWarnings = FALSE)
saveRDS(records, file.path(folder, "Supplement-Figure-S1.rds"))
plot_sensitivity(records, 100, file.path(folder, "Supplement-Figure-S1.tex"))
