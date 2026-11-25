# Figure 5. Observed kinase inhibition

The heatmap contains 364 compounds and ten kinase assays. Compounds are ordered by complete-linkage hierarchical clustering using Euclidean distances between their ten-assay inhibition profiles. Kinase rows remain in a fixed order and share one color scale.

Run from the repository root:

```sh
Rscript figures/Main-Figure-5/Main-Figure-5.R
```

The script reads `data/kinase-panel.csv.gz` and writes the PDF, TikZ source, and ordered measurements to `results/Main-Figure-5/`.
