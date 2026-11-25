# Table 1. Mean test error across scaffold splits.
source("tables/Main-Table-1/fit-kinases.R")
source("tables/Main-Table-1/kinase-summaries.R")
source("tables/kinase-tables.R")

errors <- kinase_errors(kinase_fits("predictions"))
folder <- file.path(Sys.getenv("TRANSAW_WORKDIR", "results"), "Main-Table-1")
dir.create(folder, recursive = TRUE, showWarnings = FALSE)
saveRDS(errors, file.path(folder, "Main-Table-1.rds"))
write_error_table(errors, file.path(folder, "Main-Table-1"))
