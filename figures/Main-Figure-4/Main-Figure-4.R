# Figure 4. Test error on held-out compounds.
source("method/real-data-analysis/fit-kinases.R")
source("method/real-data-analysis/kinase-summaries.R")
source("method/visualization/plot-device.R")
source("method/visualization/kinase-figures.R")

errors <- kinase_errors(kinase_fits("predictions"))
folder <- work_directory("Main-Figure-4")
saveRDS(errors, file.path(folder, "Main-Figure-4.rds"))
plot_kinase_errors(errors, file.path(folder, "Main-Figure-4.tex"))
