# Individual simulation panels

These are the separate displays used in Figure 2. The saved replication records and individual vector figures are retained here.

| Panel | Data | Source sample size |
| --- | --- | --- |
| (a) Coefficient estimation | `coefficient-error-300.rds` | 300 |
| (b) Category effective sample size | `source-information-100.rds` | 100 |

Regenerate either individual display from the repository root:

```sh
Rscript figures/Main-Figure-2/panels/coefficient-error-300-from-rds.R
Rscript figures/Main-Figure-2/panels/source-information-100-from-rds.R
```

The corresponding scripts without `-from-rds` refit the models. They share the simulation cache with Figures 1 and 2. Outputs are written to `results/Main-Figure-2/panels/` by default.
