# TransAW

TransAW estimates a linear regression for a target population using one or more source datasets. It learns a weight for each source from how well the source regressions predict the target outcome. The weights are nonnegative and sum to one. A source weight describes its share of the source fit. It is not a probability that two populations share the same regression.

## Installation

Install the dependencies once in R.

```r
install.packages(c("glmnet", "nloptr"))
```

From the directory containing the package folder, run the following in a terminal.

```sh
R CMD INSTALL TransAW
```

## Fit and predict

Each data frame has one row per observation, a numeric outcome, and the same numeric predictors. The estimator fits through the origin and uses the supplied measurement scales. Write `- 1` in the formula to specify this model explicitly. Use the same coding and preprocessing for training and prediction.

```r
library(TransAW)
set.seed(42)
cohort <- function(n, slopes) {
  x <- matrix(rnorm(n * length(slopes)), nrow = n)
  colnames(x) <- paste0("x", seq_along(slopes))
  data.frame(y = as.numeric(x %*% slopes + rnorm(n)), x)
}
target <- cohort(90, c(1, -1, 0, 0))
sources <- list(similar = cohort(100, c(1, -1, 0, 0)),
                shifted = cohort(70, c(-1, 1, 1, 0)))
fit <- TransAW(y ~ . - 1, data = target, sources = sources, seed = 42)
summary(fit)
fit$fold_weights
coef(fit)
predict(fit, newdata = target[1:3, -1])
plot(fit)
```

For matrix inputs, omit the formula and pass each cohort as
`list(x = predictor_matrix, y = response_vector)`. Named columns are matched
to the target by name. For unnamed matrices, use the same column order throughout.

## How the fit works

1. Cross-validation on the pooled sources chooses a Lasso penalty. At each candidate set of source weights, the method refits the weighted Lasso and estimates coefficients on the selected predictors.
2. The first target half supplies the prediction error for choosing source weights. COBYLA minimizes that error plus a penalty for moving away from weights proportional to source sample size. The default multiplier of 0.01 comes from the research simulation. Within each learning fold, it multiplies the target response variance, floored at 1e-10.
3. The other half supplies the orthogonal correction for weight estimation and a sparse regression of the remaining target residuals. The method swaps the halves and averages their final coefficients.

`fit$weights` averages the two sets of source weights. Predictions use the averaged final coefficients. `fit$diagnostics` includes the fold-specific penalty, optimizer status, and whether the numerical stabilization of the orthogonal correction was active.

The kinase example in the manuscript uses `shared_design = TRUE` because every source has the same predictor matrix. The simulation scripts use `coordinates = "log_weights"` for the orthogonal correction. To repeat a fit at its saved weights, pass `fold_weights = fit$fold_weights` with the original seed and row order.

In R, open `?TransAW` for the data requirements and return values. The [getting-started example](inst/examples/getting-started.R) runs with simulated data.
