# Table 2. Full-sample kinase analysis.
source("tables/Main-Table-2/source-contributions.R")
weights <- readRDS("tables/Main-Table-2/Main-Table-2.rds")
folder <- file.path(Sys.getenv("TRANSAW_WORKDIR", "results"), "Main-Table-2")
dir.create(folder, recursive = TRUE, showWarnings = FALSE)
write_source_table(weights, file.path(folder, "Main-Table-2"))
