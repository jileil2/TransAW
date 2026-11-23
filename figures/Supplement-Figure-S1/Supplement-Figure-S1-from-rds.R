# Supplementary Figure S1. Source-weight penalty sensitivity at n_k = 100.
source("work-directory.R")
source("figures/plot-device.R")
source("figures/Supplement-Figure-S1/plot-sensitivity.R")

records <- readRDS("figures/Supplement-Figure-S1/Supplement-Figure-S1.rds")
folder <- work_directory("Supplement-Figure-S1")
plot_sensitivity(records, 100, file.path(folder, "Supplement-Figure-S1.tex"))
