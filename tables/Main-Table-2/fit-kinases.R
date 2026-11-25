library(TransAW)
source("tables/Main-Table-2/kinase-design.R")
source("methods/target-lasso.R")
source("methods/riw-tl.R")
source("tables/Main-Table-2/kinase-trans-lasso.R")

fit_split <- function(i, panel, partitions) {
  d <- prepare_split(panel, partitions[partitions$split == i, ])
  seed <- 20261118L
  fit <- TransAW(data = d$target, sources = d$sources, shared_design = TRUE, seed = seed)
  predict_target <- function(beta) d$mean + d$sd * drop(d$newx %*% beta)
  dat <- benchmark_input(d$target, d$sources)
  target <- lasso_cv(dat$X0, dat$y0, seed)
  tl <- fit_paper_trans_lasso(dat, seed, return_sources = TRUE)
  selected <- sapply(tl$orientations, function(model) {
    model$membership[which.max(model$probability), ]
  })

  # At equal source weights, the common penalty selects the pooled Lasso support.
  # The fixed weights require only the post-Lasso refit and the target adjustments.
  x <- do.call(rbind, dat$X_sources)
  y <- unlist(dat$y_sources, use.names = FALSE)
  pooled <- glmnet::glmnet(x, y, lambda = fit$source_lambda, intercept = FALSE, standardize = FALSE)
  active <- which(abs(as.numeric(pooled$beta)) > 1e-8)
  offset <- numeric(ncol(x))
  if (length(active)) {
    design <- x[, active, drop = FALSE]
    gram <- crossprod(design) / nrow(x)
    diag(gram) <- diag(gram) + 1e-8
    offset[active] <- solve(gram, crossprod(design, y) / nrow(x))
  }
  residual <- dat$y0 - drop(dat$X0 %*% offset)
  adjust <- function(rows, seed) lasso_cv(dat$X0[rows, , drop = FALSE], residual[rows], seed)
  equal <- offset + (adjust(fit$folds$B, seed + 111L) + adjust(fit$folds$A, seed + 122L)) / 2

  # Record a failed RIW fit as missing. All other methods still count on this split.
  riw <- tryCatch(riw_fit(dat, seed), error = function(e) {
    message("RIW-TL on split ", i, ": ", conditionMessage(e))
    list(beta = rep(NA_real_, ncol(x)), mass = rep(NA_real_, length(kinases)),
         error = conditionMessage(e))
  })
  p <- data.frame(split = i, compound = d$compounds, observed = d$observed,
                  target = predict_target(target), trans_lasso = predict_target(tl$beta),
                  riw = predict_target(riw$beta), trans_aw = predict_target(coef(fit)),
                  equal = predict_target(equal))
  w <- data.frame(split = i, source = kinases, fold_A = fit$fold_weights[1, ],
                  fold_B = fit$fold_weights[2, ], selected_A = selected[, 1],
                  selected_B = selected[, 2], riw = riw$mass)
  list(predictions = p, weights = w, riw_error = riw$error)
}

kinase_fits <- function(component, splits = 1:100) {
  component <- match.arg(component, c("predictions", "weights"))
  stopifnot(length(splits) > 0L, all(splits %in% 1:100), !anyDuplicated(splits))
  panel <- read.csv("data/kinase-panel.csv.gz", check.names = FALSE)
  partitions <- read.csv("data/scaffold-splits.csv.gz")
  folder <- file.path(Sys.getenv("TRANSAW_WORKDIR", "results"), "kinase-fits")
  dir.create(folder, recursive = TRUE, showWarnings = FALSE)
  records <- lapply(splits, function(i) {
    path <- file.path(folder, sprintf("split-%03d.rds", i))
    if (file.exists(path)) {
      fit <- readRDS(path)
    } else {
      fit <- fit_split(i, panel, partitions)
      temporary <- tempfile(tmpdir = folder)
      saveRDS(fit, temporary)
      if (!file.rename(temporary, path)) stop("Could not save ", path)
    }
    fit[[component]]
  })
  do.call(rbind, records)
}
