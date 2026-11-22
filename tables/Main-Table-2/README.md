# Table 2. Average contribution of each source kinase

The table averages the source contributions in Figure 5 over the completed splits for each method. The entries are percentages.

Run either command from the repository root. The first reads the manuscript data in `Main-Table-2.rds`. The second fits the models with the TransAW package.

```sh
Rscript tables/Main-Table-2/Main-Table-2-from-rds.R
Rscript tables/Main-Table-2/Main-Table-2.R
```

The CSV and LaTeX table and saved R data are included here. The scripts write new files to `../TransAW-analysis/Main-Table-2/` by default. See the [setup instructions](../../README.md#refit-the-models) before running a full analysis.
