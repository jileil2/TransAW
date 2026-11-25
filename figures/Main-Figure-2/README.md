# Figure 2. Test error on held-out compounds

Each row contains root mean squared error on the 109 held-out compounds in one scaffold split. The plot compares four methods across 100 splits. RIW-TL returned predictions on 88 of them.

Run either command from the repository root. The first reads the manuscript data in `Main-Figure-2.rds`. The second fits the models with the TransAW package.

```sh
Rscript figures/Main-Figure-2/Main-Figure-2-from-rds.R
Rscript figures/Main-Figure-2/Main-Figure-2.R
```

The PDF and its TikZ source and saved R data are included here. The scripts write new files to `results/Main-Figure-2/` by default. See the [setup instructions](../../README.md#rerunning-the-analyses) before running a full analysis.
