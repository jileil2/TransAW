# Figure 2. Coefficient error with 300 observations per source.
source("method/work-directory.R")
source("method/visualization/plot-device.R")
source("method/visualization/simulation-figures.R")

errors <- readRDS("figures/Main-Figure-2/Main-Figure-2.rds")
folder <- work_directory("Main-Figure-2")
plot_simulation_errors(errors, file.path(folder, "Main-Figure-2.tex"))
