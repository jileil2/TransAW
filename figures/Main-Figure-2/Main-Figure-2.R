# Figure 2. Coefficient error with 300 observations per source.
source("method/simulation/fit-simulation.R")
source("method/visualization/plot-device.R")
source("method/visualization/simulation-figures.R")

errors <- simulation_fits(300, "errors")
folder <- work_directory("Main-Figure-2")
saveRDS(errors, file.path(folder, "Main-Figure-2.rds"))
plot_simulation_errors(errors, file.path(folder, "Main-Figure-2.tex"))
