#!/bin/bash
#SBATCH --job-name B1E-ff19
#SBATCH --nodes=1
#SBATCH --gres=gpu:1
#SBATCH --cpus-per-task=1
#SBATCH --ntasks-per-node=1
#SBATCH --output job.out
#SBATCH --error job.err
#SBATCH --no-requeue
#SBATCH --exclude=zeus,planck,kelvin,gibbs,born

################################################################################
#                                                                              #
#                         launch_aMD_plus_analysis.sh                          #
#                                                                              #
# Launches an accelerated molecular dynamics simulation and the subsequent     #
# analysis via the SLURM system.                                               #
#                                                                              #
# INPUT (RUNNING MODE 1):                                                      #
#  - In the current directory:                                                 #
#    - File $PEPID.seq, containing the amino acid sequence of the peptide in   #
#      three-letter code. The sequence must be on one line, with amino acid    #
#      names separated by spaces.                                              #
#                                                                              #
# INPUT (RUNNING MODE 2):                                                      #
#  - In the current directory:                                                 #
#    - File $PEPID.pdb, containing the starting structure of the peptide. The  #
#      PDB file must contain atom names that are understood by tleap with no   #
#      errors.                                                                 #
#                                                                              #
# INPUT (CONTINUATION MODE):                                                   #
#  - In the current directory:                                                 #
#    - File amd_$PEPID.in: protocol for each aMD iteration                     #
#    - equilibration/$PEPID/$PEPID\_wat.top: topology file of solvated peptide #
#    - $PEPID\_wat.amd_{X}.rst7: last restart file produced by previous        #
#      simulation. Here, {X} denotes the zero-padded three-digit               #
#      representation of some integer X.                                       #
#    - $PEPID\_wat.amd_{1}.log,...,$PEPID\_wat.amd_{X-1}.log: log files of     #
#      aMD iterations 1 through X-1.                                           #
#    - $PEPID\_wat.amd_{1}.nc,...,$PEPID\_wat.amd_{X-1}.nc: trajectory files   #
#      of aMD iterations 1 through X-1.                                        #
#                                                                              #
# PRIMARY OUTPUT:                                                              #
#  In the current directory:                                                   #
#   - the output of inst_aMD.pl (see that script)                              #
#   - the output of inst_aMD-analysis.pl (see that script)                     #
#   - amd_out_and_err.txt: error and output messages from inst_aMD.pl          #
#   - amd_analysis_out_and_err.txt: error and output messages from             #
#     inst_aMD-analysis.pl                                                     #
#                                                                              #
# SECONDARY OUTPUT:                                                            #
#   - inst_aMD.pl: instance of aMD.pl relative to this particular simulation   #
#   - inst_aMD-analysis.pl: corresponding instance of aMD-analysis.pl          #
#                                                                              #
# ASSUMPTIONS:                                                                 #
#  - variables $FFIELD, $SOLV, $PEPID, $NNAA, AMD_NUM_CHUNKS, and $PCA_REFDIR  #
#    are initialized correctly.                                                #
#  - variable $AMD_BASEDIR is the absolute path to the directory containing    #
#    aMD.pl and aMD-analysis.pl.                                               #
#  - variables $NON_NATURAL_AA_DIR and $AMD_BASEDIR in aMD.pl are specified    #
#    correctly.                                                                #
#  - variables $PRINTDIH, $PLOTTER, $FLOSTATS, $AMBERHOME, $AMBERBIN,          #
#    $AMBERPY, and $AMBERLIB in aMD-analysis.pl are specified correctly.       #
#  - if $PCA_REFDIR is not '', files PCA_REFPDB, PCA_REFTOP, PCA_REFVEC, and   #
#    PCA_REF_MIN_MAX as specified in aMD-analysis.pl must be present.          #
#                                                                              #
################################################################################

BASEDIR=/mnt/sharedfs/andrea/amd_peptides/ff19SB_OPC/0_1500/B1/B1_EXTENDED
LOCDIR=/home/andrea/scratch/B1-1100

source /data/software/amber22/amber22.sh

cd $LOCDIR

./inst_aMD.pl &> amd_out_and_err.txt

echo copying output files to launch directory
rm -fr $BASEDIR/equilibration
rm -fr $BASEDIR/preparation
rm -fr $BASEDIR/analysis
rm $BASEDIR/*
cp -r * $BASEDIR
echo done
