# Figure 1. Coefficient error with 100 observations per source

The plot compares four methods across four source counts and three heterogeneity levels. Each point is the mean squared coefficient error over 200 replications. The bars give Monte Carlo intervals.

Run either command from the repository root. The first reads the manuscript data in `Main-Figure-1.rds`. The second fits the models with the TransAW package.

```sh
Rscript figures/Main-Figure-1/Main-Figure-1-from-rds.R
Rscript figures/Main-Figure-1/Main-Figure-1.R
```

The PDF and its TikZ source and saved R data are included here. The scripts write new files to `../TransAW-analysis/Main-Figure-1/` by default. For dependencies and instructions on sharing fits between items, see the [method guide](../../method/README.md).
