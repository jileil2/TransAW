# TransAW

**TransAW** is an R package for **adaptive source weighting in high-dimensional linear regression**. It estimates a target regression coefficient using data from multiple source populations, which may differ from the target and from one another.

Rather than deciding which sources to include or assigning them equal weight, Trans-AW estimates **continuous source weights from their predictive performance in the target sample**. The weights balance agreement with the target against the precision gained from combining source data. Since the target sample is also used to estimate these weights, Trans-AW uses orthogonalization and cross-fitting to limit the effect of weight-estimation error. A final sparse adjustment accounts for differences between the weighted source regression and the target regression.

## How Trans-AW works

The estimator has four steps:

1. **Bilevel estimation.** Source weights are chosen to minimize target prediction error, with a penalty favoring a larger effective source sample size. For each candidate set of weights, the source regression is estimated by weighted LASSO followed by least squares on the selected variables.
2. **Orthogonalization.** An orthogonalized source coefficient removes the first-order effect of estimating the source weights. Two-fold cross-fitting separates the target observations used to estimate the weights from those used to evaluate the score and Hessian.
3. **Sparse target adjustment.** A LASSO regression on the held-out target fold estimates the remaining source–target coefficient difference, allowing the target data to focus on this difference rather than estimating the full coefficient vector from scratch.
4. **Final estimator.** The two target folds exchange roles, and the resulting coefficient estimates are averaged.

The source weights are **nonnegative and sum to one**. They weight the source regression losses.

The package accompanies *Adaptive Weighting of Sources in Transfer Learning for High-Dimensional Linear Regression*.

## Installation

Install the package from GitHub:

```r
install.packages("remotes")
remotes::install_github("jileil2/TransAW", subdir = "TransAW")
library(TransAW)
```

The package uses `glmnet` and `nloptr` (`nloptr >= 2.2.0`).

## Example

The target and source datasets must use the same predictors, but may have different sample sizes and regression coefficients. Here, one source resembles the target and the other has different regression coefficients.

```r
library(TransAW)

set.seed(42)
simulate_cohort <- function(n, beta) {
  x <- matrix(rnorm(n * length(beta)), nrow = n)
  colnames(x) <- paste0("x", seq_along(beta))
  data.frame(y = drop(x %*% beta) + rnorm(n), x)
}

target <- simulate_cohort(90, c(1, -1, 0, 0))
sources <- list(
  similar   = simulate_cohort(100, c(1, -1, 0, 0)),
  different = simulate_cohort(70, c(-1, 1, 1, 0))
)

fit <- TransAW(y ~ . - 1, data = target, sources = sources, seed = 42)

summary(fit)                            # Source weights and diagnostics
coef(fit)                               # Estimated target regression coefficients
fit$fold_weights                        # Weights estimated on each target fold
predict(fit, newdata = target[1:3, -1]) # Target predictions
plot(fit)                               # Mean source weights
```

The estimated source weights describe how Trans-AW combines the two source datasets; the fitted regression coefficients are intended for prediction in the target population.

## Input data

`TransAW()` accepts either data frames specified by a formula or lists containing predictor matrices and response vectors.

For **data frames**, the target and every source must contain a numeric response and the same numeric predictors. The regression has no intercept, so use `- 1` in the formula (for example, `y ~ . - 1`).

For **matrix inputs**, omit the formula:

```r
fit <- TransAW(
  data = list(x = target_x, y = target_y),
  sources = list(
    source1 = list(x = source1_x, y = source1_y),
    source2 = list(x = source2_x, y = source2_y)
  )
)
```

Named predictors are matched across datasets by column name; unnamed matrices must use the same column order. Predictors should have consistent definitions and scales across populations. **The package does not automatically standardize predictors.** It requires at least 12 target observations, two predictors, and six observations across the sources; all predictors and responses must be finite numeric values.

## Fitted results

| Command or component | Result |
| --- | --- |
| `coef(fit)` | Final target regression coefficients |
| `predict(fit, newdata)` | Predicted responses for new observations |
| `fit$weights` | Mean estimated weight for each source |
| `fit$fold_weights` | Source weights from the two target learning folds |
| `summary(fit)` | Estimated source weights and numerical diagnostics |
| `fit$diagnostics` | Optimization status, effective source sample size, and orthogonalization diagnostics |
| `plot(fit)` | Bar plot of mean source weights |

The main options are `multiplier` (source-weight penalty multiplier; default `0.01`), `seed`, and `nfolds` (LASSO cross-validation folds). For sources sharing an identical design matrix in the same row order, `shared_design = TRUE` enables a specialized calculation. The `coordinates` and `fold_weights` arguments are intended for alternative orthogonalization calculations and reproducibility checks.

For complete argument definitions and further examples, run:

```r
?TransAW
```

A standalone example is available in [`inst/examples/getting-started.R`](inst/examples/getting-started.R).

## Reference

Lin, J., Wang, H. J., Liu, M., and Wang, W. *Adaptive Weighting of Sources in Transfer Learning for High-Dimensional Linear Regression*. Manuscript.

## License

GPL-3.
