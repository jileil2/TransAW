# Table 3. Full-sample kinase analysis.
source("tables/Main-Table-3/source-weights.R")
weights <- readRDS("tables/Main-Table-3/Main-Table-3.rds")
folder <- file.path(Sys.getenv("TRANSAW_WORKDIR", "results"), "Main-Table-3")
dir.create(folder, recursive = TRUE, showWarnings = FALSE)
write_source_table(weights, file.path(folder, "Main-Table-3"))
