coef.TransAW <- function(object, ...) object$coefficients

predict.TransAW <- function(object, newdata, ...) {
  if (!is.null(object$formula) && is.data.frame(newdata)) {
    check_names(names(newdata), "Prediction data")
    if (!all(object$predictors %in% names(newdata))) stop("Prediction data are missing target predictors.")
    newdata <- newdata[, object$predictors, drop = FALSE]
  }
  x <- design_matrix(newdata, "Prediction data")
  x <- align_predictors(x, object$predictors, length(coef(object)), "Prediction data")
  as.numeric(x %*% coef(object))
}

summary.TransAW <- function(object, ...) {
  structure(list(n_target = sum(lengths(object$folds)), p = length(coef(object)),
                 nonzero = sum(coef(object) != 0), multiplier = object$multiplier,
                 sources = data.frame(rows = object$source_sizes, t(object$fold_weights),
                                      mean_weight = object$weights),
                 diagnostics = object$diagnostics), class = "summary.TransAW")
}

print.TransAW <- function(x, ...) {
  cat("Trans-AW fit with", sum(lengths(x$folds)), "target observations,",
      length(x$weights), "source(s), and", length(coef(x)), "predictors.\n")
  invisible(x)
}

print.summary.TransAW <- function(x, ...) {
  cat("Trans-AW fit with", x$n_target, "target observations and", x$nonzero,
      "nonzero coefficients among", x$p, "predictors.\n\nSource weights\n")
  print(x$sources)
  cat("\nFold diagnostics\n")
  print(x$diagnostics[, c("lambda_gamma", "effective_source_n", "hessian_floor_active",
                         "optimizer_status"), drop = FALSE])
  invisible(x)
}

plot.TransAW <- function(x, y, ...) {
  graphics::barplot(x$weights, ylab = "Mean source weight", ...)
}
