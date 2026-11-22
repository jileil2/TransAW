# Figure 3. Effective sample size by source compatibility.
source("method/simulation/fit-simulation.R")
source("method/visualization/plot-device.R")
source("method/visualization/simulation-figures.R")

weights <- simulation_fits(100, "weights")
folder <- work_directory("Main-Figure-3")
saveRDS(weights, file.path(folder, "Main-Figure-3.rds"))
plot_source_sizes(weights, file.path(folder, "Main-Figure-3.tex"))
