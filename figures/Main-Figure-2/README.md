# Figure 2. Coefficient error with 300 observations per source

The plot uses the same simulation settings as Figure 1, with 300 observations per source. The file contains a squared coefficient error for each method and replication.

Run either command from the repository root. The first reads the manuscript data in `Main-Figure-2.rds`. The second fits the models with the TransAW package.

```sh
Rscript figures/Main-Figure-2/Main-Figure-2-from-rds.R
Rscript figures/Main-Figure-2/Main-Figure-2.R
```

The PDF and its TikZ source and saved R data are included here. The scripts write new files to `results/Main-Figure-2/` by default. See the [setup instructions](../../README.md#rerunning-the-analyses) before running a full analysis.
