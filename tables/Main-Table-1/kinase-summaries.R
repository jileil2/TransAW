# Reduce the compound-level errors before averaging across scaffold splits.
kinase_errors <- function(predictions) {
  methods <- c("target", "trans_lasso", "riw", "trans_aw", "equal")
  names <- c("Target-only LASSO", "Trans-LASSO", "RIW-TL", "Trans-AW", "Trans-AW, equal source weights")
  by_split <- lapply(split(predictions, predictions$split), function(p) {
    stopifnot(nrow(p) == 109, !anyDuplicated(p$compound))
    sapply(p[methods], function(y) sqrt(mean((y - p$observed)^2)))
  })
  errors <- as.data.frame(do.call(rbind, by_split))
  colnames(errors) <- names
  errors
}
