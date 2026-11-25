# Target-only LASSO and the common matrix representation.
benchmark_input <- function(target, sources) {
  list(X0 = target$x, y0 = target$y, X_sources = unname(lapply(sources, "[[", "x")),
       y_sources = unname(lapply(sources, "[[", "y")))
}

lasso_cv <- function(x, y, seed) {
  set.seed(seed)
  nfolds <- min(5L, max(3L, floor(nrow(x) / 10)))
  fold <- sample(rep(seq_len(nfolds), length.out = nrow(x)))
  fit <- glmnet::cv.glmnet(x, y, foldid = fold, standardize = FALSE, intercept = FALSE)
  as.numeric(coef(fit, s = "lambda.min"))[-1L]
}
