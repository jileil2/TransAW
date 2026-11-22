# Figure 5. Contributions from the nine source kinases.
source("method/work-directory.R")
source("method/real-data-analysis/kinase-summaries.R")
source("method/visualization/plot-device.R")
source("method/visualization/kinase-figures.R")

weights <- readRDS("figures/Main-Figure-5/Main-Figure-5.rds")
folder <- work_directory("Main-Figure-5")
plot_kinase_weights(weights, file.path(folder, "Main-Figure-5.tex"))
