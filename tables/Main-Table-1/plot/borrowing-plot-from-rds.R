# Companion plot for Table 1.
source("figures/plot-device.R")
source("figures/simulation-figures.R")

weights <- readRDS("tables/Main-Table-1/plot/borrowing-plot.rds")
folder <- file.path(Sys.getenv("TRANSAW_WORKDIR", "results"), "Main-Table-1", "plot")
dir.create(folder, recursive = TRUE, showWarnings = FALSE)
plot_source_sizes(weights, file.path(folder, "borrowing-plot.tex"))
