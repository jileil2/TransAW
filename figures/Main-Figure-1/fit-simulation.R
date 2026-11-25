library(TransAW)
source("figures/Main-Figure-1/simulation-design.R")
source("methods/target-lasso.R")
source("methods/riw-tl.R")
source("figures/Main-Figure-1/simulation-trans-lasso.R")

fit_replication <- function(n, m, h, i, settings, directions, fold_weights = NULL) {
  dat <- generate_data(i, m, h, settings, directions)
  seed <- settings$seed + 1000L * i + 10000000L * m + 10000L * h
  target <- list(x = dat$X0, y = dat$y0)
  sources <- Map(function(x, y) list(x = x, y = y), dat$X_sources, dat$y_sources)
  aw <- TransAW(data = target, sources = sources, seed = seed + 1L,
                coordinates = "log_weights", fold_weights = fold_weights)
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
  list(errors = errors, weights = weights)
}

replication_weights <- function(weights, i, m) {
  rows <- weights[weights$rep == i, ]
  rows <- rows[order(rows$direction, rows$source), ]
  directions <- c("A_to_B", "B_to_A")
  stopifnot(identical(rows$source, rep(seq_len(m), 2)),
            identical(rows$direction, rep(directions, each = m)))
  matrix(rows$weight, 2, m, byrow = TRUE,
         dimnames = list(directions, paste("Source", seq_len(m))))
}

# Figures 1 and 3 use the same simulated datasets. Keep each completed fit so
# that both figures can use it and an interrupted run can resume.
simulation_fits <- function(n, component, sources = c(5, 10, 15, 20),
                            heterogeneity = c(2, 4, 6), replications = 1:200,
                            use_manuscript_weights = FALSE) {
  component <- match.arg(component, c("errors", "weights"))
  stopifnot(length(n) == 1L, n %in% c(100, 300), length(sources) > 0L,
            all(sources %in% c(5, 10, 15, 20)), !anyDuplicated(sources),
            length(heterogeneity) > 0L, all(heterogeneity %in% c(2, 4, 6)),
            !anyDuplicated(heterogeneity), length(replications) > 0L,
            all(replications %in% 1:200), !anyDuplicated(replications))
  settings <- list(seed = 20260716L, p = 500L, s0 = 16L, n0 = 150L, n_k = n)
  if (use_manuscript_weights) {
    weights <- readRDS("figures/Main-Figure-1/manuscript-fold-weights.rds")
    folder <- file.path(Sys.getenv("TRANSAW_WORKDIR", "results"), "simulation-fits-at-manuscript-weights")
    dir.create(folder, recursive = TRUE, showWarnings = FALSE)
  } else {
    folder <- file.path(Sys.getenv("TRANSAW_WORKDIR", "results"), "simulation-fits")
    dir.create(folder, recursive = TRUE, showWarnings = FALSE)
  }
  records <- list()
  for (m in sources) {
    directions <- fixed_sparse_directions(m, settings$p, 6L, settings$seed)
    for (h in heterogeneity) {
      if (use_manuscript_weights) {
        setting <- weights[weights$n == n & weights$m == m & weights$h == h, ]
      }
      for (i in replications) {
        path <- file.path(folder, sprintf("n%d-m%d-h%d-rep%03d.rds", n, m, h, i))
        if (file.exists(path)) {
          fit <- readRDS(path)
        } else {
          fold_weights <- if (use_manuscript_weights) replication_weights(setting, i, m)
          fit <- fit_replication(n, m, h, i, settings, directions, fold_weights)
          temporary <- tempfile(tmpdir = folder)
          saveRDS(fit, temporary)
          if (!file.rename(temporary, path)) stop("Could not save ", path)
        }
        records[[length(records) + 1L]] <- fit[[component]]
      }
    }
  }
  do.call(rbind, records)
}
