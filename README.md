# Trans-AW

Trans-AW learns how much to borrow from each source study when fitting a linear regression for a target population. The repository accompanies *Adaptive Weighting of Sources in Transfer Learning for High-Dimensional Linear Regression* by Jilei Lin, Huixia Judy Wang, Mingrui Liu and Wenyi Wang.

## Install the R package

```r
install.packages("remotes")
remotes::install_github("jileil2/TransAW", subdir = "TransAW")
library(TransAW)
```

The package accepts numeric design matrices or a formula and a list of source data frames. It returns target coefficients, predictions and source weights for each fold. For a worked example, see the [package guide](TransAW/README.md).

## Figures and tables

Each manuscript item has its own folder with the analysis script, the numerical values used in the paper, and a short script that draws the figure or writes the table from those values.

| Manuscript item | Analysis |
| --- | --- |
| [Figure 1](figures/Main-Figure-1/) | Squared coefficient error with 100 observations per source |
| [Figure 2](figures/Main-Figure-2/) | Squared coefficient error with 300 observations per source |
| [Figure 3](figures/Main-Figure-3/) | Effective sample size by source compatibility |
| [Figure 4](figures/Main-Figure-4/) | Test error on held-out compounds |
| [Figure 5](figures/Main-Figure-5/) | Contributions from the nine source kinases |
| [Table 1](tables/Main-Table-1/) | Mean test error and Monte Carlo standard error across scaffold splits |
| [Table 2](tables/Main-Table-2/) | Average contribution of each source kinase |

For example, run these commands from the repository root to draw Figure 1 and write Table 1 from the supplied R data. The figure scripts use **tikzDevice** and a TeX installation with `pdflatex`, TikZ, standalone, mathpazo and newpx. The simulation figures also use **ggplot2**. The table scripts use base R.

```sh
Rscript figures/Main-Figure-1/Main-Figure-1-from-rds.R
Rscript tables/Main-Table-1/Main-Table-1-from-rds.R
```

To refit the models, follow the [method guide](method/README.md) and run the corresponding script without the `-from-rds` suffix. Both routes write to a sibling directory named `TransAW-analysis`. Set `TRANSAW_WORKDIR` to choose another location.

The [data guide](data/README.md) documents the public ChEMBL measurements, compound fingerprints and 100 scaffold splits.

The R package and analysis scripts are distributed under [GPL-3](LICENSE). The prepared ChEMBL data retain their [data license and attribution](data/README.md).
