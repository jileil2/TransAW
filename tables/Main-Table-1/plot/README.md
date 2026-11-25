# Companion plot for Table 1

This figure uses the 2,400 simulation datasets with 100 observations per source. Rows represent compatible, mildly compatible, and non-compatible sources; columns represent heterogeneity levels 2, 4, and 6. Points are means over 200 replications per setting, with 95% Monte Carlo intervals for the means.

Within each replication, the script normalizes each method's source weights and computes category effective sample size using the definition in Section 4.

Run from the repository root to reproduce the figure from saved results:

```sh
Rscript tables/Main-Table-1/plot/borrowing-plot-from-rds.R
```

To refit the models and draw the figure:

```sh
Rscript tables/Main-Table-1/plot/borrowing-plot.R
```

The second command resumes completed simulation fits shared with Figure 1. See the [simulation instructions](../../../figures/Main-Figure-1/README.md#simulations) for dependencies and smaller runs. Outputs are written to `results/Main-Table-1/plot/`; set `TRANSAW_WORKDIR` to change this location. The [panels directory](panels/) retains the earlier standalone display and scripts.
