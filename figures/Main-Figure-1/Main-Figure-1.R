# Figure 1. Coefficient error with 100 and 300 observations per source.
source("figures/Main-Figure-1/fit-simulation.R")
source("figures/plot-device.R")
source("figures/simulation-figures.R")

errors <- rbind(simulation_fits(100, "errors"), simulation_fits(300, "errors"))
folder <- file.path(Sys.getenv("TRANSAW_WORKDIR", "results"), "Main-Figure-1")
dir.create(folder, recursive = TRUE, showWarnings = FALSE)
saveRDS(errors, file.path(folder, "Main-Figure-1.rds"))
plot_source_sample_sizes(errors, file.path(folder, "Main-Figure-1.tex"))
