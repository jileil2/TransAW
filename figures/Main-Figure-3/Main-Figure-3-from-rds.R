# Figure 3. Effective sample size by source compatibility.
source("method/work-directory.R")
source("method/visualization/plot-device.R")
source("method/visualization/simulation-figures.R")

weights <- readRDS("figures/Main-Figure-3/Main-Figure-3.rds")
folder <- work_directory("Main-Figure-3")
plot_source_sizes(weights, file.path(folder, "Main-Figure-3.tex"))
