# Table 3. Full-sample source weights

The table summarizes the three transfer estimators fitted using all 364 target compounds and the nine source assays. Trans-AW weights are averaged over the two target folds. Trans-LASSO weights are normalized averages of inclusion indicators for the highest-weight candidate subset in each internal split. RIW-TL weights are normalized sums of observation weights within each source.

Run from the repository root:

```sh
Rscript tables/Main-Table-3/Main-Table-3-from-rds.R
```

To refit the models, run:

```sh
Rscript tables/Main-Table-3/Main-Table-3.R
```

The CSV and LaTeX table are written to `results/Main-Table-3/`. The refitted estimates are saved under `results/full-sample/` and reused by Table 4.
