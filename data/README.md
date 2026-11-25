# Kinase inhibition data

The analysis predicts p38α inhibition from measurements on the GSK Published Kinase Inhibitor Set. The ten Nanosyn assays measured inhibition at 1 μM in the same 364 compounds. The original study describes the library and the screens. [Elkins et al. (2016)](https://doi.org/10.1038/nbt.3374)

**Dataset citation.** Hersey, A. (2012). *Compounds: GSK PKIS; Assays: Nanosyn kinase panel*. ChEMBL, EMBL-EBI. Accession CHEMBL1961873. [Dataset DOI](https://doi.org/10.6019/CHEMBL1961873) · [ChEMBL record](https://www.ebi.ac.uk/chembl/explore/document/CHEMBL1961873)

The analysis used the archived PKIS1 export distributed by Spencer Ericksen and colleagues. The pinned file preserves the parent compound identifiers, structures, assay names and observed values used here. [Archived screening records](https://github.com/SpencerEricksen/informers/blob/5fd3934f5789c371026fc9eece1846ff1294122b/data/original_data/pkis1/PKIS_screening_data.csv.gz)

| File | Contents |
| --- | --- |
| `kinase-panel.csv.gz` | One row per ChEMBL parent compound. The columns give a scaffold identifier, percent inhibition for p38α and nine source kinases, and the 256 bits of a radius-two Morgan fingerprint. MK3 appears under its assay name, MAPKAPK3. |
| `scaffold-splits.csv.gz` | Training and test compound identifiers for each of the 100 partitions. Training row order determines the inner folds. Each split holds out 109 compounds and uses the full historical source screens. |
| `kinase-test-predictions.rds` | Compound-level predictions on the 100 test splits, including missing RIW-TL predictions on its 12 unsuccessful splits. Used to compute RMSE. |
| `full-sample-fit.rds` | Full-sample regression coefficients, intercepts, and source weights. |
| `compound-structures.csv` | Parent compound SMILES for the 364 compounds. |
| `selected-environments.csv` | The three illustrated fingerprint environments, example compounds, highlighted atom/bond indices, and coverage counts. |

To rebuild the panel, download the pinned screening file and run the following from the repository root. The preparation script checks the input checksum, averages repeated readings within each compound and assay, and computes fingerprints and generic Bemis–Murcko scaffold identifiers. The original preparation used Python 3.11 and RDKit 2024.09.6.

```sh
python3 data/prepare-panel.py PKIS_screening_data.csv.gz
```

The prepared measurements and derived compound features are distributed under the ChEMBL data license, Creative Commons Attribution–ShareAlike 3.0 Unported. [ChEMBL licensing](https://chembl.gitbook.io/chembl-interface-documentation/about#data-licensing) · [License terms](https://creativecommons.org/licenses/by-sa/3.0/)
