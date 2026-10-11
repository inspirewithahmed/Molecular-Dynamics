#!/bin/tcsh
#SBATCH --job-name cpptraj
#SBATCH --exclude=born,gibbs # can add one or more nodes like kelvin,joule,gibbs,zeus,planck
#SBATCH --nodes=1
##SBATCH --gres=gpu:1
#SBATCH --cpus-per-task=2
#SBATCH --ntasks-per-node=1
#SBATCH --output job.%j.out
#SBATCH --error job.%j.err

source /data/software/amber24/amber24.sh


/data/software/amber24/bin/cpptraj -i pca.in
