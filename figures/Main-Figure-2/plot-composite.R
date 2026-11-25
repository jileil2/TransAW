# Draw both simulation panels with their original means and Monte Carlo intervals.
plot_simulation_composite <- function(errors, weights, path) {
  stopifnot(all(errors$n == 300))

  error_rows <- aggregate(coef_error ~ m + h + method, errors, mean_interval)
  error_summary <- cbind(error_rows[1:3], as.data.frame(error_rows$coef_error))
  source_sizes <- effective_sample_size(weights)
  size_rows <- aggregate(share ~ m + h + method + group, source_sizes, mean_interval)
  size_summary <- cbind(size_rows[1:4], as.data.frame(size_rows$share))
  size_summary$group <- factor(size_summary$group,
    c("compatible", "mildly compatible", "non-compatible"),
    c("Compatible", "Mildly compatible", "Non-compatible"))

  figure_theme <- theme(
    text = element_text(size = 10),
    axis.text = element_text(size = 9),
    axis.title = element_text(size = 10),
    strip.text = element_text(size = 10),
    legend.text = element_text(size = 9),
    legend.key.width = unit(17, "pt"),
    legend.spacing.x = unit(3, "pt"),
    legend.margin = margin(0, 0, 0, 0),
    legend.box.spacing = unit(3, "pt"),
    plot.title = element_text(size = 11, face = "plain", margin = margin(b = 6)),
    plot.title.position = "plot",
    plot.margin = margin(4, 2, 3, 2)
  )

  coefficient_plot <- simulation_plot(error_summary) + facet_grid(. ~ h) + figure_theme +
    labs(title = "(a) Coefficient estimation: $n_k = 300$",
         x = "Number of sources, $m$")
  borrowing_plot <- simulation_plot(size_summary, category = TRUE) + figure_theme +
    labs(title = "(b) Borrowing across sources: $n_k = 100$") +
    theme(strip.text.y = element_text(size = 9),
          panel.spacing.y = unit(6, "pt"))

  body <- tempfile(fileext = ".tex")
  tikzDevice::tikz(body, standAlone = FALSE, width = 5.8, height = 6.65,
    sanitize = FALSE, timestamp = FALSE,
    packages = c(getOption("tikzLatexPackages"),
                 "\\usepackage{mathpazo}", "\\usepackage{amsmath}", "\\usepackage{xcolor}"))

  # Align the plotting columns while preserving separate vertical scales and legends.
  top <- ggplotGrob(coefficient_plot)
  bottom <- ggplotGrob(borrowing_plot)
  # Reserve the same right-hand space as the compatibility labels in part (b).
  top <- gtable::gtable_add_cols(top, bottom$widths[12], pos = 11)
  stopifnot(length(top$widths) == length(bottom$widths))
  top$widths <- bottom$widths <- unit.pmax(top$widths, bottom$widths)
  grid.newpage()
  pushViewport(viewport(layout = grid.layout(2, 1, heights = unit(c(2.2, 4.45), "in"))))
  pushViewport(viewport(layout.pos.row = 1))
  grid.draw(top)
  popViewport()
  pushViewport(viewport(layout.pos.row = 2))
  grid.draw(bottom)
  popViewport(2)
  dev.off()

  writeLines(c("\\documentclass[tikz,border=0pt]{standalone}",
               "\\usepackage{amsmath,newpxtext,newpxmath}",
               "\\begin{document}", readLines(body), "\\end{document}"), path)
  compile_plot(path)


  write.csv(error_summary, file.path(dirname(path), "coefficient-error-300.csv"), row.names = FALSE)
  write.csv(size_summary, file.path(dirname(path), "category-effective-sample-size-100.csv"), row.names = FALSE)
}
