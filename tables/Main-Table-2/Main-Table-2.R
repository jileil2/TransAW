# Table 2. Average contribution of each source kinase.
source("method/real-data-analysis/fit-kinases.R")
source("method/real-data-analysis/kinase-summaries.R")
source("method/visualization/kinase-tables.R")

weights <- kinase_weights(kinase_fits("weights"))
folder <- work_directory("Main-Table-2")
saveRDS(weights, file.path(folder, "Main-Table-2.rds"))
write_weight_table(weights, file.path(folder, "Main-Table-2"))
