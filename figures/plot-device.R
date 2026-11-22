# Draw plots with the same typefaces as the manuscript figures.
open_kinase_plot <- function(path, width, height) {
  tikzDevice::tikz(path, width=width, height=height, pointsize=12,
                   standAlone=TRUE, sanitize=FALSE, timestamp=FALSE,
                   documentDeclaration="\\documentclass[12pt]{article}",
                   packages=c(getOption("tikzLatexPackages"), "\\usepackage{mathpazo}"))
}

compile_plot <- function(path) {
  build <- tempfile("p38-tikz-")
  dir.create(build)
  output <- system2("pdflatex", c("-interaction=nonstopmode", "-halt-on-error",
                    shQuote(paste0("-output-directory=", build)), shQuote(path)),
                    stdout=TRUE, stderr=TRUE)
  if (!is.null(attr(output,"status"))) stop(paste(tail(output,20),collapse="\n"))
  pdf_name <- paste0(tools::file_path_sans_ext(basename(path)), ".pdf")
  stopifnot(file.copy(file.path(build,pdf_name),file.path(dirname(path),pdf_name),
                      overwrite=TRUE))
}
