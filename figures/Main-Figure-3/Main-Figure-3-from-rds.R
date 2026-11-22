# Figure 3. Effective sample size by source compatibility.
source("work-directory.R")
source("figures/plot-device.R")
source("figures/simulation-figures.R")

weights <- readRDS("figures/Main-Figure-3/Main-Figure-3.rds")
folder <- work_directory("Main-Figure-3")
plot_source_sizes(weights, file.path(folder, "Main-Figure-3.tex"))
