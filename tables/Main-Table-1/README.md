# Table 1. Mean test error across scaffold splits

The table reports the mean and Monte Carlo standard error of split-level test MAE for five methods, including Trans-AW with equal source weights. RIW-TL contributes 88 splits. Each other method contributes 100.

Run either command from the repository root. The first reads the manuscript data in `Main-Table-1.rds`. The second fits the models with the TransAW package.

```sh
Rscript tables/Main-Table-1/Main-Table-1-from-rds.R
Rscript tables/Main-Table-1/Main-Table-1.R
```

The CSV and LaTeX table and saved R data are included here. The scripts write new files to `../TransAW-analysis/Main-Table-1/` by default. For dependencies and instructions on sharing fits between items, see the [method guide](../../method/README.md).
