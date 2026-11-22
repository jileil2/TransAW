# Figure 5. Contributions from the nine source kinases.
source("tables/Main-Table-1/fit-kinases.R")
source("tables/Main-Table-1/kinase-summaries.R")
source("figures/plot-device.R")
source("figures/kinase-figures.R")

weights <- kinase_weights(kinase_fits("weights"))
folder <- work_directory("Main-Figure-5")
saveRDS(weights, file.path(folder, "Main-Figure-5.rds"))
plot_kinase_weights(weights, file.path(folder, "Main-Figure-5.tex"))
