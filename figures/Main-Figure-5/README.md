# Figure 5. Contributions from the nine source kinases

The data contain source contributions for each of the 100 scaffold splits. The panels show the Trans-AW source weights, Trans-LASSO selection scores and RIW-TL observation weights, all as percentages.

Run either command from the repository root. The first reads the manuscript data in `Main-Figure-5.rds`. The second fits the models with the TransAW package.

```sh
Rscript figures/Main-Figure-5/Main-Figure-5-from-rds.R
Rscript figures/Main-Figure-5/Main-Figure-5.R
```

The PDF and its TikZ source and saved R data are included here. The scripts write new files to `../TransAW-analysis/Main-Figure-5/` by default. See the [setup instructions](../../README.md#refit-the-models) before running a full analysis.
