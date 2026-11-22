# Figure 4. Test error on held-out compounds.
source("method/work-directory.R")
source("method/real-data-analysis/kinase-summaries.R")
source("method/visualization/plot-device.R")
source("method/visualization/kinase-figures.R")

errors <- readRDS("figures/Main-Figure-4/Main-Figure-4.rds")
folder <- work_directory("Main-Figure-4")
plot_kinase_errors(errors, file.path(folder, "Main-Figure-4.tex"))
