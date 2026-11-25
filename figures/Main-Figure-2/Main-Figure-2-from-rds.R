# Figure 2. Coefficient estimation and borrowing across sources.
library(ggplot2)
library(grid)
source("figures/plot-device.R")
source("figures/simulation-figures.R")
source("figures/Main-Figure-2/plot-composite.R")

errors <- readRDS("figures/Main-Figure-2/panels/coefficient-error-300.rds")
weights <- readRDS("figures/Main-Figure-2/panels/source-information-100.rds")
folder <- file.path(Sys.getenv("TRANSAW_WORKDIR", "results"), "Main-Figure-2")
dir.create(folder, recursive = TRUE, showWarnings = FALSE)
plot_simulation_composite(errors, weights, file.path(folder, "Main-Figure-2.tex"))
