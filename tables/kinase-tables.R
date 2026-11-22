write_kinase_tables <- function(errors, weights, out) {
  completed <- colSums(!is.na(errors))
  means <- colMeans(errors, na.rm = TRUE)
  se <- vapply(errors, sd, numeric(1), na.rm = TRUE) / sqrt(completed)
  mae <- data.frame(method = names(errors), splits = completed, mean_mae = means, mcse = se)
  write.csv(mae, file.path(out, "table-1-test-error.csv"), row.names = FALSE)
  rows <- sprintf("%s & %.2f (%.2f) \\\\", mae$method, means, se)
  writeLines(rows, file.path(out, "table-1-rows.tex"))

  shares <- t(vapply(weights, function(w) {
    100 * colMeans(w[c("trans_aw", "trans_lasso", "riw")], na.rm = TRUE)
  }, numeric(3)))
  write.csv(data.frame(source = rownames(shares), shares),
            file.path(out, "table-2-source-weights.csv"), row.names = FALSE)
  cell <- function(x) ifelse(x > 0 & x < .005, "$<0.01$", sprintf("%.2f", x))
  rows <- sprintf("%s & %s & %s & %s \\\\", source_labels, cell(shares[, 1]),
                  cell(shares[, 2]), cell(shares[, 3]))
  writeLines(rows, file.path(out, "table-2-rows.tex"))
}
