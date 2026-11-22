# Figure 2. Coefficient error with 300 observations per source.
source("work-directory.R")
source("figures/plot-device.R")
source("figures/simulation-figures.R")

errors <- readRDS("figures/Main-Figure-2/Main-Figure-2.rds")
folder <- work_directory("Main-Figure-2")
plot_simulation_errors(errors, file.path(folder, "Main-Figure-2.tex"))
