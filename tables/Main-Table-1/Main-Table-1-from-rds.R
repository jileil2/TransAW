# Table 1. Category effective sample size, grouped by source count.
source("figures/simulation-figures.R")
source("tables/Main-Table-1/borrowing-table.R")

weights <- readRDS("tables/Main-Table-1/Main-Table-1.rds")
folder <- file.path(Sys.getenv("TRANSAW_WORKDIR", "results"), "Main-Table-1")
dir.create(folder, recursive = TRUE, showWarnings = FALSE)
write_borrowing_table(weights, file.path(folder, "Main-Table-1"))
