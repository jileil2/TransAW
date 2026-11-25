# Individual panel. Coefficient error with 100 observations per source.
source("figures/plot-device.R")
source("figures/simulation-figures.R")

errors <- readRDS("figures/Main-Figure-1/panels/coefficient-error-100.rds")
folder <- file.path(Sys.getenv("TRANSAW_WORKDIR", "results"), "Main-Figure-1", "panels")
dir.create(folder, recursive = TRUE, showWarnings = FALSE)
plot_simulation_errors(errors, file.path(folder, "coefficient-error-100.tex"))
