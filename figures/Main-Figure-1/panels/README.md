# Individual coefficient-error panels

The original displays and replication records for 100 and 300 observations per source are retained here. Figure 1 combines them using a common vertical scale and legend.

Run either command from the repository root:

```sh
Rscript figures/Main-Figure-1/panels/coefficient-error-100-from-rds.R
Rscript figures/Main-Figure-1/panels/coefficient-error-300-from-rds.R
```

The corresponding scripts without `-from-rds` refit the models. Outputs are written to `results/Main-Figure-1/panels/` by default.
