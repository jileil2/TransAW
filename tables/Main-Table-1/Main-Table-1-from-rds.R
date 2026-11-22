# Table 1. Mean test error across scaffold splits.
source("work-directory.R")
source("tables/Main-Table-1/kinase-summaries.R")
source("tables/kinase-tables.R")

errors <- readRDS("tables/Main-Table-1/Main-Table-1.rds")
folder <- work_directory("Main-Table-1")
write_error_table(errors, file.path(folder, "Main-Table-1"))
