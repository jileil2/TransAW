# Table 1. Refit the simulation with 100 observations per source.
source("figures/Main-Figure-1/fit-simulation.R")
source("figures/simulation-figures.R")
source("tables/Main-Table-1/borrowing-table.R")

weights <- simulation_fits(100, "weights")
folder <- file.path(Sys.getenv("TRANSAW_WORKDIR", "results"), "Main-Table-1")
dir.create(folder, recursive = TRUE, showWarnings = FALSE)
saveRDS(weights, file.path(folder, "Main-Table-1.rds"))
write_borrowing_table(weights, file.path(folder, "Main-Table-1"))
