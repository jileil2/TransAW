# Companion plot for Table 1.
source("figures/Main-Figure-1/fit-simulation.R")
source("figures/plot-device.R")
source("figures/simulation-figures.R")

weights <- simulation_fits(100, "weights")
folder <- file.path(Sys.getenv("TRANSAW_WORKDIR", "results"), "Main-Table-1", "plot", "panels")
dir.create(folder, recursive = TRUE, showWarnings = FALSE)
saveRDS(weights, file.path(folder, "source-information-100.rds"))
plot_source_sizes(weights, file.path(folder, "source-information-100.tex"))
