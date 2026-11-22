# Table 2. Average contribution of each source kinase.
source("method/work-directory.R")
source("method/real-data-analysis/kinase-summaries.R")
source("method/visualization/kinase-tables.R")

weights <- readRDS("tables/Main-Table-2/Main-Table-2.rds")
folder <- work_directory("Main-Table-2")
write_weight_table(weights, file.path(folder, "Main-Table-2"))
