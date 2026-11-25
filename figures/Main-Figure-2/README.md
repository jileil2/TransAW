# Figure 2. Coefficient estimation and borrowing across sources

Part (a) shows squared coefficient error with 300 observations per source for Trans-AW, Trans-LASSO, RIW-TL, and target-only LASSO. Part (b) shows category effective sample size with 100 observations per source for the three transfer estimators. Both parts use 200 Monte Carlo replications per setting; points are means and error bars are 95% Monte Carlo intervals for those means.

The three columns represent heterogeneity levels 2, 4, and 6. In part (b), the rows represent compatible, mildly compatible, and non-compatible sources. The methods' source contributions are normalized within each replication before calculating category effective sample size.

Run from the repository root to reproduce the figure from the saved results:

```sh
Rscript figures/Main-Figure-2/Main-Figure-2-from-rds.R
```

To refit both simulation settings and draw the figure:

```sh
Rscript figures/Main-Figure-2/Main-Figure-2.R
```

The second command resumes completed simulation fits, including those used for Figure 1. See the [simulation instructions](../Main-Figure-1/README.md#simulations) for dependencies and smaller runs.

Outputs are written to `results/Main-Figure-2/`: the vector PDF, its TikZ source, and the numerical summaries for both panels. Set `TRANSAW_WORKDIR` to change the output location. The [panels directory](panels/) retains the individual figures, saved replication records, and scripts for drawing each panel separately.
