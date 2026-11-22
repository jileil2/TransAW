# Refit the models

Run commands from the repository root. Install TransAW, the comparison packages and the figure dependencies. The reference-code script downloads the two comparator implementations at pinned revisions from their authors' repositories.

```sh
Rscript -e 'install.packages(c("glmnet", "nloptr", "ks", "ncvreg", "mvtnorm", "ggplot2", "tikzDevice"), repos="https://cloud.r-project.org")'
R CMD INSTALL TransAW
Rscript analysis/get-reference-code.R
```

## Simulation

The arguments give the observations per source, number of sources, heterogeneity level and replication numbers. This example fits the four methods for the first replication of the smallest setting.

```sh
Rscript analysis/fit-simulation.R 100 5 2 1
```

Each setting has 200 replications, 500 predictors and 150 target observations. The original runs used the base seed 20260716. Directions of source departures are fixed within each source count. Each fit uses its own seed. The simulation calls the installed TransAW package and the comparison methods with the study settings.

The Trans-LASSO implementation used in these simulations sets the penalty to zero for the pooled candidates and their residual adjustments. Its target-only candidate uses the upstream cross-validation rule. The wrapper sets this option explicitly. RIW-TL uses the authors' cross-validated thresholds. A replay recovers its observation weights and checks the resulting coefficients against the reference fit. [Li, Cai and Li](https://doi.org/10.1111/rssb.12479) · [Trans-LASSO code](https://github.com/saili0103/TransLasso) · [Zhao, Zheng and Leng](https://doi.org/10.1080/01621459.2026.2623997) · [RIW-TL code](https://github.com/RIW-TL/Transfer-learning)

## Kinase analysis

```sh
Rscript analysis/fit-kinases.R 1
```

This fits all methods for the first saved scaffold split. The package uses the common source design because all nine screens measured the same compounds. Target training rows determine predictor scales, the target intercept and the response scale. Each historical screen is centered separately. Test predictions are converted back to percentage points of inhibition. The equal-weight comparison uses the same source penalty, folds and residual adjustment as the adaptive fit.

For this application, Trans-LASSO uses two held-out thirds and eight-fold tuning of candidate models. Its source score counts how often a kinase belongs to the highest-weight candidate across the two orientations. RIW-TL returned predictions on 88 of the original 100 splits. Summaries use the completed splits for each method. Table 1 also includes the equal-weight comparison.

## Full rerun

The following Bash commands fit 4,800 simulation datasets and 100 kinase partitions. Jobs for distinct settings and replications can run independently. Each writes a separate RDS file under `output/`.

```bash
for n in 100 300; do
  for m in 5 10 15 20; do
    for h in 2 4 6; do
      Rscript analysis/fit-simulation.R "$n" "$m" "$h" $(seq 1 200) || exit 1
    done
  done
done
Rscript analysis/fit-kinases.R $(seq 1 100)
Rscript analysis/collect-fits.R
Rscript reproduce.R output/refitted-results output/refitted-manuscript
```

## Checking the archived simulation fits

The simulation computes the orthogonal correction by finite differences in centered log-weight coordinates. The kinase analysis uses analytic derivatives in the source weights. Each analysis applies the numerical Hessian floor in its own coordinates.

The public package can rerun the entire source-weight search or refit the regressions at the weights saved by the original search. COBYLA searches a criterion whose selected predictors can change with the source weights. A fresh search on another numerical platform can return different weights. To use the archived weights in a four-method rerun, add `--saved-weights` to the simulation command. The option is also valid in the full-rerun loop above.

To check the Trans-AW regression alone against the archived coefficient error, run the command below. This regenerates the data, refits the source regressions, and recomputes the orthogonal correction and both target adjustments. Saved weights have eight significant digits, so small differences can remain.

```sh
Rscript analysis/replay-simulation.R 100 5 2 1 2 3
```
