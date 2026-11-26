# Trans-AW

This repository contains the R package and reproducibility materials for our paper, *Adaptive Weighting of Sources in Transfer Learning for High-Dimensional Linear Regression*, by Jilei Lin, Huixia Judy Wang, Mingrui Liu, and Wenyi Wang.

## Overview

Trans-AW is a transfer learning method for high-dimensional linear regression with multiple heterogeneous source datasets. Existing methods often select informative sources for pooling, potentially discarding useful information from partially informative sources. We instead estimate continuous source weights by minimizing target prediction loss, allowing the target data to determine how much information to borrow from each source.

We formulate adaptive source weighting as a bilevel optimization problem and introduce a penalty on the weights to control the effective source sample size. To remove the first-order effect of weight-estimation error on coefficient estimation, we develop a cross-fitted correction based on Neyman orthogonality and post-LASSO least squares, followed by a sparse target adjustment for remaining source–target differences.

Under suitable conditions, Trans-AW achieves a faster convergence rate than target-only LASSO. Our theoretical and numerical results demonstrate efficiency gains from adaptive weighting and robustness to negative transfer. We illustrate the method by predicting p38α kinase inhibition from molecular structure, where borrowing information from related kinase assays improves prediction accuracy.

## R package

The `TransAW` package can be installed from GitHub:

```r
install.packages("remotes")
remotes::install_github("jileil2/TransAW", subdir = "TransAW")
library(TransAW)
```

The package takes a target dataset and one or more source datasets with a common set of numeric predictors. It returns estimated target regression coefficients, source weights, and fitting diagnostics; `predict()` gives predictions for new observations. See the [package README](TransAW/README.md) for a worked example and the [R documentation](TransAW/man/TransAW.Rd) for function arguments and returned objects.

## Reproducibility

The code and saved numerical results for each figure and table are provided in separate directories. All figures and tables can be regenerated from the supplied results and data without rerunning the full simulation studies or kinase analysis.

| Manuscript item | Contents |
| --- | --- |
| [Figure 1](figures/Main-Figure-1/) | Squared coefficient estimation error across simulation settings |
| [Figure 2](figures/Main-Figure-2/) | Test RMSE across scaffold-based training–test splits |
| [Figure 3](figures/Main-Figure-3/) | Observed inhibition profiles of the target and source kinases |
| [Figure 4](figures/Main-Figure-4/) | Representative molecular environments associated with selected fingerprint bits |
| [Table 1](tables/Main-Table-1/) | Effective source sample sizes by source–target compatibility |
| [Table 2](tables/Main-Table-2/) | Mean test RMSE and Monte Carlo standard error across scaffold-based splits |
| [Table 3](tables/Main-Table-3/) | Estimated weights of the source kinase assays in the full sample |
| [Table 4](tables/Main-Table-4/) | Full-sample regression coefficients and molecular-environment frequencies |
| [Supplementary Figure S1](figures/Supplement-Figure-S1/) | Sensitivity to the source-weight penalty with 100 observations per source |
| [Supplementary Figure S2](figures/Supplement-Figure-S2/) | Sensitivity to the source-weight penalty with 300 observations per source |

From the repository root, regenerate Figure 1 and Tables 1–2 with:

```sh
Rscript figures/Main-Figure-1/Main-Figure-1-from-rds.R
Rscript tables/Main-Table-1/Main-Table-1-from-rds.R
Rscript tables/Main-Table-2/Main-Table-2-from-rds.R
```

The R figure scripts require `tikzDevice` and TeX with `pdflatex`, TikZ, `standalone`, `mathpazo`, and `newpx`; simulation figures also use `ggplot2`. Table scripts use base R. Outputs go to `results/`, in a directory for each manuscript item. Set `TRANSAW_WORKDIR` to use another location.

Figures 3 and 4 use the supplied inhibition measurements and molecular structures, respectively. Regenerate them and Tables 3–4 with:

```sh
Rscript figures/Main-Figure-3/Main-Figure-3.R
python3 -m pip install -r figures/Main-Figure-4/requirements.txt
python3 figures/Main-Figure-4/Main-Figure-4.py
Rscript tables/Main-Table-3/Main-Table-3-from-rds.R
Rscript tables/Main-Table-4/Main-Table-4-from-rds.R
```

The chemical drawings also require `pdfcrop` and the TeX package `newtxtext`.

## Rerunning the analyses

While the scripts ending in `-from-rds.R` regenerate figures and tables from saved results, the corresponding analysis scripts refit the models. Install the R dependencies and local package before refitting:

```sh
Rscript -e 'install.packages(c("glmnet", "nloptr", "ks", "ncvreg", "mvtnorm", "ggplot2", "tikzDevice"), repos = "https://cloud.r-project.org")'
R CMD INSTALL TransAW
```

The simulation and kinase runners save completed fits and resume from them on the next run. The refitting code downloads the authors' Trans-LASSO and RIW-TL implementations at fixed revisions when first needed and caches them in `results/reference/`. The kinase Trans-LASSO implementation is included in `tables/Main-Table-2/kinase-trans-lasso.R`; shared target-only LASSO and RIW-TL functions are in `methods/`.

See the [simulation instructions](figures/Main-Figure-1/README.md#simulations) and [kinase analysis instructions](tables/Main-Table-2/README.md#kinase-analysis) for individual runs. Tables 3 and 4 share a full-sample analysis:

```sh
Rscript tables/Main-Table-3/Main-Table-3.R
Rscript tables/Main-Table-4/Main-Table-4.R
```

The [data README](data/README.md) documents the public kinase data and their attribution, fingerprints, saved predictions, and full-sample estimates.

## License

The R package and analysis scripts are released under [GPL-3](LICENSE). The prepared ChEMBL data retain the separate license and attribution described in the [data README](data/README.md).
