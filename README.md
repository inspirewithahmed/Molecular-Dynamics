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
├── Python scripts
│   ├── H-bond.py               # H-bond count vs. frame plotting
│   ├── diheral.py              # Dihedral angle time series plotting
│   ├── pca.py / script.py      # PCA probability density surface
│   ├── Free_energy.py          # Free energy surface analysis
│   ├── radgyr.py               # Radius of gyration analysis
│   ├── rmsd.py                 # RMSD time series
│   ├── D_vs_T.py               # Distance vs. temperature
│   ├── frequency.py            # Frequency analysis
│   ├── graph.py / launch_plot.py  # General plotting helpers
│   ├── bdp.py / cube.py        # BDP-specific and cube file utilities
│   └── packmol.py              # PACKMOL input generation helper
│
├── CPPTRAJ input files (.traj)
│   ├── H-Bond.traj
│   ├── Dihedral_Angle.traj
│   ├── BDP-RFP-distance.traj
│   ├── pi_pi_Stacking.traj
│   ├── cluster.traj
│   ├── combine.traj
│   ├── radgyr.traj
│   ├── rmsd.traj
│   └── sasa.traj
│
├── SLURM / shell job scripts
│   ├── launch-aMD.sh           # Submit aMD production run (pmemd.MPI)
│   ├── launch-MD.sh            # Submit standard MD run
│   ├── analysis.sh             # Run CPPTRAJ analysis jobs
│   ├── chained_tremd_slurm.sh  # Chained T-REMD SLURM jobs
│   └── gaussian.slurm          # Gaussian DFT job script
│
├── AMBER / MD input files
│   ├── h-remd.in / remd.mdin   # REMD input parameters
│   ├── leap.in / reduce.in     # System preparation inputs
│   ├── groupfile / remd.groupfile
│   └── setup_equilibrate_input.x / setup_remd_input.x
│
├── PACKMOL inputs
│   ├── 8x8.inp / 8x8x8.inp / 10_molecules.inp
│
├── Perl utilities
│   ├── iterative_aMD.pl
│   ├── check_file_difference.pl / check_num_frames.pl
│   ├── print_dihedrals.pl / renumber.pl
│   └── strip_trajectories_by_list.pl
│
├── Example figures
│   ├── free_energy_surface.png
│   ├── radgyr_frequency.png
│   └── D1Cl2.png
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
| Gaussian | 16 / 09 | DFT calculations |
| Python | ≥ 3.8 | Analysis & plotting |

### Python Packages
Install with:
```bash
pip install -r requirements.txt
```

---

## Script Usage

### H-bond Analysis — `H-bond.py`

Reads CPPTRAJ H-bond output and plots H-bond count as a function of simulation frame.

**Input:** `intermol_hbonds.dat` (whitespace-delimited, columns `#Frame` and `H-bond`)

```bash
python H-bond.py                          # uses default filename
python H-bond.py --input my_hbonds.dat   # custom input file
python H-bond.py --output my_plot.png     # custom output filename
```

**Output:** `D1Cl1-H-bond.png` (300 dpi)

---

### CPPTRAJ Inputs

Each `.traj` file is a CPPTRAJ input script. Run individually:

```bash
cpptraj -i H-Bond.traj
cpptraj -i cluster.traj
cpptraj -i BDP-RFP-distance.traj
cpptraj -i Dihedral_Angle.traj
cpptraj -i pi_pi_Stacking.traj
cpptraj -i radgyr.traj
cpptraj -i rmsd.traj
cpptraj -i sasa.traj
```

---

### SLURM Scripts

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
sbatch launch-aMD.sh
```

---

## Example Output

### Free Energy Surface

![Free energy surface](free_energy_surface.png)

### Radius of Gyration Distribution

![Radius of gyration frequency](radgyr_frequency.png)

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
