# Molecular Dynamics Analysis — Peptide Self-Assembly & Aggregation

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Python](https://img.shields.io/badge/Python-3.8%2B-blue.svg)](https://www.python.org/)
[![AMBER](https://img.shields.io/badge/AMBER-24-green.svg)](https://ambermd.org/)

Analysis scripts, CPPTRAJ inputs, and SLURM jobs from my Ph.D. work on **peptide self-assembly and aggregation** at the University of Milan (NanoReMedi Doctoral Network, EU-funded). The focus is on atomistic characterisation of peptide–dye conjugates using classical and accelerated MD (aMD) simulations, with post-processing done in CPPTRAJ and Python.

---

## Research Context

The system studied is a boron-dipyrromethene (BDP)–peptide conjugate, **D1Cl1**, simulated in explicit solvent. Classical MD can't easily sample the slow conformational transitions relevant to self-assembly, so aMD is used to flatten the energy surface and accelerate sampling. All simulations run with **AMBER 24**; trajectory analysis and observables are computed with **CPPTRAJ** and the scripts in this repo.

The observables tracked are H-bond formation over time, backbone and side-chain dihedral dynamics, π–π stacking between the BDP and RFP aromatic groups, intermolecular BDP–RFP distances, conformational clustering, and PCA of the conformational landscape.

---

## Repository Structure

```
Molecular-Dynamics/
│
├── scripts/                    # Python analysis and plotting scripts
│   ├── H-bond.py               # H-bond count vs. frame plotting
│   ├── dihedral.py             # Dihedral angle time series plotting
│   ├── pca.py                  # 3-D PCA probability density surface
│   └── (add more as needed)
│
├── cpptraj/                    # CPPTRAJ input files (.traj / .in)
│   ├── H-Bond.traj
│   ├── Dihedral_Angle.traj
│   ├── BDP-RFP-distance.traj
│   ├── pi_pi_Stacking.traj
│   ├── cluster.traj
│   └── pca.in
│
├── slurm/                      # SLURM job submission scripts
│   ├── launch-aMD.sh           # Submit aMD production run (AMBER pmemd.MPI)
│   └── combine_traj.sh         # Run CPPTRAJ analysis jobs
│
├── figures/                    # Example output figures
│   └── example_pca_surface.png
│
├── requirements.txt            # Python dependencies
├── LICENSE                     # MIT License
└── README.md
```

---

## Dependencies

### Software
| Tool | Version | Purpose |
|------|---------|---------|
| AMBER / pmemd.MPI | 24 | MD simulation engine |
| CPPTRAJ | bundled with AMBER 24 | Trajectory analysis |
| Python | ≥ 3.8 | Analysis & plotting |

### Python Packages
Install with:
```bash
pip install -r requirements.txt
```

See [`requirements.txt`](requirements.txt) for the full list.

---

## Script Usage

### H-bond Analysis — `scripts/H-bond.py`

Reads CPPTRAJ H-bond output and plots H-bond count as a function of simulation frame.

**Input:** `intermol_hbonds.dat` (whitespace-delimited, columns `#Frame` and `H-bond`)

```bash
python scripts/H-bond.py                          # uses default filename
python scripts/H-bond.py --input my_hbonds.dat   # custom input file
python scripts/H-bond.py --output my_plot.png     # custom output filename
```

**Output:** `D1Cl1-H-bond.png` (300 dpi)

---

### Dihedral Angle Analysis — `scripts/dihedral.py`

Plots dihedral angle time series for multiple planes (e.g. BDP and RFP aromatic planes).

**Input:** `dihedral_angle.dat` (columns `#Frame`, `RFP_plane`, `BDP_plane`)

```bash
python scripts/dihedral.py
```

**Output:** `Dihedral-Angles.png` (300 dpi)

---

### PCA — `scripts/pca.py`

Generates a 3-D probability density surface from principal component data using Gaussian KDE.

**Input:** `PCA.dat` (columns: PC1, PC2)

```bash
python scripts/pca.py
```

**Output:** `PCA_3D_probability_surface.png` (600 dpi)

---

### CPPTRAJ Inputs — `cpptraj/`

Each `.traj` file is a CPPTRAJ input script. Run individually:

```bash
cpptraj -i cpptraj/H-Bond.traj
cpptraj -i cpptraj/cluster.traj
cpptraj -i cpptraj/BDP-RFP-distance.traj
cpptraj -i cpptraj/Dihedral_Angle.traj
cpptraj -i cpptraj/pi_pi_Stacking.traj
```

---

### SLURM Scripts — `slurm/`

**`launch-aMD.sh`** — submits an aMD production run using `pmemd.MPI`.

Before submitting, edit the configuration block at the top of the file:
```bash
# -- USER CONFIGURATION --
AMBER_HOME=/path/to/amber24      # path to your AMBER installation
DIR=/path/to/your/project        # path to your project directory
name=D1Cl1                       # system name (used for file naming)
ACCOUNT=your_hpc_account         # HPC account name
```

Submit with:
```bash
sbatch slurm/launch-aMD.sh
```

**`combine_traj.sh`** — runs a selected CPPTRAJ analysis on the cluster. Uncomment the relevant `cpptraj -i` line for the analysis you need, then submit:
```bash
sbatch slurm/combine_traj.sh
```

---

## Example Output

### PCA Conformational Landscape

![PCA probability density surface](figures/example_pca_surface.png)

*3-D probability density surface (Gaussian KDE) of the D1Cl1 conjugate projected onto PC1 and PC2. Trajectory: 80,000 frames of aMD simulation.*

---

## Citation

If you use these scripts, please cite:

> Saeed Ahmed. *Peptide Self-Assembly and Aggregation: Atomistic Simulations of Peptide–Dye Conjugates.* Ph.D. Thesis, University of Milan / Universitat Politècnica de Catalunya, 2026.

---

## Author

**Saeed Ahmed**  
NanoReMedi DC 01 — EU Doctoral Network  
Università degli Studi di Milano | Universitat Politècnica de Catalunya  
📧 saeed.ahmed@unimi.it  
🔗 [ORCID](https://orcid.org/0009-0003-9717-5180) · [Google Scholar](https://scholar.google.com/citations?user=GkT5UZUAAAAJ&hl=en) · [LinkedIn](https://www.linkedin.com/in/ahmed-saeed-833a74157)

---

## License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.
