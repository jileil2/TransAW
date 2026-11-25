# Figure 1. Coefficient error with 100 observations per source.
source("figures/Main-Figure-1/fit-simulation.R")
source("figures/plot-device.R")
source("figures/simulation-figures.R")

errors <- simulation_fits(100, "errors")
folder <- file.path(Sys.getenv("TRANSAW_WORKDIR", "results"), "Main-Figure-1")
dir.create(folder, recursive = TRUE, showWarnings = FALSE)
saveRDS(errors, file.path(folder, "Main-Figure-1.rds"))
plot_simulation_errors(errors, file.path(folder, "Main-Figure-1.tex"))
