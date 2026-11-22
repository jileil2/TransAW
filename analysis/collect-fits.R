# Combine a complete rerun into the same four files as results/.
out <- "output/refitted-results"
dir.create(out, recursive = TRUE, showWarnings = FALSE)
write_result <- function(x, name) {
  write.csv(x, gzfile(file.path(out, paste0(name, ".csv.gz"))), row.names = FALSE)
}
kinase <- lapply(sprintf("output/kinase-fits/split-%03d.rds", 1:100), readRDS)
write_result(do.call(rbind, lapply(kinase, "[[", "predictions")), "kinase-predictions")
write_result(do.call(rbind, lapply(kinase, "[[", "weights")), "kinase-weights")

design <- expand.grid(n = c(100, 300), m = c(5, 10, 15, 20), h = c(2, 4, 6), rep = 1:200)
paths <- with(design, sprintf("output/simulation-fits/n%d-m%d-h%d-rep%03d.rds", n, m, h, rep))
fits <- lapply(paths, readRDS)
write_result(do.call(rbind, lapply(fits, "[[", "errors")), "simulation-errors")
write_result(do.call(rbind, lapply(fits[design$n == 100], "[[", "weights")), "simulation-weights")
