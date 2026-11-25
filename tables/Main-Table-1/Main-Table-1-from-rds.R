# Table 1. Mean test error across scaffold splits.
source("tables/Main-Table-1/kinase-summaries.R")
source("tables/kinase-tables.R")

predictions <- readRDS("data/kinase-test-predictions.rds")
errors <- kinase_errors(predictions)
folder <- file.path(Sys.getenv("TRANSAW_WORKDIR", "results"), "Main-Table-1")
dir.create(folder, recursive = TRUE, showWarnings = FALSE)
write_error_table(errors, file.path(folder, "Main-Table-1"))
