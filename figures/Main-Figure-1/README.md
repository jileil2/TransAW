# Figure 1. Coefficient error with 100 observations per source

The plot compares four methods across four source counts and three heterogeneity levels. Each point is the mean squared coefficient error over 200 replications. The bars give Monte Carlo intervals.

Run either command from the repository root. The first reads the manuscript data in `Main-Figure-1.rds`. The second fits the models with the TransAW package.

```sh
Rscript figures/Main-Figure-1/Main-Figure-1-from-rds.R
Rscript figures/Main-Figure-1/Main-Figure-1.R
```

The PDF and its TikZ source and saved R data are included here. The scripts write new files to `../TransAW-analysis/Main-Figure-1/` by default. See the [setup instructions](../../README.md#refit-the-models) before running a full analysis.

## Simulations

The simulations use 150 target observations, 500 predictors, and 100 or 300 observations per source. Each combination of source count and heterogeneity has 200 replications. The base seed is 20260716. Figures 1 and 3 use the same 2,400 datasets. Figure 2 uses the other 2,400.

For example, this command simulates the data, fits the four methods and draws Figure 1.

```sh
Rscript figures/Main-Figure-1/Main-Figure-1.R
```

For a smaller run, fit just the first replication with five sources and heterogeneity level two.

```r
source("figures/Main-Figure-1/fit-simulation.R")
simulation_fits(100, "errors", sources = 5, heterogeneity = 2, replications = 1)
```

Trans-AW computes the simulation correction by finite differences in centered log-weight coordinates. The selected predictors can change during the source-weight search, so a fresh search on another numerical platform can give different estimates.

To check a regression at the two source-weight vectors selected in the original simulation, set `use_manuscript_weights = TRUE`. This reads `figures/Main-Figure-1/manuscript-fold-weights.rds`, refits the regressions and target adjustments, and stores the fits in a separate directory.

```r
simulation_fits(100, "errors", sources = 5, heterogeneity = 2, replications = 1,
                use_manuscript_weights = TRUE)
```

In the Trans-LASSO simulation comparison, the target-only candidate uses cross-validation. The pooled candidates and their target adjustments use a zero penalty. RIW-TL uses the authors’ cross-validated thresholds. [Trans-LASSO code](https://github.com/saili0103/TransLasso) · [RIW-TL code](https://github.com/RIW-TL/Transfer-learning)
