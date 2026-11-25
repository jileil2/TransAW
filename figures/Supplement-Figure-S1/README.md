# Supplementary Figure S1. Source-weight penalty sensitivity

This figure accompanies Section S5 of the Supplementary Material. It covers the 12 settings with 100 observations per source, 5, 10, 15 or 20 sources, and heterogeneity levels 2, 4 or 6. Each setting has 200 replications, 150 target observations and 500 predictors.

The seven source-weight multipliers are 0, 0.0025, 0.005, 0.01, 0.02, 0.05 and 0.1. Each multiplier uses the same data and target folds within a replication. The points and error bars show mean squared coefficient error for Trans-AW and pointwise 95% Monte Carlo intervals. The dashed line and shaded band show the corresponding target-only LASSO mean and interval. Multiplier values occupy equally spaced positions.

From the repository root, regenerate the figure from the saved replication records.

```sh
Rscript figures/Supplement-Figure-S1/Supplement-Figure-S1-from-rds.R
```

The RDS file contains `fits` with 16,800 Trans-AW estimates of squared coefficient error and `target` with 2,400 target-only LASSO estimates. It retains the design identifiers and replication numbers. The original sensitivity fits used the archived manuscript implementation on Pegasus. The source-weight correction uses finite differences in centered log-weight coordinates. All fits at 0.01 reproduced the manuscript coefficient errors to numerical precision.

To refit the models using the installed TransAW package, run the analysis script.

```sh
Rscript figures/Supplement-Figure-S1/Supplement-Figure-S1.R
```

Completed fits are saved under `results/penalty-sensitivity/`. The figure and a table of means, Monte Carlo standard errors and intervals are written to `results/Supplement-Figure-S1/`. Set `TRANSAW_WORKDIR` to choose another location.

The figures use ggplot2, tikzDevice, pdflatex, TikZ, standalone, amsmath and mathpazo. Refitting requires the TransAW package and its dependencies. The common plotting and fitting functions are in [Figure S1](../Supplement-Figure-S1/).
