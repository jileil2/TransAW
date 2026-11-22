group_labels <- function(m) {
  if (m %% 5L != 0L) stop("m must be a multiple of 5 for the 2:2:1 group ratio.")
  c(
    rep("compatible", 2L * m / 5L),
    rep("mildly compatible", 2L * m / 5L),
    rep("non-compatible", m / 5L)
  )
}

group_q <- function(groups) {
  out <- rep(1, length(groups))
  for (g in c("mildly compatible", "non-compatible")) {
    idx <- which(groups == g)
    if (length(idx) == 1L) {
      out[idx] <- 1
    } else if (length(idx) > 1L) {
      out[idx] <- seq(0.75, 1.25, length.out = length(idx))
    }
  }
  out
}

fixed_sparse_directions <- function(m, p, h_delta, seed) {
  old_seed_exists <- exists(".Random.seed", envir = .GlobalEnv, inherits = FALSE)
  old_seed <- if (old_seed_exists) get(".Random.seed", envir = .GlobalEnv) else NULL
  on.exit({
    if (old_seed_exists) {
      assign(".Random.seed", old_seed, envir = .GlobalEnv)
    } else if (exists(".Random.seed", envir = .GlobalEnv, inherits = FALSE)) {
      rm(".Random.seed", envir = .GlobalEnv)
    }
  }, add = TRUE)
  set.seed(seed + 1000L * m)
  U <- matrix(0, nrow = m, ncol = p)
  for (k in seq_len(m)) {
    supp <- sample.int(p, h_delta)
    signs <- sample(c(-1, 1), h_delta, replace = TRUE)
    U[k, supp] <- signs / sqrt(h_delta)
  }
  U
}

make_beta0 <- function(p, s0) {
  beta0 <- rep(0, p)
  beta0[seq_len(s0)] <- 0.3
  beta0
}

make_source_betas <- function(beta0, groups, U, h, cfg) {
  base <- sqrt(cfg$s0 * log(cfg$p) / cfg$n0)
  q <- group_q(groups)
  a <- numeric(length(groups))
  a[groups == "compatible"] <- 0.1 * base
  a[groups == "mildly compatible"] <- 0.2 * h * q[groups == "mildly compatible"] * base
  a[groups == "non-compatible"] <- 0.5 * h * q[groups == "non-compatible"] * base
  betas <- t(vapply(seq_along(groups), function(k) beta0 + a[k] * U[k, ], numeric(cfg$p)))
  list(betas = betas, a = a, q = q)
}

generate_data <- function(rep_id, m, h, cfg, U_fixed) {
  set.seed(cfg$seed + 100000L * rep_id + 1000L * m + as.integer(10 * h))
  groups <- group_labels(m)
  beta0 <- make_beta0(cfg$p, cfg$s0)
  source_info <- make_source_betas(beta0, groups, U_fixed, h, cfg)
  X0 <- matrix(rnorm(cfg$n0 * cfg$p), nrow = cfg$n0, ncol = cfg$p)
  y0 <- as.numeric(X0 %*% beta0 + rnorm(cfg$n0))
  X_sources <- vector("list", m)
  y_sources <- vector("list", m)
  for (k in seq_len(m)) {
    X_sources[[k]] <- matrix(rnorm(cfg$n_k * cfg$p), nrow = cfg$n_k, ncol = cfg$p)
    y_sources[[k]] <- as.numeric(X_sources[[k]] %*% source_info$betas[k, ] + rnorm(cfg$n_k))
  }
  list(
    X0 = X0, y0 = y0,
    X_sources = X_sources, y_sources = y_sources,
    beta0 = beta0,
    groups = groups
  )
}
