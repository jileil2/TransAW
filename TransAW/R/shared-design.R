# With the same compounds in every screen, a weighted sum of squared errors
# differs from regression on the weighted mean response by a constant.
shared_source_fit <- function(cohorts, lambda) {
  x <- cohorts[[1]]$x
  if (!all(vapply(cohorts, function(s) identical(s$x, x), logical(1)))) {
    stop("A shared design requires identical source predictor matrices and row order.")
  }
  responses <- do.call(cbind, lapply(cohorts, "[[", "y"))
  gram <- crossprod(x) / nrow(x)
  xy <- crossprod(x, responses) / nrow(x)
  mean_squares <- colMeans(responses^2)
  cache <- new.env(parent = emptyenv())

  function(gamma) {
    # Match the weight floor and convergence tolerance on the stacked data.
    w <- pmax(gamma, 1e-8 * nrow(x))
    w <- w / sum(w)
    y <- drop(responses %*% w)
    beta <- numeric(ncol(x))
    if (all(y == 0)) return(list(beta_ref = beta, support = integer()))
    tolerance <- 1e-7 * sum(w * mean_squares) / mean(y^2)
    fit <- glmnet::glmnet(x, y, lambda = lambda, thresh = tolerance,
                          standardize = FALSE, intercept = FALSE)
    support <- which(abs(as.numeric(fit$beta)) > 1e-8)
    if (length(support)) {
      key <- paste(support, collapse = ",")
      if (is.null(cache[[key]])) {
        normal <- gram[support, support, drop = FALSE]
        diag(normal) <- diag(normal) + 1e-8
        factor <- chol(normal)
        cache[[key]] <- backsolve(factor, forwardsolve(t(factor), xy[support, , drop = FALSE]))
      }
      beta[support] <- drop(cache[[key]] %*% gamma)
    }
    list(beta_ref = beta, support = support)
  }
}
