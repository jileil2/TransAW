# Table 4. Full-sample kinase analysis.
source("tables/Main-Table-4/feature-coefficients.R")
source("tables/Main-Table-3/fit-full-sample.R")
fit <- fit_full_sample()
folder <- file.path(Sys.getenv("TRANSAW_WORKDIR", "results"), "Main-Table-4")
dir.create(folder, recursive = TRUE, showWarnings = FALSE)
write_feature_table(fit, file.path(folder, "Main-Table-4"))
