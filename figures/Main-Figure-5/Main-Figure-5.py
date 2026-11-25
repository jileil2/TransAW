"""Draw the three molecular environments in Figure 5."""
import csv
import gzip
import json
import os
import subprocess
from pathlib import Path

import cairosvg
from rdkit import Chem
from rdkit.Chem import rdFingerprintGenerator
from rdkit.Chem.Draw import rdMolDraw2D

folder = Path(os.environ.get("TRANSAW_WORKDIR", "results")) / "Main-Figure-5"
folder.mkdir(parents=True, exist_ok=True)
with open("data/selected-environments.csv") as stream:
    examples = list(csv.DictReader(stream))
with open("data/compound-structures.csv") as stream:
    structures = {row["compound"]: row["smiles"] for row in csv.DictReader(stream)}
with gzip.open("data/kinase-panel.csv.gz", "rt") as stream:
    panel = list(csv.DictReader(stream))

generator = rdFingerprintGenerator.GetMorganGenerator(
    radius=2, fpSize=256, includeChirality=False
)
molecules, bit_info = {}, {}
coverage = {row["bit"]: set() for row in examples}
for row in panel:
    compound = row["compound"]
    molecule = Chem.MolFromSmiles(structures[compound])
    info = rdFingerprintGenerator.AdditionalOutput()
    info.AllocateBitInfoMap()
    fingerprint = generator.GetFingerprint(molecule, additionalOutput=info)
    assert all(fingerprint[j] == int(row[f"bit{j}"]) for j in range(256))
    molecules[compound] = molecule
    bit_info[compound] = info.GetBitInfoMap()
    for example in examples:
        bit = int(example["bit"][3:])
        for center, radius in bit_info[compound].get(bit, []):
            if radius != int(example["radius"]):
                continue
            bonds = list(Chem.FindAtomEnvironmentOfRadiusN(molecule, radius, center))
            atoms = {center}
            for bond in bonds:
                edge = molecule.GetBondWithIdx(bond)
                atoms.update([edge.GetBeginAtomIdx(), edge.GetEndAtomIdx()])
            fragment = Chem.MolFragmentToSmiles(
                molecule, atomsToUse=sorted(atoms), bondsToUse=bonds,
                rootedAtAtom=center, isomericSmiles=True
            )
            if fragment == example["fragment_smiles"]:
                coverage[example["bit"]].add(compound)

colors = [(0.94, 0.80, 0.42), (0.94, 0.56, 0.79), (0.45, 0.78, 0.94)]
for example, color in zip(examples, colors):
    bit, compound = example["bit"], example["compound"]
    assert len(coverage[bit]) == int(example["fragment_compounds"])
    assert sum(int(row[bit]) for row in panel) == int(example["bit_compounds"])
    molecule = molecules[compound]
    atoms = json.loads(example["highlighted_atoms"])
    bonds = json.loads(example["highlighted_bonds"])
    assert (int(example["center"]), int(example["radius"])) in bit_info[compound][int(bit[3:])]
    drawer = rdMolDraw2D.MolDraw2DSVG(620, 350)
    options = drawer.drawOptions()
    options.fixedFontSize = 23
    options.bondLineWidth = 1.8
    options.padding = 0.07
    options.useBWAtomPalette()
    rdMolDraw2D.PrepareAndDrawMolecule(
        drawer, molecule, highlightAtoms=atoms, highlightBonds=bonds,
        highlightAtomColors={atom: color for atom in atoms},
        highlightBondColors={bond: color for bond in bonds}
    )
    drawer.FinishDrawing()
    svg = drawer.GetDrawingText()
    (folder / f"{bit}.svg").write_text(svg)
    uncropped = folder / f"{bit}-uncropped.pdf"
    cairosvg.svg2pdf(bytestring=svg.encode(), write_to=str(uncropped))
    subprocess.run(
        ["pdfcrop", "--margins", "2", str(uncropped), str(folder / f"{bit}.pdf")],
        check=True
    )
    uncropped.unlink()

template = Path("figures/Main-Figure-5/Main-Figure-5.tex")
(folder / template.name).write_text(template.read_text())
subprocess.run(
    ["pdflatex", "-interaction=nonstopmode", "-halt-on-error", template.name],
    cwd=folder, check=True
)
