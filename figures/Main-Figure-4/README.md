# Figure 4. Test error on held-out compounds

Each row contains mean absolute error on the 109 held-out compounds in one scaffold split. The plot compares four methods across 100 splits. RIW-TL returned predictions on 88 of them.

Run either command from the repository root. The first reads the manuscript data in `Main-Figure-4.rds`. The second fits the models with the TransAW package.

```sh
Rscript figures/Main-Figure-4/Main-Figure-4-from-rds.R
Rscript figures/Main-Figure-4/Main-Figure-4.R
```

The PDF and its TikZ source and saved R data are included here. The scripts write new files to `../TransAW-analysis/Main-Figure-4/` by default. For dependencies and instructions on sharing fits between items, see the [method guide](../../method/README.md).
