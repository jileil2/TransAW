# Figure 2(a). Coefficient error with 300 observations per source.
source("figures/plot-device.R")
source("figures/simulation-figures.R")

errors <- readRDS("figures/Main-Figure-2/panels/coefficient-error-300.rds")
folder <- file.path(Sys.getenv("TRANSAW_WORKDIR", "results"), "Main-Figure-2", "panels")
dir.create(folder, recursive = TRUE, showWarnings = FALSE)
plot_simulation_errors(errors, file.path(folder, "coefficient-error-300.tex"))
