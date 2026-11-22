# Figure 1. Coefficient error with 100 observations per source.
source("work-directory.R")
source("figures/plot-device.R")
source("figures/simulation-figures.R")

errors <- readRDS("figures/Main-Figure-1/Main-Figure-1.rds")
folder <- work_directory("Main-Figure-1")
plot_simulation_errors(errors, file.path(folder, "Main-Figure-1.tex"))
