# Table 2. Average contribution of each source kinase.
source("tables/Main-Table-1/fit-kinases.R")
source("tables/Main-Table-1/kinase-summaries.R")
source("tables/kinase-tables.R")

weights <- kinase_weights(kinase_fits("weights"))
folder <- work_directory("Main-Table-2")
saveRDS(weights, file.path(folder, "Main-Table-2.rds"))
write_weight_table(weights, file.path(folder, "Main-Table-2"))
