# Figure 1. Coefficient error with 100 and 300 observations per source.
source("figures/plot-device.R")
source("figures/simulation-figures.R")

errors <- readRDS("figures/Main-Figure-1/Main-Figure-1.rds")
folder <- file.path(Sys.getenv("TRANSAW_WORKDIR", "results"), "Main-Figure-1")
dir.create(folder, recursive = TRUE, showWarnings = FALSE)
plot_source_sample_sizes(errors, file.path(folder, "Main-Figure-1.tex"))
