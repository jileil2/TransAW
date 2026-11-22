write_error_table <- function(errors, stem) {
  completed <- colSums(!is.na(errors))
  means <- colMeans(errors, na.rm = TRUE)
  se <- vapply(errors, sd, numeric(1), na.rm = TRUE) / sqrt(completed)
  mae <- data.frame(method = names(errors), splits = completed, mean_mae = means, mcse = se)
  write.csv(mae, paste0(stem, ".csv"), row.names = FALSE)
  rows <- sprintf("%s & %.2f (%.2f) \\\\", mae$method, means, se)
  writeLines(c("\\begin{tabular}{lr}", "Method & Mean MAE \\\\", rows, "\\end{tabular}"),
             paste0(stem, ".tex"))
}

write_weight_table <- function(weights, stem) {
  shares <- t(vapply(weights, function(w) {
    100 * colMeans(w[c("trans_aw", "trans_lasso", "riw")], na.rm = TRUE)
  }, numeric(3)))
  write.csv(data.frame(source = rownames(shares), shares),
            paste0(stem, ".csv"), row.names = FALSE)
  cell <- function(x) ifelse(x > 0 & x < .005, "$<0.01$", sprintf("%.2f", x))
  rows <- sprintf("%s & %s & %s & %s \\\\", source_labels, cell(shares[, 1]),
                  cell(shares[, 2]), cell(shares[, 3]))
  writeLines(c("\\begin{tabular}{lrrr}", "Source & Trans-AW & Trans-LASSO & RIW-TL \\\\", rows, "\\end{tabular}"),
             paste0(stem, ".tex"))
}
