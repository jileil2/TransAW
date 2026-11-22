# Figure 5. Contributions from the nine source kinases.
source("method/real-data-analysis/fit-kinases.R")
source("method/real-data-analysis/kinase-summaries.R")
source("method/visualization/plot-device.R")
source("method/visualization/kinase-figures.R")

weights <- kinase_weights(kinase_fits("weights"))
folder <- work_directory("Main-Figure-5")
saveRDS(weights, file.path(folder, "Main-Figure-5.rds"))
plot_kinase_weights(weights, file.path(folder, "Main-Figure-5.tex"))
