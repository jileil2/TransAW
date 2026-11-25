# Figure 2. Test error on held-out compounds.
source("tables/Main-Table-2/fit-kinases.R")
source("tables/Main-Table-2/kinase-summaries.R")
source("figures/plot-device.R")
source("figures/kinase-figures.R")

errors <- kinase_errors(kinase_fits("predictions"))
folder <- file.path(Sys.getenv("TRANSAW_WORKDIR", "results"), "Main-Figure-2")
dir.create(folder, recursive = TRUE, showWarnings = FALSE)
saveRDS(errors, file.path(folder, "Main-Figure-2.rds"))
plot_kinase_errors(errors, file.path(folder, "Main-Figure-2.tex"))
