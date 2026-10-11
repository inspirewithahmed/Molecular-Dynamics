#!/bin/bash
#SBATCH --job-name=gaussian
#SBATCH --exclude=born,gibbs
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=12
#SBATCH --output job2.out
#SBATCH --error job2.err
#SBATCH --time=240:00:00

# start from launch dir
cd $SLURM_SUBMIT_DIR

# set environment variables
. /data/software/g16/bsd/g16.profile
export SCRATCH_DIR="${HOME}/scratch/${SLURM_JOB_ID}"
mkdir -p $SCRATCH_DIR
export GAUSS_SCRDIR=$SCRATCH_DIR

# set launch command
g16 DFNKF-conf-1.com

# wait for execution 
wait
echo "Job finished at $(date)"

# cleanup directories
rm -fr ${HOME}/scratch/${SLURM_JOB_ID}


