# Arguments are source sample size, number of sources, heterogeneity, replication(s).
library(TransAW)
source("analysis/simulation-design.R")
source("analysis/comparisons.R")
source("analysis/simulation-trans-lasso.R")
source("analysis/saved-weights.R")
args <- commandArgs(trailingOnly = TRUE)
reuse_weights <- "--saved-weights" %in% args
args <- as.integer(args[args != "--saved-weights"])
stopifnot(length(args) >= 4L, !anyNA(args))
n <- args[1]
m <- args[2]
h <- args[3]
reps <- args[-(1:3)]
stopifnot(n %in% c(100, 300), m %in% c(5, 10, 15, 20), h %in% c(2, 4, 6), all(reps %in% 1:200))
settings <- list(seed = 20260716L, p = 500L, s0 = 16L, n0 = 150L, n_k = n)
directions <- fixed_sparse_directions(m, settings$p, 6L, settings$seed)
dir.create("output/simulation-fits", recursive = TRUE, showWarnings = FALSE)

saved <- if (reuse_weights) read_setting_weights(n, m, h)
for (i in reps) {
  dat <- generate_data(i, m, h, settings, directions)
  seed <- settings$seed + 1000L * i + 10000000L * m + 10000L * h
  target <- list(x = dat$X0, y = dat$y0)
  sources <- Map(function(x, y) list(x = x, y = y), dat$X_sources, dat$y_sources)
  fold_weights <- if (reuse_weights) replication_weights(saved, i, m)
  aw <- TransAW(data = target, sources = sources, seed = seed + 1L,
                fold_weights = fold_weights, coordinates = "log_weights")
  target_beta <- lasso_cv(dat$X0, dat$y0, seed + 2L)
  tl <- fit_trans_lasso_reference(dat, seed + 3L)
  riw <- riw_fit(dat, seed + 4L)
  coefficients <- list("Trans-AW" = coef(aw), "Target LASSO" = target_beta,
                       "Trans-LASSO" = tl$beta, "RIW-TL" = riw$beta)
  error <- vapply(coefficients, function(b) sum((b - dat$beta0)^2), numeric(1))
  errors <- data.frame(n = n, rep = i, m = m, h = h, method = names(error), coef_error = unname(error))
  mass <- list("Trans-AW" = aw$weights, "Trans-LASSO" = tl$mass, "RIW-TL" = riw$mass)
  weights <- do.call(rbind, lapply(names(mass), function(method) {
    data.frame(rep = i, m = m, h = h, method = method, source = seq_len(m),
               group = dat$groups, mass = unname(mass[[method]]))
  }))
  saveRDS(list(errors = errors, weights = weights),
          sprintf("output/simulation-fits/n%d-m%d-h%d-rep%03d.rds", n, m, h, i))
}
