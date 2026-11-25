# Trans-AW

This repository accompanies *Adaptive Weighting of Sources in Transfer Learning for High-Dimensional Linear Regression* by Jilei Lin, Huixia Judy Wang, Mingrui Liu, and Wenyi Wang. It contains the **TransAW** R package, simulation code, and the data and scripts used to produce the figures and tables in the manuscript.

## Overview

Transfer learning can improve estimation when the target sample is small and related source datasets are available. However, source populations may differ from the target, and treating all sources equally—or selecting a subset of sources—may not make the best use of the available information.

**Trans-AW** (Transfer Learning with Adaptive Weighting) estimates a sparse linear regression for the target population using source weights chosen to minimize target prediction error. Instead of assigning equal weights or making a binary decision about which sources to include, it allows each source to contribute according to its usefulness for the target. A penalty on the weights controls the effective source sample size and stabilizes their estimation.

The estimator has four steps: **(i)** bilevel estimation of source weights and a weighted source regression, using weighted LASSO followed by least squares on the selected variables; **(ii)** Neyman orthogonalization with cross-fitting to remove the first-order effect of estimating the source weights; **(iii)** a sparse target adjustment to account for remaining source–target differences; and **(iv)** averaging the two cross-fitted coefficient estimates.

## R package

Install the package directly from GitHub:

```r
install.packages("remotes")
remotes::install_github("jileil2/TransAW", subdir = "TransAW")
library(TransAW)
```

The package accepts a target dataset and one or more source datasets with the same numeric predictors. It returns estimated target regression coefficients, predictions, source weights, and diagnostics for the two cross-fitting directions. See the [package README](TransAW/README.md) for a reproducible example and [R documentation](TransAW/man/TransAW.Rd) for the full interface.

## Reproducing the manuscript results

Each figure and table has a separate directory containing its analysis code, saved numerical results, and a script for regenerating the displayed output. The saved results can be used to reproduce the figures and tables without rerunning the full simulations or kinase analysis.

| Manuscript item | Contents |
| --- | --- |
| [Figure 1](figures/Main-Figure-1/) | Squared coefficient error with 100 observations per source |
| [Figure 2](figures/Main-Figure-2/) | Squared coefficient error with 300 observations per source |
| [Figure 3](figures/Main-Figure-3/) | Effective source sample size under different levels of source compatibility |
| [Figure 4](figures/Main-Figure-4/) | Test RMSE for held-out compounds |
| [Figure 5](figures/Main-Figure-5/) | Observed inhibition heatmap for the target and nine source kinases |
| [Figure 6](figures/Main-Figure-6/) | Three representative molecular environments |
| [Table 1](tables/Main-Table-1/) | Mean test RMSE and Monte Carlo standard error across scaffold splits |
| [Table 2](tables/Main-Table-2/) | Full-sample source contributions |
| [Table 3](tables/Main-Table-3/) | Full-sample coefficients and molecular-environment coverage |
| [Supplementary Figure S1](figures/Supplement-Figure-S1/) | Source-weight penalty sensitivity with 100 observations per source |
| [Supplementary Figure S2](figures/Supplement-Figure-S2/) | Source-weight penalty sensitivity with 300 observations per source |

For example, from the repository root, regenerate Figure 1 and Table 1 using the supplied R data:

```sh
Rscript figures/Main-Figure-1/Main-Figure-1-from-rds.R
Rscript tables/Main-Table-1/Main-Table-1-from-rds.R
```

The R figure scripts use `tikzDevice` and a TeX installation with `pdflatex`, TikZ, `standalone`, `mathpazo`, and `newpx`; simulation figures also use `ggplot2`. Table scripts use base R. Outputs are written under `results/`, with one directory per manuscript item. Set `TRANSAW_WORKDIR` to choose another location.

Figure 5 is drawn directly from the inhibition measurements. Figure 6 uses the stored compound structures and mapped fingerprint environments:

```sh
Rscript figures/Main-Figure-5/Main-Figure-5.R
python3 -m pip install -r figures/Main-Figure-6/requirements.txt
python3 figures/Main-Figure-6/Main-Figure-6.py
Rscript tables/Main-Table-2/Main-Table-2-from-rds.R
Rscript tables/Main-Table-3/Main-Table-3-from-rds.R
```

The chemical drawings also require `pdfcrop` and the TeX package `newtxtext`.

## Rerunning the analyses

Install the R dependencies and the local package:

```sh
Rscript -e 'install.packages(c("glmnet", "nloptr", "ks", "ncvreg", "mvtnorm", "ggplot2", "tikzDevice"), repos = "https://cloud.r-project.org")'
R CMD INSTALL TransAW
```

The scripts ending in `-from-rds.R` regenerate displays from saved results. The corresponding `.R` scripts refit the models. The simulation and kinase runners save completed fits and resume from them on the next run.

The refitting code downloads the authors' Trans-LASSO and RIW-TL implementations at fixed revisions when first needed, and keeps them in `results/reference/`. The kinase Trans-LASSO implementation is included in `tables/Main-Table-1/kinase-trans-lasso.R`. Shared target-LASSO and RIW-TL functions are in `methods/`.

See the [simulation instructions](figures/Main-Figure-1/README.md#simulations) and [kinase analysis instructions](tables/Main-Table-1/README.md#kinase-analysis) for individual runs. Tables 2 and 3 use a single full-sample fit:

```sh
Rscript tables/Main-Table-2/Main-Table-2.R
Rscript tables/Main-Table-3/Main-Table-3.R
```

The [data README](data/README.md) describes the public kinase data, fingerprints, saved predictions, and full-sample estimates.

## License

The R package and analysis scripts are released under [GPL-3](LICENSE). The prepared ChEMBL data retain the separate license and attribution described in the [data README](data/README.md).
