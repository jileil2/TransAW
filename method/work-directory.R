# Set TRANSAW_WORKDIR to choose where model fits and manuscript files are written.
work_directory <- function(folder) {
  root <- Sys.getenv("TRANSAW_WORKDIR", unset = "../TransAW-analysis")
  path <- file.path(root, folder)
  if (!dir.exists(path)) dir.create(path, recursive = TRUE, showWarnings = FALSE)
  if (!dir.exists(path)) stop("Could not create ", path)
  path
}

save_fit <- function(fit, path) {
  temporary <- tempfile(tmpdir = dirname(path))
  on.exit(unlink(temporary))
  saveRDS(fit, temporary)
  if (!file.rename(temporary, path)) stop("Could not save ", path)
}
