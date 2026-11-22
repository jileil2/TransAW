# Figure 1. Coefficient error with 100 observations per source.
source("method/simulation/fit-simulation.R")
source("method/visualization/plot-device.R")
source("method/visualization/simulation-figures.R")

errors <- simulation_fits(100, "errors")
folder <- work_directory("Main-Figure-1")
saveRDS(errors, file.path(folder, "Main-Figure-1.rds"))
plot_simulation_errors(errors, file.path(folder, "Main-Figure-1.tex"))
