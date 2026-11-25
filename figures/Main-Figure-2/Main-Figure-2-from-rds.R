# Figure 2. Effective sample size by source compatibility.
source("figures/plot-device.R")
source("figures/simulation-figures.R")

weights <- readRDS("figures/Main-Figure-2/Main-Figure-2.rds")
folder <- file.path(Sys.getenv("TRANSAW_WORKDIR", "results"), "Main-Figure-2")
dir.create(folder, recursive = TRUE, showWarnings = FALSE)
plot_source_sizes(weights, file.path(folder, "Main-Figure-2.tex"))
