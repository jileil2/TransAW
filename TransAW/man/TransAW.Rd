\name{TransAW}
\alias{TransAW}
\alias{print.TransAW}
\alias{summary.TransAW}
\alias{print.summary.TransAW}
\alias{coef.TransAW}
\alias{predict.TransAW}
\alias{plot.TransAW}
\title{Fit a Target Linear Regression with Adaptive Source Weights}
\description{Estimate target regression coefficients from one target sample and
one or more source samples using two-fold cross-fitting.}
\usage{
TransAW(formula = NULL, data, sources, multiplier = 0.01,
        seed = 1L, nfolds = 5L, shared_design = FALSE,
        fold_weights = NULL, coordinates = c("weights", "log_weights"))

\method{predict}{TransAW}(object, newdata, ...)
\method{coef}{TransAW}(object, ...)
\method{summary}{TransAW}(object, ...)
\method{plot}{TransAW}(x, y, ...)
}
\arguments{
\item{formula}{An additive formula specifying a numeric response and numeric
predictor columns, such as \code{y ~ . - 1} or \code{y ~ x1 + x2 - 1}.
Specify a zero intercept. Omit the formula for matrix inputs.}
\item{data}{Target data frame for the formula, or a list with a numeric
matrix \code{x} and a numeric response vector \code{y}. Supply at least
12 target observations and two predictors. All values used must be finite.}
\item{sources}{A list of source cohorts, each in the target format.
Source names label fitted weights. Supply at least one row per source and
six pooled source rows. Use the same predictors and units in each cohort.
Named predictors are aligned by name. Unnamed matrices are aligned by position.}
\item{multiplier}{Nonnegative weight-penalty multiplier. The default 0.01
was selected in the research simulation. Zero removes this penalty.}
\item{seed}{Nonnegative integer controlling the outer split and Lasso folds.
The fit preserves the caller's random-number state.}
\item{coordinates}{Coordinates for the orthogonal correction. The kinase
analysis uses analytic derivatives in the source weights (the default).
The simulation uses finite differences in centered log-weight coordinates.
Numerical Hessian stabilization is applied in the chosen coordinates.}
\item{fold_weights}{Optional matrix for replaying a previous weight search.
Use the original data, row order and seed. Rows must be named A_to_B and B_to_A
and columns must match the source names. Each row sums to one. The method
recomputes the source regression, orthogonal correction and target adjustment
at those weights. The default estimates new weights.}
\item{shared_design}{Use the common-design calculation for source screens with
identical predictor matrices in the same row order. Source cross-validation
still uses all stacked observations. The kinase analysis uses this option.}
\item{nfolds}{Requested number of Lasso cross-validation folds (at least three).
The implementation caps this at the larger of three and one tenth of the
current sample size, rounded down.}
\item{object, x}{A fitted TransAW model.}
\item{newdata}{A numeric design matrix or data frame for new observations.
For a formula fit, data frames may contain additional columns.}
\item{y}{Unused in a source-weight plot.}
\item{...}{Additional arguments. The plot passes these to \code{barplot}.}
}
\details{
The estimator fits Gaussian linear models through the origin without automatic
predictor standardization. Cross-validation at pooled weights selects a common
source Lasso penalty. Each candidate source allocation determines a weighted
Lasso support and a weighted least-squares refit on that support. Starting at
weights proportional to source sizes, COBYLA searches the simplex using one
target fold's mean squared prediction error plus a weighted squared deviation
from the starting allocation. The penalty coefficient is the multiplier times
the learning fold's response variance (mean squared deviation from its mean,
floored at \code{1e-10}). Each observation in source k receives its source's
weight divided by its sample size, with a small numerical weight floor in the
Lasso solver.

The opposite fold supplies the orthogonal correction for source-weight estimation
and the sparse Lasso adjustment to the target residuals. The method swaps the
two folds and averages the final coefficient vectors. A single source has unit
weight. All design columns should be on scientifically appropriate common
scales. Lasso cross-validation requires usable predictor and response variation
in its training subsets.
}
\value{
\code{TransAW()} returns an object of class \code{TransAW} with components
\item{coefficients}{Final averaged target coefficients.}
\item{weights, fold_weights}{Mean source weights and a matrix with each
direction's weights. Row A_to_B learns weights on fold A and adjusts on B.}
\item{diagnostics}{One row per direction with fold sizes, penalized objective,
optimizer status, effective source sample size, score norm and Hessian diagnostics.}
\item{folds}{Target row indices for each half.}
\item{source_lambda, multiplier}{Pooled-source Lasso penalty and weight-penalty multiplier.}
\item{source_sizes, predictors, formula, call}{Source sample sizes, target
predictor names (or NULL), supplied formula and matched call.}
\code{coef} returns the coefficient vector. \code{predict} returns one numeric
prediction per row. \code{summary} returns the model dimensions, source-weight
table, penalty multiplier and fold diagnostics. \code{plot} displays the mean
source weights and invisibly returns bar positions.
}
\examples{
set.seed(3)
sample_data <- function(n, b) {
  x <- matrix(rnorm(3 * n), ncol = 3)
  list(x = x, y = drop(x \%*\% b) + rnorm(n))
}
target <- sample_data(60, c(1, -1, 0))
sources <- list(first = sample_data(80, c(1, -1, 0)),
                second = sample_data(65, c(-1, 1, 0)))
fit <- TransAW(data = target, sources = sources)
summary(fit)
predict(fit, target$x[1:3, , drop = FALSE])
}
