# The simulation perturbs centered log weights on the active face of the simplex.
# Keep the selected predictors fixed throughout the finite differences.
log_weight_derivatives <- function(gamma, stacked, sizes, x, y, path, active, cfg) {
  support <- path$support
  basis <- tangent_basis(sum(active))
  dimension <- ncol(basis)
  step <- 1e-3
  shift <- diag(step, nrow = dimension)
  score <- numeric(dimension)
  curvature <- matrix(0, dimension, dimension)
  slope <- matrix(0, cfg$p, dimension)

  # Each perturbation reuses the same source cross-products.
  moments <- lapply(seq_along(sizes), function(k) {
    rows <- stacked$source_id == k
    design <- stacked$X[rows, support, drop = FALSE]
    list(gram = crossprod(design) / sizes[k],
         xy = crossprod(design, stacked$y[rows]) / sizes[k])
  })
  gram <- lapply(moments, "[[", "gram")
  xy <- lapply(moments, "[[", "xy")
  evaluate <- function(delta) {
    log_w <- log(gamma[active]) + drop(basis %*% delta)
    w <- gamma
    relative <- exp(log_w - max(log_w))
    w[active] <- sum(gamma[active]) * relative / sum(relative)
    beta <- numeric(cfg$p)
    if (length(support)) {
      normal <- Reduce("+", Map("*", gram, w))
      diag(normal) <- diag(normal) + 1e-8
      beta[support] <- solve(normal, Reduce("+", Map("*", xy, w)))
    }
    loss <- mean((y - drop(x %*% beta))^2) + cfg$lambda_gamma * weighted_centered_l2(w, sizes)
    list(beta = beta, loss = loss)
  }
  center <- evaluate(numeric(dimension))
  for (j in seq_len(dimension)) {
    u <- shift[, j]
    plus <- evaluate(u)
    minus <- evaluate(-u)
    slope[, j] <- (plus$beta - minus$beta) / (2 * step)
    score[j] <- (plus$loss - minus$loss) / (2 * step)
    curvature[j, j] <- (plus$loss - 2 * center$loss + minus$loss) / step^2
    for (k in seq_len(j - 1L)) {
      v <- shift[, k]
      mixed <- (evaluate(u + v)$loss - evaluate(u - v)$loss -
                evaluate(-u + v)$loss + evaluate(-u - v)$loss) / (4 * step^2)
      curvature[j, k] <- curvature[k, j] <- mixed
    }
  }
  list(beta = path$beta_ref, D = slope, S = score, H = curvature)
}
