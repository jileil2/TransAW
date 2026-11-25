library(TransAW)
source("tables/Main-Table-2/kinase-design.R")
source("tables/Main-Table-2/kinase-trans-lasso.R")
source("methods/target-lasso.R")
source("methods/riw-tl.R")

fit_full_sample <- function() {
  folder <- file.path(Sys.getenv("TRANSAW_WORKDIR", "results"), "full-sample")
  dir.create(folder, recursive = TRUE, showWarnings = FALSE)
  path <- file.path(folder, "fit.rds")
  if (file.exists(path)) return(readRDS(path))

  panel <- read.csv("data/kinase-panel.csv.gz", check.names = FALSE)
  d <- prepare_kinases(panel)
  dat <- benchmark_input(d$target, d$sources)
  seed <- 20261118L
  aw <- TransAW(data = d$target, sources = d$sources, shared_design = TRUE, seed = seed)
  target <- lasso_cv(dat$X0, dat$y0, seed)
  tl <- fit_paper_trans_lasso(dat, seed, return_sources = TRUE)
  riw <- riw_fit(dat, seed)

  selected <- sapply(tl$orientations, function(fit) {
    fit$membership[which.max(fit$probability), ]
  })
  inclusion <- rowMeans(selected)
  weights <- data.frame(enzyme = kinases, trans_aw = aw$weights,
                       trans_lasso = inclusion / sum(inclusion), riw_tl = riw$mass)

  # Express coefficients on the original binary-predictor scale.
  beta <- matrix(0, 256, 4, dimnames = list(paste0("bit", 0:255),
                  c("target_only", "trans_aw", "trans_lasso", "riw_tl")))
  beta[d$retained_predictors, ] <- cbind(target, coef(aw), tl$beta, riw$beta) *
                                  d$sd / d$predictor_scale
  intercept <- d$mean - drop(colMeans(panel[paste0("bit", 0:255)]) %*% beta)
  fit <- list(coefficients = beta, intercept = intercept, source_weights = weights,
              seed = seed, n = nrow(panel), p = 256L,
              retained_predictors = d$retained_predictors)
  temporary <- tempfile(tmpdir = folder)
  saveRDS(fit, temporary)
  if (!file.rename(temporary, path)) stop("Could not save ", path)
  fit
}
