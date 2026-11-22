# Figure 4. Test error on held-out compounds.
source("work-directory.R")
source("tables/Main-Table-1/kinase-summaries.R")
source("figures/plot-device.R")
source("figures/kinase-figures.R")

errors <- readRDS("figures/Main-Figure-4/Main-Figure-4.rds")
folder <- work_directory("Main-Figure-4")
plot_kinase_errors(errors, file.path(folder, "Main-Figure-4.tex"))
