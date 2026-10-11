# Repository Reorganization — Step-by-Step Git Commands

Run these in the root of your cloned `Molecular-Dynamics` repo.
Each block is one logical commit — copy-paste the whole block at once, don't mix them.

---

## Step 1 — Create the folder structure

```bash
mkdir -p scripts cpptraj slurm figures
```

---

## Step 2 — Move Python scripts into `scripts/`
(also fixes the `diheral.py` typo)

```bash
git mv H-bond.py       scripts/H-bond.py
git mv diheral.py      scripts/dihedral.py    # fixes the typo
git mv pca.py          scripts/pca.py
git commit -m "refactor: move Python scripts into scripts/ and fix dihedral.py typo"
```

---

## Step 3 — Move CPPTRAJ inputs into `cpptraj/`

```bash
git mv H-Bond.traj              cpptraj/H-Bond.traj
git mv Dihedral_Angle.traj      cpptraj/Dihedral_Angle.traj
git mv BDP-RFP-distance.traj    cpptraj/BDP-RFP-distance.traj
git mv pi_pi_Stacking.traj      cpptraj/pi_pi_Stacking.traj
git mv cluster.traj             cpptraj/cluster.traj
git mv pca.in                   cpptraj/pca.in
git commit -m "refactor: move CPPTRAJ input files into cpptraj/"
```

---

## Step 4 — Move SLURM scripts into `slurm/`

```bash
git mv launch-aMD.sh    slurm/launch-aMD.sh
git mv combine_traj.sh  slurm/combine_traj.sh
git commit -m "refactor: move SLURM scripts into slurm/"
```

---

## Step 5 — Add new files (copy from this package into your repo root first)

```bash
# Copy the provided files into your repo:
#   README.md        → replace the existing empty one
#   H-bond.py        → replace scripts/H-bond.py  (already moved above)
#   requirements.txt → new file at repo root
#   LICENSE          → new file at repo root

cp /path/to/provided/README.md        README.md
cp /path/to/provided/H-bond.py        scripts/H-bond.py
cp /path/to/provided/requirements.txt requirements.txt
cp /path/to/provided/LICENSE          LICENSE

git add README.md scripts/H-bond.py requirements.txt LICENSE
git commit -m "docs: add full README, requirements.txt, MIT license, and fix H-bond.py"
```

---

## Step 6 — Add a figures/ placeholder (so the folder appears on GitHub)

```bash
# Place one of your real output PNG files in figures/, e.g.:
cp /path/to/your/PCA_3D_probability_surface.png figures/example_pca_surface.png

git add figures/example_pca_surface.png
git commit -m "docs: add example PCA output figure"
```

---

## Step 7 — Push everything

```bash
git push origin main
```

---

## Final Checklist

After pushing, open the repo on GitHub and check:
- [ ] README renders with the figure visible
- [ ] All four folders (`scripts/`, `cpptraj/`, `slurm/`, `figures/`) appear at the root
- [ ] Filename reads `dihedral.py`, not `diheral.py`
- [ ] `requirements.txt` and `LICENSE` are at the repo root
- [ ] Add a one-line description via the gear ⚙️ next to "About" on GitHub
- [ ] Topics are already set (`peptide-md-analysis`, `md-trajectory-analysis`, `peptide-interaction-analysis`) ✓

---

## Suggested future commits

Don't do these all at once — spread them out over days or weeks. The point is a commit history that looks like ongoing work, not a single upload.

| What to add | Commit message |
|---|---|
| Fixed `dihedral.py` (argparse + config block) | `fix: add CLI arguments and config block to dihedral.py` |
| Fixed `pca.py` (z-axis label) | `fix: label z-axis as relative density, not probability density` |
| Fixed `launch-aMD.sh` (SRUN_CPUS_PER_TASK) | `fix: correct SRUN_CPUS_PER_TASK variable name in launch-aMD.sh` |
| Second system's scripts | `feat: add analysis scripts for D2 system` |
| New clustering script | `feat: add population-weighted cluster analysis` |
