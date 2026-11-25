# Figure 2. Coefficient error with 300 observations per source.
source("figures/plot-device.R")
source("figures/simulation-figures.R")

errors <- readRDS("figures/Main-Figure-2/Main-Figure-2.rds")
folder <- file.path(Sys.getenv("TRANSAW_WORKDIR", "results"), "Main-Figure-2")
dir.create(folder, recursive = TRUE, showWarnings = FALSE)
plot_simulation_errors(errors, file.path(folder, "Main-Figure-2.tex"))
