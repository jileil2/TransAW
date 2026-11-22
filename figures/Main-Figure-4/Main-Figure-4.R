# Figure 4. Test error on held-out compounds.
source("tables/Main-Table-1/fit-kinases.R")
source("tables/Main-Table-1/kinase-summaries.R")
source("figures/plot-device.R")
source("figures/kinase-figures.R")

errors <- kinase_errors(kinase_fits("predictions"))
folder <- work_directory("Main-Figure-4")
saveRDS(errors, file.path(folder, "Main-Figure-4.rds"))
plot_kinase_errors(errors, file.path(folder, "Main-Figure-4.tex"))
