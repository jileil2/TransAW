# Standalone borrowing display

This directory retains the original category effective sample size display and replication records for 100 observations per source.

Run from the repository root:

```sh
Rscript tables/Main-Table-1/plot/panels/source-information-100-from-rds.R
```

The corresponding script without `-from-rds` refits the models. Outputs are written to `results/Main-Table-1/plot/panels/` by default.
