# Reduce the compound-level errors before averaging across scaffold splits.
kinase_errors <- function(predictions) {
  methods <- c("target", "trans_lasso", "riw", "trans_aw", "equal")
  names <- c("Target-only LASSO", "Trans-LASSO", "RIW-TL", "Trans-AW", "Trans-AW, equal source weights")
  by_split <- lapply(split(predictions, predictions$split), function(p) {
    stopifnot(nrow(p) == 109, !anyDuplicated(p$compound))
    sapply(p[methods], function(y) mean(abs(y - p$observed)))
  })
  errors <- as.data.frame(do.call(rbind, by_split))
  colnames(errors) <- names
  errors
}

kinase_weights <- function(w) {
  w$trans_aw <- (w$fold_A + w$fold_B) / 2
  selected <- (w$selected_A + w$selected_B) / 2
  w$trans_lasso <- selected / ave(selected, w$split, FUN = sum)
  w$source <- factor(w$source, levels = c("P38beta", "MAPKAPK3", "P38gamma",
                                        "P38delta", "FYN", "YES", "LCK", "Aurora-A", "AKT1"))
  stopifnot(!anyNA(w$source))
  split(w, w$source)
}

source_labels <- c("p38$\\beta$", "MK3", "p38$\\gamma$", "p38$\\delta$",
                   "FYN", "YES", "LCK", "Aurora A", "AKT1")
