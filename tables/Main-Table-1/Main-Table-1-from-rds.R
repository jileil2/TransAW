# Table 1. Mean test error across scaffold splits.
source("method/work-directory.R")
source("method/real-data-analysis/kinase-summaries.R")
source("method/visualization/kinase-tables.R")

errors <- readRDS("tables/Main-Table-1/Main-Table-1.rds")
folder <- work_directory("Main-Table-1")
write_error_table(errors, file.path(folder, "Main-Table-1"))
