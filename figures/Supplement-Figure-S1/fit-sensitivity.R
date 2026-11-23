library(TransAW)
source("figures/Main-Figure-1/simulation-design.R")

fit_target_lasso <- function(x, y, seed) {
  set.seed(seed)
  fold <- sample(rep(1:5, length.out = nrow(x)))
  fit <- glmnet::cv.glmnet(x, y, foldid = fold, standardize = FALSE,
                          intercept = FALSE)
  as.numeric(coef(fit, s = "lambda.min"))[-1L]
}

# Reuse each dataset and fitting seed across the seven multipliers. Save after
# every fit so that an interrupted run can continue from its last completed fit.
fit_sensitivity <- function(n, sources = c(5, 10, 15, 20),
                            heterogeneity = c(2, 4, 6), replications = 1:200) {
  stopifnot(length(n) == 1L, n %in% c(100, 300), length(sources) > 0L,
            all(sources %in% c(5, 10, 15, 20)), !anyDuplicated(sources),
            length(heterogeneity) > 0L, all(heterogeneity %in% c(2, 4, 6)),
            !anyDuplicated(heterogeneity), length(replications) > 0L,
            all(replications %in% 1:200), !anyDuplicated(replications))
  settings <- list(seed = 20260716L, p = 500L, s0 = 16L, n0 = 150L, n_k = n)
  multipliers <- c(0.01, 0, 0.0025, 0.005, 0.02, 0.05, 0.1)
  folder <- work_directory("penalty-sensitivity")
  records <- list()
  for (m in sources) {
    directions <- fixed_sparse_directions(m, settings$p, 6L, settings$seed)
    for (h in heterogeneity) {
      for (i in replications) {
        path <- file.path(folder, sprintf("n%d-m%d-h%d-rep%03d.rds", n, m, h, i))
        key <- data.frame(n_k = n, m = m, h = h, rep = i)
        record <- if (file.exists(path)) readRDS(path) else NULL
        if (!is.null(record)) {
          stopifnot(identical(record$settings, settings),
                    nrow(record$target) == 1L,
                    isTRUE(all.equal(record$target[names(key)], key)),
                    all(is.finite(record$target$error)))
          if (nrow(record$fits) > 0L) {
            stopifnot(!anyDuplicated(record$fits$multiplier),
                      all(record$fits$multiplier %in% multipliers),
                      all(is.finite(record$fits$error)),
                      all(record$fits$n_k == n), all(record$fits$m == m),
                      all(record$fits$h == h), all(record$fits$rep == i))
          }
        }
        pending <- setdiff(multipliers, record$fits$multiplier)
        if (length(pending)) {
          dat <- generate_data(i, m, h, settings, directions)
          seed <- settings$seed + 1000L * i + 10000000L * m + 10000L * h
          target <- list(x = dat$X0, y = dat$y0)
          cohorts <- Map(function(x, y) list(x = x, y = y),
                         dat$X_sources, dat$y_sources)
          if (is.null(record)) {
            beta <- fit_target_lasso(dat$X0, dat$y0, seed + 2L)
            stopifnot(all(is.finite(beta)))
            record <- list(settings = settings, fits = NULL,
                           target = cbind(key, error = sum((beta - dat$beta0)^2)))
          }
          for (value in pending) {
            fit <- TransAW(data = target, sources = cohorts, multiplier = value,
                           seed = seed + 1L, coordinates = "log_weights")
            stopifnot(all(is.finite(coef(fit))))
            row <- cbind(key, data.frame(
              multiplier = value, error = sum((coef(fit) - dat$beta0)^2),
              effective_n = 1 / sum(fit$weights^2 / n),
              status_A = fit$diagnostics$optimizer_status[1],
              status_B = fit$diagnostics$optimizer_status[2]))
            record$fits <- rbind(record$fits, row)
            save_fit(record, path)
          }
          message(sprintf("Completed n_k=%d, m=%d, h=%d, replication %d", n, m, h, i))
        }
        records[[length(records) + 1L]] <- record
      }
    }
  }
  list(fits = do.call(rbind, lapply(records, "[[", "fits")),
       target = do.call(rbind, lapply(records, "[[", "target")))
}
