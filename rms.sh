#!/bin/bash
#SBATCH -J cppt_R6
#SBATCH -o stdout.%j.txt
#SBATCH -e stderr.%j.txt
#SBATCH -q acc_resa
#SBATCH --ntasks=24
#SBATCH --cpus-per-task=1 
#SBATCH --gres=gpu:1     
#SBATCH --mail-user=saeed.ahmed@upc.edu
#SBATCH --mail-type=end
##SBATCH --get-user-env
#SBATCH -t 24:00:00 

module load amber/24


cpptraj -p D2Cl1_R6_TIP3P.prmtop -i H-Bond.traj
cpptraj -p D2Cl1_R6_TIP3P.prmtop -i sasa.in
cpptraj -p D2Cl1_R6_TIP3P.prmtop -i rmsd.in
cpptraj -p D2Cl1_R6_TIP3P.prmtop -i cluster.traj
cpptraj -p D2Cl1_R6_TIP3P.prmtop -i BDP-RFP-distance.traj
cpptraj -p D2Cl1_R6_TIP3P.prmtop -i Dihedral_Angle.traj
cpptraj -p D2Cl1_R6_TIP3P.prmtop -i pi_pi_Stacking.traj
