# Companion plot for Table 1.
source("figures/plot-device.R")
source("figures/simulation-figures.R")

weights <- readRDS("tables/Main-Table-1/plot/panels/source-information-100.rds")
folder <- file.path(Sys.getenv("TRANSAW_WORKDIR", "results"), "Main-Table-1", "plot", "panels")
dir.create(folder, recursive = TRUE, showWarnings = FALSE)
plot_source_sizes(weights, file.path(folder, "source-information-100.tex"))
