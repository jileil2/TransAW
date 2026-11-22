# Table 1. Mean test error across scaffold splits.
source("method/real-data-analysis/fit-kinases.R")
source("method/real-data-analysis/kinase-summaries.R")
source("method/visualization/kinase-tables.R")

errors <- kinase_errors(kinase_fits("predictions"))
folder <- work_directory("Main-Table-1")
saveRDS(errors, file.path(folder, "Main-Table-1.rds"))
write_error_table(errors, file.path(folder, "Main-Table-1"))
