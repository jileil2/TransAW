# Trans-AW

Trans-AW learns how much to borrow from each source study when fitting a linear regression for a target population. The repository accompanies *Adaptive Weighting of Sources in Transfer Learning for High-Dimensional Linear Regression* by Jilei Lin, Huixia Judy Wang, Mingrui Liu and Wenyi Wang.

## Install the R package

```r
install.packages("remotes")
remotes::install_github("jileil2/TransAW", subdir = "TransAW")
library(TransAW)
```

The package accepts numeric design matrices or a formula and a list of source data frames. It returns target coefficients, predictions and source weights for each fold. For a worked example, see the [package guide](TransAW/README.md).

## Reproduce the manuscript

From the repository root, run the following command to rebuild all five figures and both tables from the saved fits. This takes about a minute and requires R, the **ggplot2** and **tikzDevice** packages, and a TeX installation with `pdflatex`, TikZ, standalone, mathpazo and newpx.

```sh
Rscript reproduce.R
```

The PDFs, CSV tables and LaTeX table rows appear in `output/manuscript/`. The simulation files contain results for individual replications. The kinase files contain held-out compound predictions, fold weights and candidate selections. The scripts compute the summaries and plots from these records.

| Manuscript item | What it shows | Script |
| --- | --- | --- |
| Figures 1–2 | Squared coefficient error for 100 or 300 observations per source | [Simulation figures](figures/simulation-figures.R) |
| Figure 3 | Effective sample size by source compatibility | [Simulation figures](figures/simulation-figures.R) |
| Figure 4 and Table 1 | Test mean absolute error across scaffold splits | [Kinase figures](figures/kinase-figures.R) · [Kinase tables](tables/kinase-tables.R) |
| Figure 5 and Table 2 | Contributions from the nine source kinases | [Kinase figures](figures/kinase-figures.R) · [Kinase tables](tables/kinase-tables.R) |

To fit the models from the beginning, see the [analysis instructions](analysis/README.md). The [data guide](data/README.md) describes the public ChEMBL measurements, gives the dataset citation and explains how to rebuild the compound fingerprints.

The R package and analysis scripts are distributed under [GPL-3](LICENSE). The prepared ChEMBL data retain their [data license and attribution](data/README.md).
