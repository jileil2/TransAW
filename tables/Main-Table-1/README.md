# Table 1. Mean test error across scaffold splits

The table reports the mean and Monte Carlo standard error of split-level test RMSE for five methods, including Trans-AW with equal source weights. RIW-TL contributes 88 splits. Each other method contributes 100.

Run either command from the repository root. The first reads the manuscript data in `Main-Table-1.rds`. The second fits the models with the TransAW package.

```sh
Rscript tables/Main-Table-1/Main-Table-1-from-rds.R
Rscript tables/Main-Table-1/Main-Table-1.R
```

The CSV and LaTeX table and saved R data are included here. The scripts write new files to `results/Main-Table-1/` by default. See the [setup instructions](../../README.md#rerunning-the-analyses) before running a full analysis.

## Kinase analysis

The nine source screens measured the same compounds. Trans-AW fits them with a common design matrix and uses analytic derivatives in the source weights. The target training set determines predictor scaling, the intercept and response scaling. Each historical screen is centered separately. Prediction errors are measured in percentage points of inhibition. The equal-weight comparison uses the same source penalty, folds and residual adjustment as the adaptive fit.

Figure 3 and Table 1 share the same 100 scaffold splits. Tables 2 and 3 use the full sample. For example, run Table 1 from the measurements with the following command.

```sh
Rscript tables/Main-Table-1/Main-Table-1.R
```

To examine a single split in R, run the following commands.

```r
source("tables/Main-Table-1/fit-kinases.R")
predictions <- kinase_fits("predictions", splits = 1)
```

Trans-LASSO uses two held-out thirds and eight-fold tuning of candidate models. RIW-TL returned predictions on 88 splits in the manuscript analysis. Each summary uses the completed splits for that method.
