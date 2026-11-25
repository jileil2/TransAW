# Table 3. Fingerprint coefficients and environment coverage

The table contains full-sample Trans-AW and target-only LASSO coefficients for bits 204, 19, and 64. Coverage is the number of bit-positive compounds containing the highlighted molecular environment divided by the number of bit-positive compounds.

Run from the repository root:

```sh
Rscript tables/Main-Table-3/Main-Table-3-from-rds.R
```

This uses `data/full-sample-fit.rds` and `data/selected-environments.csv`. To use a fresh full-sample fit, run `Rscript tables/Main-Table-3/Main-Table-3.R`. The CSV and LaTeX output are written to `results/Main-Table-3/`.
