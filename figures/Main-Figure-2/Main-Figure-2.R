# Figure 2. Coefficient error with 300 observations per source.
source("figures/Main-Figure-1/fit-simulation.R")
source("figures/plot-device.R")
source("figures/simulation-figures.R")

errors <- simulation_fits(300, "errors")
folder <- work_directory("Main-Figure-2")
saveRDS(errors, file.path(folder, "Main-Figure-2.rds"))
plot_simulation_errors(errors, file.path(folder, "Main-Figure-2.tex"))
