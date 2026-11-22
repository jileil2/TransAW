TransAW <- function(formula = NULL, data, sources, multiplier = 0.01,
                    seed = 1L, nfolds = 5L, shared_design = FALSE,
                    fold_weights = NULL, coordinates = c("weights", "log_weights")) {
  coordinates <- match.arg(coordinates)
  call <- match.call()
  columns <- if (!is.null(formula)) formula_columns(formula, data)
  target <- read_cohort(data, columns, "Target")
  if (nrow(target$x) < 12L || ncol(target$x) < 2L) {
    stop("Supply at least 12 target observations and two predictors for Lasso cross-validation.")
  }
  if (!is.list(sources) || is.data.frame(sources) || !length(sources)) {
    stop("Supply one or more cohorts in a list of sources.")
  }
  if (!is.numeric(multiplier) || length(multiplier) != 1L ||
      !is.finite(multiplier) || multiplier < 0) stop("multiplier must be finite and nonnegative.")
  check_integer(seed, 0, .Machine$integer.max - 122L, "seed")
  check_integer(nfolds, 3, .Machine$integer.max, "nfolds")
  source_names <- names(sources)
  if (is.null(source_names)) source_names <- paste("Source", seq_along(sources))
  check_names(source_names, "Sources")
  p <- ncol(target$x)
  predictors <- colnames(target$x)
  cohorts <- Map(function(s, label) {
    cohort <- read_cohort(s, columns, label)
    cohort$x <- align_predictors(cohort$x, predictors, p, label)
    cohort
  }, sources, source_names)
  sizes <- unname(vapply(cohorts, function(s) nrow(s$x), integer(1)))
  if (sum(sizes) < 6L) stop("Lasso cross-validation needs at least six pooled source rows.")
  stacked <- stack_sources(lapply(cohorts, "[[", "x"), lapply(cohorts, "[[", "y"))
  cfg <- list(p = p, nfolds = as.integer(nfolds), active_tol = 1e-4, coordinates = coordinates)
  # Some numerical dependencies initialize their RNG on first use.
  previous_seed <- get0(".Random.seed", envir = .GlobalEnv, inherits = FALSE)
  on.exit({
    if (is.null(previous_seed)) {
      rm(".Random.seed", envir = .GlobalEnv)
    } else {
      assign(".Random.seed", previous_seed, envir = .GlobalEnv)
    }
  }, add = TRUE)
  set.seed(as.integer(seed))
  perm <- sample.int(nrow(target$x))
  folds <- split(perm, rep(1:2, length.out = length(perm)))
  src <- select_trans_aw_source_map(stacked, sizes, cfg, seed)
  if (!is.logical(shared_design) || length(shared_design) != 1L || is.na(shared_design)) {
    stop("shared_design must be TRUE or FALSE.")
  }
  if (shared_design) src$shared_fit <- shared_source_fit(cohorts, src$lambda_src)
  if (!is.null(fold_weights)) {
    fold_weights <- validate_fold_weights(fold_weights, source_names)
  }
  direction <- function(learn, heldout, seed_offset, label) {
    y <- target$y[learn]
    cfg$lambda_gamma <- multiplier * max(mean((y - mean(y))^2), 1e-10)
    x_learn <- target$x[learn, , drop = FALSE]
    weights <- if (is.null(fold_weights)) {
      learn_weights(x_learn, y, stacked, sizes, src, cfg)
    } else {
      gamma <- as.numeric(fold_weights[label, ])
      value <- weight_criterion(gamma, x_learn, y, stacked, sizes, src, cfg)
      list(gamma = gamma, objective = value, status = "replayed fold weights")
    }
    x <- target$x[heldout, , drop = FALSE]
    y <- target$y[heldout]
    orth <- orthogonal_source_lasso(weights$gamma, stacked, sizes, x, y, src, cfg)
    beta <- fit_adjustment(x, y, orth$beta, cfg, seed + seed_offset + 100L)
    list(beta = beta, gamma = weights$gamma, diagnostics = data.frame(
      n_learning = length(learn), n_heldout = length(heldout),
      objective = weights$objective, optimizer_status = weights$status,
      effective_source_n = effective_source_n(weights$gamma, sizes), orth$diagnostics
    ))
  }
  fits <- list(A_to_B = direction(folds[[1]], folds[[2]], 11L, "A_to_B"),
               B_to_A = direction(folds[[2]], folds[[1]], 22L, "B_to_A"))
  weights <- do.call(rbind, lapply(fits, "[[", "gamma"))
  colnames(weights) <- source_names
  beta <- (fits[[1]]$beta + fits[[2]]$beta) / 2
  names(beta) <- if (is.null(predictors)) paste0("x", seq_len(p)) else predictors
  structure(list(call = call, coefficients = beta, weights = colMeans(weights),
                 fold_weights = weights, diagnostics = do.call(rbind, lapply(fits, "[[", "diagnostics")),
                 folds = stats::setNames(folds, c("A", "B")), multiplier = multiplier,
                 source_lambda = src$lambda_src, source_sizes = stats::setNames(sizes, source_names),
                 predictors = predictors, formula = formula),
            class = "TransAW")
}
