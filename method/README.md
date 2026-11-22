# Refit the models

Run the commands below from the repository root. The TransAW package implements the estimator. The scripts here generate simulation data, prepare the kinase training and test sets, and fit the comparison methods.

## Setup

```sh
Rscript -e 'install.packages(c("glmnet", "nloptr", "ks", "ncvreg", "mvtnorm", "ggplot2", "tikzDevice"), repos = "https://cloud.r-project.org")'
R CMD INSTALL TransAW
Rscript method/get-reference-code.R
```

The last command downloads the two comparison implementations at fixed revisions. To draw the figures, install a TeX distribution that includes `pdflatex`, TikZ, standalone, mathpazo and newpx.

## Simulations

The simulations use 150 target observations, 500 predictors, and 100 or 300 observations per source. Each combination of source count and heterogeneity has 200 replications. The base seed is 20260716. Figures 1 and 3 use the same 2,400 datasets. Figure 2 uses the other 2,400.

For example, this command simulates the data, fits the four methods and draws Figure 1.

```sh
Rscript figures/Main-Figure-1/Main-Figure-1.R
```

For a smaller run, fit just the first replication with five sources and heterogeneity level two.

```r
source("method/simulation/fit-simulation.R")
simulation_fits(100, "errors", sources = 5, heterogeneity = 2, replications = 1)
```

Trans-AW computes the simulation correction by finite differences in centered log-weight coordinates. The selected predictors can change during the source-weight search, so a fresh search on another numerical platform can give different estimates.

In the Trans-LASSO simulation comparison, the target-only candidate uses cross-validation. The pooled candidates and their target adjustments use a zero penalty. RIW-TL uses the authors’ cross-validated thresholds. [Trans-LASSO code](https://github.com/saili0103/TransLasso) · [RIW-TL code](https://github.com/RIW-TL/Transfer-learning)

## Kinase analysis

The nine source screens measured the same compounds. Trans-AW fits them with a common design matrix and uses analytic derivatives in the source weights. The target training set determines predictor scaling, the intercept and response scaling. Each historical screen is centered separately. Prediction errors are measured in percentage points of inhibition. The equal-weight comparison uses the same source penalty, folds and residual adjustment as the adaptive fit.

Figures 4–5 and Tables 1–2 share the same 100 scaffold splits. For example, run Table 1 from the measurements with the following command.

```sh
Rscript tables/Main-Table-1/Main-Table-1.R
```

To examine a single split in R, run the following commands.

```r
source("method/real-data-analysis/fit-kinases.R")
predictions <- kinase_fits("predictions", splits = 1)
```

Trans-LASSO uses two held-out thirds and eight-fold tuning of candidate models. RIW-TL returned predictions on 88 splits in the manuscript analysis. Each summary uses the completed splits for that method.

## Where files are written

By default, scripts save fits in `../TransAW-analysis/simulation-fits/` and `../TransAW-analysis/kinase-fits/`. A later script reuses the completed fits in that directory. Each figure or table gets its own subdirectory for the files it produces. To use a different location for a new run, set `TRANSAW_WORKDIR` before running the scripts.

```sh
export TRANSAW_WORKDIR="$HOME/TransAW-analysis"
```
