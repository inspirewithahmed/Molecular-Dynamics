#!/bin/bash
#SBATCH --job-name D1Cl1_TR
#SBATCH --nodes=1
#SBATCH --gres=gpu:1
#SBATCH --cpus-per-task=1
#SBATCH --ntasks-per-node=20
#SBATCH --output job.out
#SBATCH --error job.err
# start from launch dir
cd $SLURM_SUBMIT_DIR

# load amber module + mpi environment
source /data/software/amber24/amber24.sh

# Calculate the number of replica
NG=`cat equilibrate.groupfile | wc -l`

# do equilibration
cd $SLURM_SUBMIT_DIR/equilibration
mpirun --mca btl_tcp_if_include 10.8.0.0/24 -np $NG pmemd.cuda.MPI -ng $NG -groupfile equilibrate.groupfile
wait

# go into workdir and launch batch script
cd $SLURM_SUBMIT_DIR/cycle_1

# run job
mpirun --mca btl_tcp_if_include 10.8.0.0/24 -np $NG pmemd.cuda.MPI -ng $NG  -groupfile remd.groupfile
wait

#go back to launch dir
cd $SLURM_SUBMIT_DIR
exit
