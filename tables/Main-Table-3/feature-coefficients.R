write_feature_table <- function(fit, stem) {
  environments <- read.csv("data/selected-environments.csv")
  labels <- c("Substituted imidazole junction (bit 204)", "Pyridine-ring segment (bit 19)",
              "Aromatic carbon environment (bit 64)")
  beta <- fit$coefficients[environments$bit, c("trans_aw", "target_only")]
  coverage <- with(environments, sprintf("%d/%d (%.1f%%)", fragment_compounds,
                                         bit_compounds, 100 * environment_coverage))
  result <- data.frame(bit = environments$bit, environment = labels,
                       trans_aw = beta[, 1], target_only = beta[, 2], coverage = coverage)
  write.csv(result, paste0(stem, ".csv"), row.names = FALSE)
  rows <- sprintf("%s & %.2f & %.2f & %s \\\\", labels, beta[, 1], beta[, 2],
                  gsub("%", "\\%", coverage, fixed = TRUE))
  writeLines(c("\\begin{tabular}{lrrr}",
               "Molecular environment & Trans-AW & Target-only LASSO & Coverage \\\\",
               rows, "\\end{tabular}"), paste0(stem, ".tex"))
}
