write_source_table <- function(weights, stem) {
  order <- c("P38beta", "MAPKAPK3", "P38gamma", "P38delta", "FYN", "YES", "LCK", "Aurora-A", "AKT1")
  labels <- c("p38$\\beta$", "MK3", "p38$\\gamma$", "p38$\\delta$", "FYN", "YES", "LCK", "Aurora A", "AKT1")
  weights <- weights[match(order, weights$enzyme), ]
  shares <- 100 * weights[c("trans_aw", "trans_lasso", "riw_tl")]
  write.csv(data.frame(source = order, shares), paste0(stem, ".csv"), row.names = FALSE)
  rows <- sprintf("%s & %.2f & %.2f & %.2f \\\\", labels,
                  shares$trans_aw, shares$trans_lasso, shares$riw_tl)
  writeLines(c("\\begin{tabular}{lrrr}", "Source & Trans-AW & Trans-LASSO & RIW-TL \\\\",
               rows, "\\end{tabular}"), paste0(stem, ".tex"))
}
