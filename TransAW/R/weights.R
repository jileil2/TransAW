project_simplex <- function(gamma, lower = 0) {
  gamma <- pmax(as.numeric(gamma), lower)
  s <- sum(gamma)
  if (!is.finite(s) || s <= 0) return(rep(1 / length(gamma), length(gamma)))
  gamma / s
}

############################################################
# Sample-size-aware source-weight stabilization
############################################################

weighted_centered_l2 <- function(gamma, n_source) {
  gamma <- as.numeric(gamma)
  n_source <- as.numeric(n_source)

  if (length(gamma) != length(n_source)) {
    stop("gamma and n_source must have the same length")
  }
  if (any(!is.finite(gamma)) || any(!is.finite(n_source)) ||
      any(n_source <= 0)) {
    stop("gamma must be finite and source sizes must be positive")
  }

  N <- sum(n_source)
  gamma_pool <- n_source / N
  sum((gamma - gamma_pool)^2 / gamma_pool)
}

effective_source_n <- function(gamma, n_source) {
  gamma <- as.numeric(gamma)
  n_source <- as.numeric(n_source)
  if (length(gamma) != length(n_source) || any(n_source <= 0)) {
    stop("gamma and positive n_source must have the same length")
  }
  1 / sum(gamma^2 / n_source)
}

weight_criterion <- function(gamma, x, y, stacked, sizes, source_map, cfg) {
  refit <- fit_source_path(gamma, stacked, source_map, cfg)
  loss <- mean((y - as.numeric(x %*% refit$beta_ref))^2)
  loss + cfg$lambda_gamma * weighted_centered_l2(gamma, sizes)
}

validate_fold_weights <- function(w, sources) {
  directions <- c("A_to_B", "B_to_A")
  if (!is.matrix(w) || !is.numeric(w) || nrow(w) != 2L || ncol(w) != length(sources) ||
      !setequal(rownames(w), directions) || !setequal(colnames(w), sources) ||
      any(!is.finite(w)) || any(w < 0) || any(abs(rowSums(w) - 1) > 1e-6)) {
    stop("Supply nonnegative fold weights with one column per named source, rows A_to_B and B_to_A, and row sums of one.")
  }
  w <- w[directions, sources, drop = FALSE]
  w / rowSums(w)
}

learn_weights <- function(x, y, stacked, sizes, source_map, cfg) {
  pooled <- source_map$gamma_pool
  objective <- function(gamma) {
    weight_criterion(project_simplex(gamma), x, y, stacked, sizes, source_map, cfg)
  }
  if (length(pooled) == 1L) {
    return(list(gamma = 1, objective = objective(1), status = "single source"))
  }

  cache <- new.env(parent = emptyenv())
  evaluate <- function(gamma) {
    gamma <- project_simplex(gamma)
    key <- paste(round(gamma, 8L), collapse = ",")
    if (is.null(cache[[key]])) cache[[key]] <- objective(gamma)
    cache[[key]]
  }
  opt <- nloptr::cobyla(
    x0 = project_simplex(pooled), fn = evaluate,
    lower = rep(0, length(pooled)), upper = rep(1, length(pooled)),
    hin = function(w) c(sum(w) - 1, 1 - sum(w)),
    control = list(xtol_rel = 1e-5, maxeval = 2400L),
    deprecatedBehavior = FALSE
  )
  if (opt$convergence < 0 || any(!is.finite(opt$par)) ||
      abs(sum(opt$par) - 1) + sum(pmax(-opt$par, 0)) > 1e-6) {
    stop("COBYLA failed to return feasible source weights. ", opt$message)
  }
  gamma <- project_simplex(opt$par)
  value <- objective(gamma)
  if (!is.finite(value)) stop("The fitted source-weight criterion is not finite.")
  list(gamma = gamma, objective = value, status = opt$message)
}
