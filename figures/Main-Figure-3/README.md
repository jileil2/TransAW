# Figure 3. Effective sample size by source compatibility

This figure uses the fits from Figure 1. Within each replication, the script normalizes the fitted source contributions and computes effective sample size in each compatibility group.

Run either command from the repository root. The first reads the manuscript data in `Main-Figure-3.rds`. The second fits the models with the TransAW package.

```sh
Rscript figures/Main-Figure-3/Main-Figure-3-from-rds.R
Rscript figures/Main-Figure-3/Main-Figure-3.R
```

The PDF and its TikZ source and saved R data are included here. The scripts write new files to `../TransAW-analysis/Main-Figure-3/` by default. See the [setup instructions](../../README.md#refit-the-models) before running a full analysis.
