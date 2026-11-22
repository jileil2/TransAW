trans_lasso_candidate_sets <- function(rank_pi) {
  kk_list <- unique(rank_pi)
  tset <- lapply(seq_along(kk_list), function(kk) which(rank_pi <= kk_list[kk]))
  unique(tset)
}

trans_lasso_mass_from_reference <- function(fit, m) {
  theta <- as.numeric(fit$theta.hat)
  if (!length(theta) || !length(fit$rank.pi)) return(rep(0, m))
  tset <- trans_lasso_candidate_sets(fit$rank.pi)
  candidates <- c(list(integer(0)), tset)

  # The reference implementation removes duplicate candidate coefficient
  # vectors before Q-aggregation but does not return the surviving source
  # sets.  In the rare event that duplicates alter the candidate count, we
  # align theta with the nested ranked sets in their reference order.
  if (length(candidates) < length(theta)) {
    candidates <- c(candidates, rep(list(integer(0)), length(theta) - length(candidates)))
  } else if (length(candidates) > length(theta)) {
    candidates <- candidates[seq_along(theta)]
  }

  mass <- rep(0, m)
  for (ell in seq_along(theta)) {
    chosen <- candidates[[ell]]
    if (length(chosen)) mass[chosen] <- mass[chosen] + theta[ell]
  }
  if (sum(mass) > 0) mass <- mass / sum(mass)
  mass
}

fit_trans_lasso_reference_one <- function(dat, I_til) {
  # The simulation used unpenalized pooled candidates. The target-only
  # candidate still selects its penalty by eight-fold cross-validation.
  ref <- new.env(parent = tl_reference)
  ref$las.kA <- function(X, y, A0, n.vec, lam.const = NULL, l1 = TRUE) {
    tl_reference$las.kA(X, y, A0, n.vec, lam.const = 0, l1 = l1)
  }
  ref$Trans.lasso <- tl_reference$Trans.lasso
  environment(ref$Trans.lasso) <- ref
  X <- do.call(rbind, c(list(dat$X0), dat$X_sources))
  y <- c(dat$y0, unlist(dat$y_sources, use.names = FALSE))
  n_vec <- c(nrow(dat$X0), vapply(dat$X_sources, nrow, integer(1)))
  ref$Trans.lasso(X = X, y = y, n.vec = n_vec, I.til = I_til, l1 = TRUE)
}

fit_trans_lasso_reference <- function(dat, seed) {
  # This benchmark calls the reference Trans-LASSO implementation in
  # Li, Cai and Li's code.  The reference routine performs source ranking,
  # candidate-set construction, and Q-aggregation internally.
  set.seed(seed)
  n0 <- nrow(dat$X0)
  m <- length(dat$X_sources)

  # Match the example in TransLasso-main: use two complementary target
  # validation folds for Q-aggregation and average the two resulting fits.
  A <- sample.int(n0, floor(n0 / 2))
  B <- setdiff(seq_len(n0), A)
  fit_A <- fit_trans_lasso_reference_one(dat, I_til = A)
  fit_B <- fit_trans_lasso_reference_one(dat, I_til = B)

  beta <- 0.5 * (as.numeric(fit_A$beta.hat) + as.numeric(fit_B$beta.hat))
  mass <- 0.5 * (
    trans_lasso_mass_from_reference(fit_A, m) +
      trans_lasso_mass_from_reference(fit_B, m)
  )
  if (sum(mass) > 0) mass <- mass / sum(mass)
  list(
    beta = beta,
    mass = mass,
    theta = list(fold_A = fit_A$theta.hat, fold_B = fit_B$theta.hat),
    rank = list(fold_A = fit_A$rank.pi, fold_B = fit_B$rank.pi)
  )
}
