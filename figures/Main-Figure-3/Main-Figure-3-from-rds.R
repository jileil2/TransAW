# Figure 3. Test error on held-out compounds.
source("tables/Main-Table-1/kinase-summaries.R")
source("figures/plot-device.R")
source("figures/kinase-figures.R")

predictions <- readRDS("data/kinase-test-predictions.rds")
errors <- kinase_errors(predictions)
folder <- file.path(Sys.getenv("TRANSAW_WORKDIR", "results"), "Main-Figure-3")
dir.create(folder, recursive = TRUE, showWarnings = FALSE)
plot_kinase_errors(errors, file.path(folder, "Main-Figure-3.tex"))
