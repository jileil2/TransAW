# Run from the repository root. By default use the saved manuscript fits.
source("analysis/kinase-summaries.R")
source("tables/kinase-tables.R")
source("figures/plot-device.R")
source("figures/kinase-figures.R")
source("figures/simulation-figures.R")

args <- commandArgs(trailingOnly = TRUE)
results <- if (length(args)) args[1] else "results"
out <- if (length(args) >= 2L) args[2] else "output/manuscript"
dir.create(out, recursive = TRUE, showWarnings = FALSE)
read_result <- function(name) read.csv(file.path(results, paste0(name, ".csv.gz")))
errors <- kinase_errors(read_result("kinase-predictions"))
weights <- kinase_weights(read_result("kinase-weights"))
write_kinase_tables(errors, weights, out)
write_kinase_figures(errors, weights, out)
write_simulation_figures(read_result("simulation-errors"), read_result("simulation-weights"), out)
