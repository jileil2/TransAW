write_error_table <- function(errors, stem) {
  completed <- colSums(!is.na(errors))
  means <- colMeans(errors, na.rm = TRUE)
  se <- vapply(errors, sd, numeric(1), na.rm = TRUE) / sqrt(completed)
  rmse <- data.frame(method = names(errors), splits = completed, mean_rmse = means, mcse = se)
  write.csv(rmse, paste0(stem, ".csv"), row.names = FALSE)
  rows <- sprintf("%s & %.2f (%.2f) \\\\", rmse$method, means, se)
  writeLines(c("\\begin{tabular}{lr}", "Method & Mean RMSE \\\\", rows, "\\end{tabular}"),
             paste0(stem, ".tex"))
}
