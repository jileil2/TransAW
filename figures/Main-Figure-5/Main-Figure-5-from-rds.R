# Figure 5. Contributions from the nine source kinases.
source("work-directory.R")
source("tables/Main-Table-1/kinase-summaries.R")
source("figures/plot-device.R")
source("figures/kinase-figures.R")

weights <- readRDS("figures/Main-Figure-5/Main-Figure-5.rds")
folder <- work_directory("Main-Figure-5")
plot_kinase_weights(weights, file.path(folder, "Main-Figure-5.tex"))
