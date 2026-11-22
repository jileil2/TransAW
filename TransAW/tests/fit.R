library(TransAW)

set.seed(287)
cohort <- function(n, slope) {
  x <- matrix(rnorm(4 * n), n, 4, dimnames = list(NULL, letters[1:4]))
  list(x = x, y = drop(x %*% slope) + rnorm(n))
}
target <- cohort(75, c(1, -1, 0, 0))
sources <- list(near = cohort(64, c(1, -1, 0, 0)), far = cohort(93, c(-1, 1, 0, 1)))
rng <- .Random.seed
fit <- TransAW(data = target, sources = sources, seed = 5)
stopifnot(identical(.Random.seed, rng))
frame <- function(s) data.frame(y = s$y, s$x, unused = 1)
source_frames <- lapply(sources, function(s) frame(s)[, c("c", "b", "d", "a", "unused", "y")])
from_formula <- TransAW(y ~ . - unused - 1, frame(target), source_frames, seed = 5)
stopifnot(isTRUE(all.equal(coef(fit), coef(from_formula))),
          isTRUE(all.equal(fit$fold_weights, from_formula$fold_weights)),
          all(abs(rowSums(fit$fold_weights) - 1) < 1e-10), all(fit$fold_weights >= 0),
          identical(names(fit$weights), names(sources)),
          identical(sort(unname(unlist(fit$folds))), seq_along(target$y)),
          isTRUE(all.equal(unname(fit$diagnostics$lambda_gamma),
                           unname(vapply(fit$folds, function(i) {
                             0.01 * mean((target$y[i] - mean(target$y[i]))^2)
                           }, numeric(1))))),
          isTRUE(all.equal(predict(fit, target$x[, 4:1]),
                           drop(target$x %*% coef(fit)))),
          isTRUE(all.equal(predict(from_formula, frame(target)), predict(fit, target$x))),
          nrow(summary(fit)$sources) == 2L)

single <- TransAW(data = target, sources = sources[1], multiplier = 0)
stopifnot(all(single$weights == 1), all(single$diagnostics$lambda_gamma == 0),
          all(single$diagnostics$hessian_dimension == 0L))
fails <- function(expr) inherits(try(expr, silent = TRUE), "try-error")
stopifnot(fails(predict(fit, unname(target$x))),
          fails(predict(fit, target$x[, -1])),
          fails(TransAW(y ~ ., frame(target), source_frames)),
          fails(TransAW(data = target, sources = list())),
          fails(TransAW(data = target, sources = list(list(x = target$x, y = NA_real_)))),
          fails(TransAW(data = target, sources = sources, multiplier = -1)))

replayed <- TransAW(data = target, sources = sources, seed = 5,
                    fold_weights = fit$fold_weights[2:1, 2:1])
stopifnot(isTRUE(all.equal(coef(fit), coef(replayed), tolerance = 1e-9)),
          fails(TransAW(data = target, sources = sources, shared_design = TRUE)))
