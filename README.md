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
| [Figure 4](figures/Main-Figure-4/) | Prediction error for held-out compounds |
| [Figure 5](figures/Main-Figure-5/) | Estimated weights for the nine source kinases |
| [Table 1](tables/Main-Table-1/) | Mean test prediction error and Monte Carlo standard error across scaffold splits |
| [Table 2](tables/Main-Table-2/) | Average source weights for the nine kinases |
| [Supplementary Figure S1](figures/Supplement-Figure-S1/) | Source-weight penalty sensitivity with 100 observations per source |
| [Supplementary Figure S2](figures/Supplement-Figure-S2/) | Source-weight penalty sensitivity with 300 observations per source |

For example, from the repository root, regenerate Figure 1 and Table 1 using the supplied R data:

```sh
Rscript figures/Main-Figure-1/Main-Figure-1-from-rds.R
Rscript tables/Main-Table-1/Main-Table-1-from-rds.R
```

The figure scripts require `tikzDevice` and a TeX installation with `pdflatex`, TikZ, `standalone`, `mathpazo`, and `newpx`; simulation figures also use `ggplot2`. Table scripts use base R. By default, newly generated files are written to a sibling directory named `TransAW-analysis`. Set the environment variable `TRANSAW_WORKDIR` to use another location.

## Rerunning the analyses

To refit the models rather than use the saved results, install the R dependencies and the TransAW package from the repository root:

```sh
Rscript -e 'install.packages(c("glmnet", "nloptr", "ks", "ncvreg", "mvtnorm", "ggplot2", "tikzDevice"), repos = "https://cloud.r-project.org")'
R CMD INSTALL TransAW
Rscript setup-comparisons.R
```

The final command retrieves the comparison methods at fixed revisions. The analysis scripts use the installed package and save completed fits in the work directory. Full reruns can be computationally intensive; see the [simulation instructions](figures/Main-Figure-1/README.md#simulations) and [kinase analysis instructions](tables/Main-Table-1/README.md#kinase-analysis) for the settings and commands.

The [data README](data/README.md) documents the kinase inhibition measurements, compound fingerprints, and 100 scaffold-disjoint training/test splits used in the application.

## License

The R package and analysis scripts are released under [GPL-3](LICENSE). The prepared ChEMBL data retain the separate license and attribution described in the [data README](data/README.md).
