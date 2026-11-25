# Table 1. Category effective sample size

The table compares Trans-AW, Trans-LASSO, and RIW-TL with 100 observations per source. Results are grouped by source count (`m = 5, 10, 15, 20`), then heterogeneity (`h = 2, 4, 6`). Entries are Monte Carlo means, with Monte Carlo standard errors in parentheses, over 200 replications per setting.

Within each replication, Trans-AW weights are averaged across its two target folds. For Trans-LASSO, the weight for each source is the sum of Q-aggregation weights over candidate subsets containing that source. RIW-TL weights are summed over retained observations within each source and across its three internal split directions. The weights are normalized across sources before calculating category effective sample size.

From the repository root, reproduce the table from the saved weights:

```sh
Rscript tables/Main-Table-1/Main-Table-1-from-rds.R
```

To refit the simulations:

```sh
Rscript tables/Main-Table-1/Main-Table-1.R
```

The second command reuses completed fits from Figure 1. See the [simulation instructions](../../figures/Main-Figure-1/README.md#simulations) for dependencies and smaller runs.

The scripts write a CSV and the manuscript's LaTeX table to `results/Main-Table-1/`. Set `TRANSAW_WORKDIR` to use another output directory. The LaTeX table uses `multirow` to center the group labels and the manuscript's Biometrika table macros. The [companion plot](plot/) is retained with its data and scripts.
