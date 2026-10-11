#!/bin/bash
##################### SLURM setup #####################
#SBATCH --job-name=AMBER_MD
#SBATCH --nodes=1
#SBATCH --gres=gpu:1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH --output=job.out
#SBATCH --error=job.err
#SBATCH --no-requeue
#SBATCH --exclude=born,boltzmann
#######################################################

set -euo pipefail

# ==============================
# Load AMBER safely
# ==============================
set +u
source /data/software/amber24/amber24.sh
set -u

# ==============================
# System definition
# ==============================
sys=D1_Ref_TIP3P

PRMTOP="${sys}.prmtop"
INPCRD="${sys}.inpcrd"
RSTFILE="md01_${sys}.restrt"
INPUT="md.inp"

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
# GPU sanity check (CRITICAL FIX)
# ==============================
echo "GPU status:"
nvidia-smi || {
    echo "ERROR: GPU not available or NVML broken"
    exit 1
}

# Avoid overloaded display GPU (VERY IMPORTANT FIX)
echo "Checking GPU compute status..."

GPU_ID=$(nvidia-smi --query-gpu=index,utilization.gpu,memory.used --format=csv,noheader,nounits \
    | sort -t, -k2 -n | head -n1 | awk '{print $1}')

export CUDA_VISIBLE_DEVICES=$GPU_ID

echo "Using GPU: $CUDA_VISIBLE_DEVICES"

# ==============================
# Restart logic (CRITICAL FIX)
# ==============================
if [ -f "$RSTFILE" ] && [ -s "$RSTFILE" ]; then
    echo "Restart file detected → continuing simulation"
    INCOORD="$RSTFILE"
else
    echo "No restart found → starting from inpcrd"
    INCOORD="$INPCRD"
fi

# ==============================
# File validation (prevents CUDA crash)
# ==============================
for f in "$INPUT" "$PRMTOP" "$INCOORD"; do
    if [ ! -f "$f" ]; then
        echo "ERROR: Missing file $f"
        exit 1
    fi
done

# ==============================
# Run AMBER (GPU)
# ==============================
echo "Launching AMBER MD..."

pmemd.cuda -O \
    -i "$INPUT" \
    -o ${sys}.mdout \
    -p "$PRMTOP" \
    -c "$INCOORD" \
    -r "$RSTFILE" \
    -x ${sys}.md.mdcrd \
    -inf ${sys}.mdinfo

STATUS=$?

# ==============================
# Failure handling
# ==============================
if [ $STATUS -ne 0 ]; then
    echo "❌ AMBER CRASH DETECTED"
    echo "Check mdout + mdinfo + job.err"
    exit 1
fi

echo "======================================"
echo "MD RUN COMPLETED SUCCESSFULLY"
echo "End time: $(date)"
echo "======================================"
