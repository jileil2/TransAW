# Figure 2(b). Effective sample size by source compatibility.
source("figures/plot-device.R")
source("figures/simulation-figures.R")

weights <- readRDS("figures/Main-Figure-2/panels/source-information-100.rds")
folder <- file.path(Sys.getenv("TRANSAW_WORKDIR", "results"), "Main-Figure-2", "panels")
dir.create(folder, recursive = TRUE, showWarnings = FALSE)
plot_source_sizes(weights, file.path(folder, "source-information-100.tex"))
