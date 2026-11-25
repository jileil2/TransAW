kinases <- c("FYN", "YES", "LCK", "P38beta", "P38gamma", "P38delta",
             "Aurora-A", "AKT1", "MAPKAPK3")

prepare_split <- function(panel, partition) {
  train <- match(partition$compound[partition$role == "train"], panel$compound)
  test <- match(partition$compound[partition$role == "test"], panel$compound)
  stopifnot(length(train) == 255L, length(test) == 109L, !anyNA(c(train, test)),
            !anyDuplicated(c(train, test)), !any(panel$scaffold[train] %in% panel$scaffold[test]))
  prepare_kinases(panel, train, test)
}

prepare_kinases <- function(panel, train = seq_len(nrow(panel)), test = integer()) {
  bits <- as.matrix(panel[, paste0("bit", 0:255)])
  scale_x <- apply(bits[train, , drop = FALSE], 2, sd, na.rm = TRUE)
  keep <- scale_x > 0
  bits <- bits[, keep, drop = FALSE]
  standardize <- function(center) sweep(sweep(bits, 2, center), 2, scale_x[keep], "/")
  target_x <- standardize(colMeans(bits[train, , drop = FALSE], na.rm = TRUE))
  source_x <- standardize(colMeans(bits, na.rm = TRUE))
  target_mean <- mean(panel$P38alpha[train])
  target_sd <- sd(panel$P38alpha[train])
  target <- list(x = target_x[train, , drop = FALSE],
                 y = (panel$P38alpha[train] - target_mean) / target_sd)
  sources <- lapply(kinases, function(k) {
    list(x = source_x, y = (panel[[k]] - mean(panel[[k]])) / target_sd)
  })
  names(sources) <- kinases
  list(target = target, sources = sources, newx = target_x[test, , drop = FALSE],
       mean = target_mean, sd = target_sd, compounds = panel$compound[test],
       observed = panel$P38alpha[test], predictor_scale = scale_x[keep],
       retained_predictors = names(scale_x)[keep])
}
