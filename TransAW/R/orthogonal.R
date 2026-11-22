weight_derivatives <- function(gamma, stacked, n_source, X_score, y_score, support, active, cfg) {
  T_active <- tangent_basis(sum(active))
  T_basis <- matrix(0, nrow = length(gamma), ncol = ncol(T_active))
  T_basis[active, ] <- T_active
  derivatives <- fixed_support_post_lasso_derivatives(
    gamma, stacked, support, T_basis, cfg
  )
  beta_src <- derivatives$beta
  D <- derivatives$D
  D2 <- derivatives$D2

  n_score <- nrow(X_score)
  target_residual <- y_score - as.numeric(X_score %*% beta_src)
  target_score <- as.numeric(crossprod(X_score, target_residual) / n_score)
  gamma_pool <- n_source / sum(n_source)
  penalty_gradient <- 2 * as.numeric(
    crossprod(T_basis, (gamma - gamma_pool) / gamma_pool)
  )
  penalty_hessian <- 2 * crossprod(
    T_basis,
    sweep(T_basis, 1L, gamma_pool, "/")
  )
  S <- -2 * as.numeric(crossprod(D, target_score)) +
    cfg$lambda_gamma * penalty_gradient
  # Form the curvature in source-weight coordinates to avoid a p by p matrix.
  H <- 2 * crossprod(X_score %*% D) / n_score
  d <- ncol(T_basis)
  for (r in seq_len(d)) {
    for (s in seq_len(d)) {
      H[r, s] <- H[r, s] -
        2 * sum(D2[, r, s] * target_score)
    }
  }
  H <- 0.5 * (H + t(H)) + cfg$lambda_gamma * penalty_hessian
  list(beta = beta_src, D = D, S = S, H = H)
}

tangent_basis <- function(K) {
  if (K <= 1L) return(matrix(0, nrow = K, ncol = 0L))
  C <- diag(K) - matrix(1 / K, K, K)
  qr.Q(qr(C))[, seq_len(K - 1L), drop = FALSE]
}

stabilized_solve <- function(H, b, ridge = 1e-8, abs_floor = 1e-3) {
  if (!length(b)) return(numeric(0))
  H <- 0.5 * (H + t(H))
  eig <- eigen(H, symmetric = TRUE)
  vals <- pmax(eig$values, abs_floor, ridge)
  as.numeric(eig$vectors %*% (crossprod(eig$vectors, b) / vals))
}

orthogonal_source_lasso <- function(gamma, stacked, n_source,
                                    X_score, y_score, source_map, cfg) {
  m <- length(gamma)
  # Global source-weight learning is bilevel.  Local derivatives for the
  # orthogonal correction are computed on the selected support at gamma,
  # matching the local support-stability event in the theory.  The outer
  # simplex optimizer treats the bilevel objective as a black box. D_beta is
  # source-side; both H_gamma and S_gamma use the held-out target fold so the
  # score expansion and its inverse use the same empirical Hessian.
  local_path <- fit_source_path(gamma, stacked, source_map, cfg)
  support <- local_path$support
  beta_src <- local_path$beta_ref
  active <- gamma > cfg$active_tol
  lambda_is_zero <- abs(cfg$lambda_gamma) <= sqrt(.Machine$double.eps)
  if (m <= 1L || sum(active) <= 1L) {
    return(list(
      beta = beta_src,
      beta_ref = as.numeric(beta_src),
      correction = rep(0, length(beta_src)),
      diagnostics = data.frame(
        active_source_count = sum(active),
        raw_hessian_min_eigenvalue = NA_real_,
        raw_hessian_median_eigenvalue = NA_real_,
        raw_hessian_max_eigenvalue = NA_real_,
        raw_hessian_trace = NA_real_,
        hessian_dimension = 0L,
        hessian_negative_eigenvalue_count = 0L,
        hessian_eigenvalues_below_floor_count = 0L,
        hessian_eigenvalues_below_floor_fraction = NA_real_,
        heldout_score_l2 = NA_real_,
        hessian_floor = NA_real_,
        hessian_floor_active = FALSE,
        lambda_gamma = cfg$lambda_gamma,
        lambda_gamma_is_zero = lambda_is_zero,
        diagnostic_regime = if (lambda_is_zero) {
          "selected_zero_floor_inactive_identification_unverified"
        } else {
          "positive_penalty_no_floor"
        },
        stringsAsFactors = FALSE
      )
    ))
  }

  derivatives <- if (cfg$coordinates == "log_weights") {
    log_weight_derivatives(gamma, stacked, n_source, X_score, y_score, local_path, active, cfg)
  } else {
    weight_derivatives(gamma, stacked, n_source, X_score, y_score, support, active, cfg)
  }
  beta_src <- derivatives$beta
  D <- derivatives$D
  S <- derivatives$S
  H <- derivatives$H
  # The Hessian floor is only a numerical conditioning device for the
  # fixed-support quadratic criterion.  By default it is on the fold-size
  # scale used in the report.
  h_floor <- 1 / sqrt(nrow(X_score))
  hessian_eigenvalues <- eigen(
    (H + t(H)) / 2, symmetric = TRUE, only.values = TRUE
  )$values
  raw_hessian_min <- min(hessian_eigenvalues)
  floor_active <- raw_hessian_min < h_floor
  diagnostic_regime <- if (floor_active) {
    "floor_active_not_covered_by_unregularized_theory"
  } else if (lambda_is_zero) {
    "selected_zero_floor_inactive_identification_unverified"
  } else {
    "positive_penalty_no_floor"
  }
  correction <- as.numeric(D %*% stabilized_solve(H, S, abs_floor = h_floor))
  list(
    beta = as.numeric(beta_src - correction),
    beta_ref = as.numeric(beta_src),
    correction = correction,
    diagnostics = data.frame(
      active_source_count = sum(active),
      raw_hessian_min_eigenvalue = raw_hessian_min,
      raw_hessian_median_eigenvalue = stats::median(hessian_eigenvalues),
      raw_hessian_max_eigenvalue = max(hessian_eigenvalues),
      raw_hessian_trace = sum(hessian_eigenvalues),
      hessian_dimension = length(hessian_eigenvalues),
      hessian_negative_eigenvalue_count = sum(hessian_eigenvalues < 0),
      hessian_eigenvalues_below_floor_count =
        sum(hessian_eigenvalues < h_floor),
      hessian_eigenvalues_below_floor_fraction =
        mean(hessian_eigenvalues < h_floor),
      heldout_score_l2 = sqrt(sum(S^2)),
      hessian_floor = h_floor,
      hessian_floor_active = floor_active,
      lambda_gamma = cfg$lambda_gamma,
      lambda_gamma_is_zero = lambda_is_zero,
      diagnostic_regime = diagnostic_regime,
      stringsAsFactors = FALSE
    )
  )
}
