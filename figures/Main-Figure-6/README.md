# Figure 6. Representative molecular environments

The panels show the substituted imidazole environment in SB-221466 (bit 204), the pyridine-ring segment in SB-751148 (bit 19), and an aromatic-carbon environment in CHEMBL69757 (bit 64).

Run from the repository root:

```sh
python3 -m pip install -r figures/Main-Figure-6/requirements.txt
python3 figures/Main-Figure-6/Main-Figure-6.py
```

The script rebuilds the 256-bit radius-two Morgan fingerprints from the compound SMILES, calculates environment coverage, and draws the stored atom and bond highlights. It writes vector drawings and the assembled figure to `results/Main-Figure-6/`. A TeX installation with `pdflatex`, `pdfcrop`, `standalone`, and `newtxtext` is required.
