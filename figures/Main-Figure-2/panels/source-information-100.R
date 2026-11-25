# Figure 2(b). Effective sample size by source compatibility.
source("figures/Main-Figure-1/fit-simulation.R")
source("figures/plot-device.R")
source("figures/simulation-figures.R")

weights <- simulation_fits(100, "weights")
folder <- file.path(Sys.getenv("TRANSAW_WORKDIR", "results"), "Main-Figure-2", "panels")
dir.create(folder, recursive = TRUE, showWarnings = FALSE)
saveRDS(weights, file.path(folder, "source-information-100.rds"))
plot_source_sizes(weights, file.path(folder, "source-information-100.tex"))
