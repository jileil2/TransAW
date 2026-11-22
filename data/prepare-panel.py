"""Build the analysis panel from the archived ChEMBL screening records."""
import csv
import gzip
import hashlib
import sys
from collections import defaultdict
from pathlib import Path
from statistics import mean

from rdkit import Chem
from rdkit.Chem import rdFingerprintGenerator
from rdkit.Chem.Scaffolds import MurckoScaffold

kinases = ["P38alpha", "FYN", "YES", "LCK", "P38beta", "P38gamma", "P38delta",
           "Aurora-A", "AKT1", "MAPKAPK3"]
assays = {k + " mean inhibition at 1 uM [Nanosyn]": k for k in kinases}
archive = Path(sys.argv[1])
output = Path(sys.argv[2]) if len(sys.argv) > 2 else Path("data/kinase-panel.csv.gz")
with archive.open("rb") as stream:
    if hashlib.file_digest(stream, "sha256").hexdigest() != "81d7f9f82f7ee8e6b0f38dafe523da7254aaabe9449758a056372511d7868ad0":
        raise ValueError("Expected the pinned PKIS screening archive (see data/README.md).")

values = defaultdict(lambda: defaultdict(list))
structures = {}
with gzip.open(archive, "rt", encoding="latin1") as stream:
    for row in csv.DictReader(stream):
        kinase = assays.get(row["ASSAY"])
        if kinase is None:
            continue
        assert (row["SPECIES"], row["RELATION"], row["ENDPOINT"], row["UNITS"]) == (
            "Homo sapiens", "=", "Inhibition", "%")
        compound = row["PARENT_CHEMBL_ID"]
        smiles = row["PARENT_SMILES"]
        assert structures.setdefault(compound, smiles) == smiles
        values[compound][kinase].append(float(row["VALUE"]))

generator = rdFingerprintGenerator.GetMorganGenerator(radius=2, fpSize=256)
assert len(values) == 364
with gzip.open(output, "wt", newline="") as stream:
    writer = csv.writer(stream)
    writer.writerow(["compound", "scaffold", *kinases, *[f"bit{i}" for i in range(256)]])
    for compound, readings in sorted(values.items()):
        mol = Chem.MolFromSmiles(structures[compound])
        core = MurckoScaffold.GetScaffoldForMol(mol)
        generic = Chem.MolToSmiles(MurckoScaffold.MakeScaffoldGeneric(core))
        scaffold = hashlib.sha256(generic.encode()).hexdigest()[:16]
        bits = generator.GetFingerprint(mol).ToBitString()
        writer.writerow([compound, scaffold, *[mean(readings[k]) for k in kinases], *bits])
