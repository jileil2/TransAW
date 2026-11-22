check_names <- function(x, label) {
  if (anyNA(x) || any(!nzchar(x)) || anyDuplicated(x)) {
    stop(label, " must have unique, nonempty names.", call. = FALSE)
  }
}

design_matrix <- function(x, label) {
  if (is.data.frame(x) && all(vapply(x, is.numeric, logical(1)))) x <- as.matrix(x)
  if (!is.matrix(x) || !is.numeric(x) || any(!is.finite(x))) {
    stop(label, " must be a finite numeric matrix or numeric data frame.", call. = FALSE)
  }
  check_names(colnames(x), label)
  x
}

formula_columns <- function(formula, data) {
  if (!inherits(formula, "formula") || length(formula) != 3L ||
      !is.symbol(formula[[2L]]) || !is.data.frame(data)) {
    stop("Supply a response formula and a target data frame.", call. = FALSE)
  }
  design <- stats::terms(formula, data = data, specials = "offset")
  if (attr(design, "intercept") != 0L) {
    stop("Trans-AW fits through the origin. Specify the model as y ~ . - 1.", call. = FALSE)
  }
  variables <- as.list(attr(design, "variables"))[-1L]
  if (!all(vapply(variables, is.symbol, logical(1))) || any(attr(design, "order") != 1L)) {
    stop("Use additive numeric predictor columns in the formula.", call. = FALSE)
  }
  factors <- attr(design, "factors")
  if (!length(factors)) stop("The formula must select at least two predictors.")
  selected <- variables[rowSums(factors != 0) > 0L]
  predictors <- vapply(selected, as.character, character(1))
  response <- as.character(formula[[2L]])
  if (response %in% predictors) stop("The response cannot also be a predictor.")
  list(response = response, predictors = predictors)
}

read_cohort <- function(data, columns, label) {
  if (is.null(columns)) {
    if (!is.list(data) || !all(c("x", "y") %in% names(data))) {
      stop(label, " must contain x and y.", call. = FALSE)
    }
    x <- data[["x"]]
    y <- data[["y"]]
  } else {
    required <- c(columns$response, columns$predictors)
    if (!is.data.frame(data) || !all(required %in% names(data))) {
      stop(label, " must contain the response and all target predictors.", call. = FALSE)
    }
    check_names(names(data), label)
    x <- data[, columns$predictors, drop = FALSE]
    y <- data[[columns$response]]
  }
  x <- design_matrix(x, label)
  if (!nrow(x) || !is.numeric(y) || !is.null(dim(y)) ||
      length(y) != nrow(x) || any(!is.finite(y))) {
    stop(label, " needs one finite numeric response per row.", call. = FALSE)
  }
  list(x = x, y = as.numeric(y))
}

align_predictors <- function(x, reference, p, label) {
  if (ncol(x) != p || is.null(reference) != is.null(colnames(x)) ||
      !setequal(colnames(x), reference)) {
    stop(label, " must have the same predictors as the target.", call. = FALSE)
  }
  if (is.null(reference)) x else x[, reference, drop = FALSE]
}

check_integer <- function(x, lower, upper, label) {
  if (!is.numeric(x) || length(x) != 1L || !is.finite(x) ||
      x != floor(x) || x < lower || x > upper) {
    stop(label, " must be an integer between ", lower, " and ", upper, ".", call. = FALSE)
  }
}
