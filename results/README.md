# Saved manuscript fits

These files are the inputs to `reproduce.R`. Each row represents a fitted result before the manuscript summaries are calculated.

| File | Unit and columns |
| --- | --- |
| `simulation-errors.csv.gz` | One method in one replication. `coef_error` is the sum of squared differences between estimated and true target coefficients. The design columns are `n` (observations per source), `m` (sources), and `h` (heterogeneity). |
| `simulation-weights.csv.gz` | One source per method and replication at 100 observations per source. The figure script normalizes source contributions within the replication and calculates effective sample size for each compatibility group. |
| `simulation-fold-weights.csv.gz` | The two Trans-AW source allocations in every simulation setting, as saved by the optimizer. These can be used to refit the regression at the archived solution. |
| `kinase-predictions.csv.gz` | One held-out compound per split, with its observed inhibition and five predictions. `equal` is the equal-source-weight comparison. |
| `kinase-weights.csv.gz` | One source kinase per split. `fold_A` and `fold_B` are Trans-AW weights, `selected_A` and `selected_B` indicate selection by Trans-LASSO, and `riw` is the source's share of the total RIW-TL observation weight. |

The kinase files retain all 100 split identifiers. A missing RIW-TL prediction or source share marks a split for which the fit failed. The summaries use the 88 completed RIW-TL fits. The prediction files use percentage points of inhibition and the weight files use proportions.
