# Each interval describes Monte Carlo uncertainty in a mean across replications.
mean_interval <- function(x) {
  estimate <- mean(x)
  margin <- 1.96 * sd(x) / sqrt(length(x))
  c(mean = estimate, lower = max(0, estimate - margin), upper = estimate + margin)
}

effective_sample_size <- function(weights) {
  # Normalize each method's fitted source weights within its replication.
  total <- with(weights, ave(mass, rep, m, h, method, FUN = sum))
  stopifnot(all(is.finite(total)), all(total > 0))
  weights$share <- weights$mass / total
  aggregate(share ~ rep + m + h + method + group, weights, function(w) {
    group_weight <- sum(w)
    if (group_weight == 0) return(0)
    # Normalize before squaring so negligible weights do not underflow.
    group_weight / sum((w / group_weight)^2 / 100)
  })
}

simulation_plot <- function(rows, category = FALSE) {
  methods <- c("Trans-AW", "Trans-LASSO", "RIW-TL", "Target LASSO")
  rows$method <- factor(rows$method, levels = methods)
  if (category) rows <- rows[order(rows$method, rows$m, rows$h), ]
  rows$h <- factor(rows$h, levels = c(2, 4, 6), labels = paste0("$h = ", c(2, 4, 6), "$"))
  types <- if (category) c("solid", "longdash", "dotted", "solid") else c("solid", "dashed", "dotdash", "solid")
  g <- ggplot2::ggplot(rows, ggplot2::aes(m, mean, color = method, shape = method, linetype = method)) +
    ggplot2::geom_errorbar(ggplot2::aes(ymin = lower, ymax = upper), width = .6, linewidth = .45) +
    ggplot2::geom_line(linewidth = .75) +
    ggplot2::scale_x_continuous(breaks = c(5, 10, 15, 20)) +
    ggplot2::scale_color_manual(values = c("magenta", "indianred1", "deepskyblue", "grey25"), name = NULL) +
    ggplot2::scale_shape_manual(values = c(16, 17, 15, 18), name = NULL) +
    ggplot2::scale_linetype_manual(values = types, name = NULL)
  if (category) {
    g + ggplot2::geom_point(size = 2.2, stroke = .7) + ggplot2::facet_grid(group ~ h) +
      ggplot2::labs(x = "Number of sources, $m$", y = "Category effective sample size, $E_g$") +
      ggplot2::theme_bw(base_size = 10.5) + ggplot2::theme(legend.position = "bottom",
        panel.spacing = grid::unit(.55, "lines"), strip.text.y = ggplot2::element_text(size = 8.5))
  } else {
    g + ggplot2::geom_point(size = 2) + ggplot2::facet_wrap(~ h) +
      ggplot2::labs(x = "Number of sources", y = "$\\|\\hat{\\boldsymbol{\\beta}}-\\boldsymbol{\\beta}_0\\|_2^2$") +
      ggplot2::theme_bw(base_size = 11) + ggplot2::theme(legend.position = "bottom")
  }
}

save_simulation_plot <- function(plot, path, height) {
  body <- tempfile(fileext = ".tex")
  tikzDevice::tikz(body, standAlone = FALSE, width = 6.4, height = height,
                   sanitize = FALSE, packages = c(getOption("tikzLatexPackages"),
                   "\\usepackage{mathpazo}", "\\usepackage{amsmath}", "\\usepackage{xcolor}"))
  print(plot)
  grDevices::dev.off()
  writeLines(c("\\documentclass[tikz,border=0pt]{standalone}", "\\usepackage{amsmath,newpxtext,newpxmath}",
               "\\begin{document}", readLines(body), "\\end{document}"), path)
  compile_plot(path)
}

plot_simulation_errors <- function(errors, path) {
  rows <- aggregate(coef_error ~ m + h + method, errors, mean_interval)
  summary <- cbind(rows[1:3], as.data.frame(rows$coef_error))
  save_simulation_plot(simulation_plot(summary),
                       path, 4.1)
}

# Compare source sample sizes on a shared vertical scale.
plot_source_sample_sizes <- function(errors, path) {
  rows <- aggregate(coef_error ~ n + m + h + method, errors, mean_interval)
  summary <- cbind(rows[1:4], as.data.frame(rows$coef_error))
  write.csv(summary, file.path(dirname(path), "coefficient-error.csv"), row.names = FALSE)
  summary$n <- factor(summary$n, levels = c(100, 300),
                      labels = c("$n_k = 100$", "$n_k = 300$"))
  plot <- simulation_plot(summary) +
    ggplot2::facet_grid(n ~ h) +
    ggplot2::labs(x = "Number of sources, $m$") +
    ggplot2::theme(strip.text.y = ggplot2::element_text(size = 10),
                   panel.spacing.y = grid::unit(.8, "lines"))
  save_simulation_plot(plot, path, height = 4.8)
}

plot_source_sizes <- function(weights, path) {
  sizes <- effective_sample_size(weights)
  rows <- aggregate(share ~ m + h + method + group, sizes, mean_interval)
  summary <- cbind(rows[1:4], as.data.frame(rows$share))
  summary$group <- factor(summary$group, c("compatible", "mildly compatible", "non-compatible"),
                          c("Compatible", "Mildly compatible", "Non-compatible"))
  save_simulation_plot(simulation_plot(summary, category = TRUE),
                       path, 5.5)
}
