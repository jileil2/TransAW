# Figure 3. Effective sample size by source compatibility.
source("figures/Main-Figure-1/fit-simulation.R")
source("figures/plot-device.R")
source("figures/simulation-figures.R")

weights <- simulation_fits(100, "weights")
folder <- work_directory("Main-Figure-3")
saveRDS(weights, file.path(folder, "Main-Figure-3.rds"))
plot_source_sizes(weights, file.path(folder, "Main-Figure-3.tex"))
