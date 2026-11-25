# Format the simulation table in manuscript order.
write_borrowing_table <- function(weights, stem) {
  sizes <- effective_sample_size(weights)
  rows <- aggregate(share ~ m + h + method + group, sizes, function(x) {
    c(mean = mean(x), mcse = sd(x) / sqrt(length(x)), replications = length(x))
  })
  summary <- cbind(rows[1:4], as.data.frame(rows$share))
  stopifnot(all(summary$replications == 200))

  write.csv(summary, paste0(stem, ".csv"), row.names = FALSE)

  methods <- c("Trans-AW", "Trans-LASSO", "RIW-TL")
  groups <- c("compatible", "mildly compatible", "non-compatible")
  lines <- c(
    "\\begin{table}[!htbp]",
    "\\resultstableformat",
    "\\renewcommand{\\tablefont}{\\fontsize{8.5}{9.5}\\selectfont}",
    "\\renewcommand{\\arraystretch}{1.0}",
    "\\setlength{\\tabcolsep}{3pt}",
    "\\tbl{Mean category effective sample size at \\(n_k=100\\) across source counts \\(m\\) and heterogeneity levels \\(h\\).}{%",
    "\\begin{minipage}{.92\\linewidth}",
    "\\begin{tabular*}{\\linewidth}{@{\\extracolsep{\\fill}}rrlrrr@{}}",
    "\\noalign{\\hrule height .6pt\\vskip 3pt}",
    "$m$ & $h$ & Method & Compatible & Mildly compatible & Non-compatible \\\\",
    "\\noalign{\\vskip 3pt\\hrule height .3pt\\vskip 3pt}"
  )
  for (m in c(5, 10, 15, 20)) {
    if (m != 5) lines <- c(lines, "\\noalign{\\vskip 3pt\\hrule height .3pt\\vskip 3pt}")
    for (h in c(2, 4, 6)) {
      if (h != 2) lines <- c(lines, "\\noalign{\\vskip 1.5pt}")
      for (method in methods) {
        values <- vapply(groups, function(group) {
          row <- summary[summary$h == h & summary$m == m &
                         summary$method == method & summary$group == group, ]
          stopifnot(nrow(row) == 1)
          sprintf("%.1f (%.1f)", row$mean, row$mcse)
        }, character(1))
        first <- method == methods[1]
        # The two 1.5pt gaps add 3pt to each nine-row m group.
        m_label <- if (first && h == 2) sprintf("\\multirow{9}{*}[-1.5pt]{%d}", m) else ""
        h_label <- if (first) sprintf("\\multirow{3}{*}{%d}", h) else ""
        fields <- c(m_label, h_label, method, values)
        lines <- c(lines, paste0(paste(fields, collapse = " & "), " \\\\"))
      }
    }
  }
  lines <- c(lines,
    "\\noalign{\\vskip 3pt\\hrule height .6pt}",
    "\\end{tabular*}",
    "\\resultstablenote{Parentheses give Monte Carlo standard errors based on 200 replications. Category effective sample size is calculated within each replication from the normalized source weights.}",
    "\\end{minipage}}",
    "\\label{tab:highdim-category-neff}",
    "\\end{table}"
  )
  writeLines(lines, paste0(stem, ".tex"))
}
