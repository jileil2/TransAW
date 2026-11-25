# Zhao et al. reference implementation, downloaded only when a refit is requested.
riw_reference <- NULL
load_riw_reference <- function() {
  folder <- file.path(Sys.getenv("TRANSAW_WORKDIR", "results"), "reference")
  dir.create(folder, recursive = TRUE, showWarnings = FALSE)
  path <- file.path(folder, "riw.R")
  if (!file.exists(path)) {
    download.file("https://raw.githubusercontent.com/RIW-TL/Transfer-learning/cee9d7b4a5ca32abfbe466e2902806a232f86ba0/functions.R",
                  path, mode = "wb")
  }
  env <- new.env(parent = globalenv())
  sys.source(path, envir = env)
  env
}

riw_fit <- function(dat, seed) {
  if (is.null(riw_reference)) riw_reference <<- load_riw_reference()
  x <- do.call(rbind, c(list(dat$X0), dat$X_sources))
  y <- c(dat$y0, unlist(dat$y_sources, use.names = FALSE))
  sizes <- c(nrow(dat$X0), vapply(dat$X_sources, nrow, integer(1)))
  m <- length(dat$X_sources)
  set.seed(seed)
  tuning <- riw_reference$hyper.select.cv(x, y, sizes, K = m, fold = 5)
  A <- tuning$A.opt
  M <- tuning$M.opt
  set.seed(seed + 1L)
  fit <- riw_reference$fit.RIW(x, y, sizes, K = m, A = A, M = M, TU = A + M)
  replay <- riw_source_weights(dat, A, M, seed + 1L)
  stopifnot(sqrt(sum((fit$beta_RIW_TL - replay$beta)^2)) <= 1e-6)
  list(beta = as.numeric(fit$beta_RIW_TL), mass = replay$mass)
}

# Recover source contributions from the three rotations of the published RIW estimator.
reference_target_split <- function(X0, y0, j) {
  n0 <- nrow(X0)
  n_third <- floor(n0 / 3)
  id <- ((j - 1L) * n_third + 1L):(j * n_third)
  list(
    X01 = X0[-id, , drop = FALSE],
    Y01 = y0[-id],
    X02 = X0[id, , drop = FALSE],
    Y02 = y0[id]
  )
}

reference_source_splits <- function(X_sources, y_sources) {
  m <- length(X_sources)
  XP <- YP <- vector("list", 3L)
  for (j in seq_len(3L)) {
    XP[[j]] <- YP[[j]] <- vector("list", m)
  }
  for (k in seq_len(m)) {
    n_k <- nrow(X_sources[[k]])
    n_third <- floor(n_k / 3)
    ids <- list(
      seq_len(n_third),
      (n_third + 1L):floor(2 * n_k / 3),
      (floor(2 * n_k / 3) + 1L):n_k
    )
    for (j in seq_len(3L)) {
      XP[[j]][[k]] <- X_sources[[k]][ids[[j]], , drop = FALSE]
      YP[[j]][[k]] <- y_sources[[k]][ids[[j]]]
    }
  }
  list(X = XP, y = YP)
}

riw_rotation <- function(X01, Y01, X02, Y02,
                         X11, Y11, X12, Y12, X13, Y13,
                         A, M) {
  p <- ncol(X01)
  m <- length(X11)

  target_fit <- ncvreg::cv.ncvreg(X01, Y01, family = "gaussian", penalty = "SCAD")
  beta_target <- as.numeric(stats::coef(target_fit))[-1]

  beta_source <- matrix(0, nrow = p, ncol = m)
  for (k in seq_len(m)) {
    source_fit <- glmnet::cv.glmnet(X11[[k]], Y11[[k]], family = "gaussian", alpha = 1)
    # Match the Zhao reference code: coef(cv.glmnet_object) is used without
    # specifying s, so the replay must not force lambda.min here.
    beta_source[, k] <- as.numeric(stats::coef(source_fit))[-1]
  }

  YY <- Y02
  XX <- X02
  source_weight_sums <- numeric(m)

  for (k in seq_len(m)) {
    source_resid_density <- as.numeric(Y12[[k]] - X12[[k]] %*% beta_source[, k])
    kde_fit <- ks::kde(x = source_resid_density)

    target_resid_on_source <- as.numeric(Y13[[k]] - X13[[k]] %*% beta_target)
    source_resid_on_source <- as.numeric(Y13[[k]] - X13[[k]] %*% beta_source[, k])
    contrast <- as.numeric(X13[[k]] %*% (beta_source[, k] - beta_target))

    numerator <- (
      as.numeric(predict(kde_fit, x = target_resid_on_source)) +
        as.numeric(predict(kde_fit, x = -target_resid_on_source))
    ) / 2
    denominator <- as.numeric(predict(kde_fit, x = source_resid_on_source))
    weights <- numerator / denominator
    weights[which(numerator < 0 | denominator < 0)] <- 0
    weights[!is.finite(weights)] <- 0

    pass_source_resid <- abs(source_resid_on_source) <= A
    pass_contrast <- abs(contrast) <= M
    keep <- which(pass_source_resid & pass_contrast)
    kept_weights <- weights[keep]

    if (length(keep)) {
      sqrt_w <- sqrt(pmax(kept_weights, 0))
      YY <- c(YY, sqrt_w * Y13[[k]][keep])
      XX <- rbind(XX, X13[[k]][keep, , drop = FALSE] * sqrt_w)
    }

    source_weight_sums[k] <- sum(kept_weights[is.finite(kept_weights) & kept_weights > 0])
  }

  lambda <- 0.5 * sqrt(log(p) / length(YY))
  final_fit <- glmnet::glmnet(XX, YY, family = "gaussian", alpha = 1, lambda = lambda)
  beta <- as.numeric(stats::coef(final_fit, s = lambda))[-1]
  list(beta = beta, source_weight_sums = source_weight_sums)
}

riw_source_weights <- function(dat, A, M, seed) {
  set.seed(seed)
  target_splits <- lapply(seq_len(3L), function(j) {
    reference_target_split(dat$X0, dat$y0, j)
  })
  source_splits <- reference_source_splits(dat$X_sources, dat$y_sources)
  fits <- list(
    riw_rotation(
      target_splits[[1]]$X01, target_splits[[1]]$Y01,
      target_splits[[1]]$X02, target_splits[[1]]$Y02,
      source_splits$X[[1]], source_splits$y[[1]],
      source_splits$X[[2]], source_splits$y[[2]],
      source_splits$X[[3]], source_splits$y[[3]],
      A, M
    ),
    riw_rotation(
      target_splits[[2]]$X01, target_splits[[2]]$Y01,
      target_splits[[2]]$X02, target_splits[[2]]$Y02,
      source_splits$X[[2]], source_splits$y[[2]],
      source_splits$X[[3]], source_splits$y[[3]],
      source_splits$X[[1]], source_splits$y[[1]],
      A, M
    ),
    riw_rotation(
      target_splits[[3]]$X01, target_splits[[3]]$Y01,
      target_splits[[3]]$X02, target_splits[[3]]$Y02,
      source_splits$X[[3]], source_splits$y[[3]],
      source_splits$X[[1]], source_splits$y[[1]],
      source_splits$X[[2]], source_splits$y[[2]],
      A, M
    )
  )
  raw_mass <- Reduce(`+`, lapply(fits, `[[`, "source_weight_sums"))
  list(beta = Reduce(`+`, lapply(fits, `[[`, "beta")) / 3,
       mass = if (sum(raw_mass) > 0) raw_mass / sum(raw_mass) else numeric(length(raw_mass)))
}
