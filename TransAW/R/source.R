fit_lasso <- function(X, y, weights = NULL, lambda = NULL, nfolds = 5, seed = NULL) {
  nfolds <- min(nfolds, max(3L, floor(nrow(X) / 10)))
  if (is.null(weights)) weights <- rep(1, nrow(X))
  weights <- pmax(weights, 1e-8)
  if (all(y == 0)) {
    return(list(beta = numeric(ncol(X)), lambda = 0, support_size = 0L))
  }
  if (is.null(lambda)) {
    if (!is.null(seed)) {
      set.seed(seed)
      foldid <- sample(rep(seq_len(nfolds), length.out = nrow(X)))
    } else {
      foldid <- rep(seq_len(nfolds), length.out = nrow(X))
    }
    fit <- glmnet::cv.glmnet(
      x = X, y = y, weights = weights, alpha = 1,
      intercept = FALSE, standardize = FALSE, nfolds = nfolds,
      foldid = foldid
    )
    beta <- as.numeric(stats::coef(fit, s = "lambda.min"))[-1]
    lam <- fit$lambda.min
  } else {
    fit <- glmnet::glmnet(
      x = X, y = y, weights = weights, alpha = 1,
      intercept = FALSE, standardize = FALSE, lambda = lambda
    )
    beta <- as.numeric(stats::coef(fit, s = lambda))[-1]
    lam <- lambda
  }
  list(beta = beta, lambda = lam, support_size = sum(abs(beta) > 1e-8))
}

fit_adjustment <- function(X0, y0, beta_src, cfg, seed = NULL) {
  residual <- y0 - as.numeric(X0 %*% beta_src)
  delta <- fit_lasso(
    X0,
    residual,
    nfolds = cfg$nfolds,
    seed = seed
  )$beta
  beta_src + delta
}

stack_sources <- function(X_sources, y_sources) {
  X <- do.call(rbind, X_sources)
  y <- unlist(y_sources, use.names = FALSE)
  source_id <- rep(seq_along(X_sources), vapply(X_sources, nrow, integer(1)))
  list(X = X, y = y, source_id = source_id)
}

weights_from_gamma <- function(gamma, source_id) {
  nk <- tabulate(source_id, nbins = length(gamma))
  gamma[source_id] / nk[source_id]
}

source_lasso_fit_for_gamma <- function(gamma, stacked, cfg, lambda = NULL, seed = NULL) {
  w <- weights_from_gamma(gamma, stacked$source_id)
  fit <- fit_lasso(
    stacked$X,
    stacked$y,
    weights = w,
    lambda = lambda,
    nfolds = cfg$nfolds,
    seed = seed
  )
  fit$support <- which(abs(fit$beta) > 1e-8)
  fit
}

select_trans_aw_source_map <- function(stacked, n_source, cfg, seed = NULL) {
  # CV is used only once to choose the source-side penalty level at the
  # pooled source weight. During source-weight learning, the weighted Lasso is
  # recomputed for each candidate gamma with this fixed lambda.
  gamma_pool <- n_source / sum(n_source)
  fit <- source_lasso_fit_for_gamma(gamma_pool, stacked, cfg, seed = seed)
  list(
    gamma_pool = gamma_pool,
    lambda_src = fit$lambda
  )
}

source_post_lasso_for_gamma <- function(gamma, stacked, support, cfg, ridge = 1e-8) {
  beta <- rep(0, cfg$p)
  if (!length(support)) return(beta)
  w <- weights_from_gamma(gamma, stacked$source_id)
  Xs <- stacked$X[, support, drop = FALSE]
  G <- crossprod(Xs, Xs * w)
  g <- crossprod(Xs, stacked$y * w)
  beta[support] <- as.numeric(solve(G + ridge * diag(length(support)), g))
  beta
}

fixed_support_post_lasso_derivatives <- function(gamma, stacked, support,
                                                 tangent, cfg, ridge = 1e-8) {
  p <- cfg$p
  d <- ncol(tangent)
  beta <- rep(0, p)
  D <- matrix(0, nrow = p, ncol = d)
  D2 <- array(0, dim = c(p, d, d))
  if (!length(support)) {
    return(list(beta = beta, D = D, D2 = D2))
  }

  m <- length(gamma)
  Gk <- vector("list", m)
  hk <- vector("list", m)
  for (k in seq_len(m)) {
    rows <- which(stacked$source_id == k)
    Xk <- stacked$X[rows, support, drop = FALSE]
    yk <- stacked$y[rows]
    nk <- length(rows)
    Gk[[k]] <- crossprod(Xk) / nk
    hk[[k]] <- as.numeric(crossprod(Xk, yk) / nk)
  }

  G <- Reduce(`+`, Map(function(weight, moment) weight * moment, gamma, Gk))
  h <- Reduce(`+`, Map(function(weight, moment) weight * moment, gamma, hk))
  G_solve <- G + ridge * diag(length(support))
  beta_J <- as.numeric(solve(G_solve, h))
  beta[support] <- beta_J

  if (d > 0L) {
    Gu <- vector("list", d)
    for (r in seq_len(d)) {
      u <- tangent[, r]
      Gu[[r]] <- Reduce(`+`, Map(function(weight, moment) weight * moment, u, Gk))
      hu <- Reduce(`+`, Map(function(weight, moment) weight * moment, u, hk))
      D[support, r] <- as.numeric(
        solve(G_solve, hu - as.numeric(Gu[[r]] %*% beta_J))
      )
    }
    for (r in seq_len(d)) {
      for (s in seq_len(d)) {
        rhs <- as.numeric(
          Gu[[s]] %*% D[support, r] +
            Gu[[r]] %*% D[support, s]
        )
        D2[support, r, s] <- -as.numeric(solve(G_solve, rhs))
      }
    }
  }
  list(beta = beta, D = D, D2 = D2)
}

fit_source_path <- function(gamma, stacked, source_map, cfg) {
  if (!is.null(source_map$shared_fit)) return(source_map$shared_fit(gamma))
  fit <- source_lasso_fit_for_gamma(gamma, stacked, cfg, lambda = source_map$lambda_src)
  beta <- source_post_lasso_for_gamma(gamma, stacked, fit$support, cfg)
  list(beta_ref = beta, support = fit$support)
}
