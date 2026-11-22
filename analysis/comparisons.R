# The authors' scripts define some functions with the same names.
# Load each in its own environment.
load_reference <- function(file) {
  path <- file.path("analysis/reference", file)
  if (!file.exists(path)) stop("First run Rscript analysis/get-reference-code.R")
  env <- new.env(parent = globalenv())
  sys.source(path, envir = env)
  env
}
riw_reference <- load_reference("riw.R")
tl_reference <- load_reference("trans-lasso.R")
source("analysis/riw-weights.R")

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

riw_fit <- function(dat, seed) {
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
