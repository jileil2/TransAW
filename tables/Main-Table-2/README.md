# Table 2. Full-sample source contributions

The table summarizes the three transfer estimators fitted using all 364 target compounds and the nine source assays. Trans-AW weights are averaged over the two target folds. Trans-LASSO contributions are normalized averages of inclusion indicators for the highest-weight candidate subset in each internal split. RIW-TL contributions are normalized sums of observation weights within each source.

Run from the repository root:

```sh
Rscript tables/Main-Table-2/Main-Table-2-from-rds.R
```

To refit the models, run:

```sh
Rscript tables/Main-Table-2/Main-Table-2.R
```

The CSV and LaTeX table are written to `results/Main-Table-2/`. The refitted estimates are saved under `results/full-sample/` and reused by Table 3.
