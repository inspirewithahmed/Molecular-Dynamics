#!/bin/bash
##################### SLURM setup #####################
#SBATCH --job-name=Ref_aMD
#SBATCH --nodes=1
#SBATCH --gres=gpu:1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH --output=job.%j.out
#SBATCH --error=job.%j.err
#SBATCH --no-requeue
#SBATCH --exclude=born,boltzmann
#######################################################

set -euo pipefail

# ==============================
# Load AMBER environment (FIXED for strict bash)
# ==============================
set +u
source /data/software/amber24/amber24.sh
set -u

# ==============================
# System parameters
# ==============================
sys=D1_Ref_TIP3P

PRMTOP="${sys}.prmtop"
RST7="amd_${sys}.rst7"
INPUT="amd.in"

# ==============================
# Job info
# ==============================
echo "======================================"
echo "Job ID   : $SLURM_JOB_ID"
echo "Node     : $(hostname)"
echo "System   : $sys"
echo "Start    : $(date)"
echo "======================================"

# ==============================
# GPU check (critical fix for your cluster)
# ==============================
echo "GPU status:"
nvidia-smi || {
    echo "ERROR: GPU not available on this node"
    exit 1
}

# ==============================
# File checks
# ==============================
for f in "$INPUT" "$PRMTOP" "$RST7"; do
    if [ ! -f "$f" ]; then
        echo "ERROR: Missing file $f"
        exit 1
    fi
done

# ==============================
# Run explicit-solvent aMD (GPU)
# ==============================
echo "Starting EXPLICIT aMD (pmemd.cuda)..."

pmemd.cuda -O \
    -i "$INPUT" \
    -o ${sys}.amd.out \
    -p "$PRMTOP" \
    -c "$RST7" \
    -r ${sys}.amd.rst7 \
    -x ${sys}.amd.nc \
    -inf ${sys}.amd.mdinfo

# ==============================
# Safety check
# ==============================
if [ $? -ne 0 ]; then
    echo "❌ AMBER FAILED"
    exit 1
fi

echo "======================================"
echo "Simulation completed successfully"
echo "End time: $(date)"
echo "======================================"
