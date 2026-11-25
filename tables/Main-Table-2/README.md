# Table 2. Mean test error across scaffold splits

The table reports the mean and Monte Carlo standard error of split-level test RMSE for five methods, including Trans-AW with equal source weights. RIW-TL produced predictions for 88 splits; the other methods produced predictions for 100.

Run either command from the repository root. The first reads the manuscript data in `Main-Table-2.rds`. The second fits the models with the TransAW package.

```sh
Rscript tables/Main-Table-2/Main-Table-2-from-rds.R
Rscript tables/Main-Table-2/Main-Table-2.R
```

The CSV and LaTeX table and saved R data are included here. The scripts write new files to `results/Main-Table-2/` by default. See the [setup instructions](../../README.md#rerunning-the-analyses) before running a full analysis.

## Kinase analysis

The nine source screens measured the same compounds. Trans-AW fits them with a common design matrix and uses analytic derivatives in the source weights. The target training set determines predictor scaling, the intercept and response scaling. Each historical screen is centered separately. Prediction errors are measured in percentage points of inhibition. The equal-weight comparison uses the same source penalty, folds and residual adjustment as the adaptive fit.

Figure 2 and Table 2 share the same 100 scaffold splits. Tables 3 and 4 use the full sample. For example, run Table 2 from the measurements with the following command.

```sh
Rscript tables/Main-Table-2/Main-Table-2.R
```

To examine a single split in R, run the following commands.

```r
source("tables/Main-Table-2/fit-kinases.R")
predictions <- kinase_fits("predictions", splits = 1)
```

Trans-LASSO uses two held-out thirds and eight-fold tuning of candidate models. RIW-TL returned predictions on 88 splits in the manuscript analysis. Each summary uses the completed splits for that method.
