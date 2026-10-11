#!/bin/bash
#SBATCH --job-name amd 
#SBATCH --nodes=1
#SBATCH --gres=gpu:1
#SBATCH --cpus-per-task=1
#SBATCH --ntasks-per-node=1
#SBATCH --output job.out
#SBATCH --error job.err
#SBATCH --no-requeue
#SBATCH --exclude=
#SBATCH --exclude=born

################################################################################
#                                                                                #
#                         launch_aMD_plus_analysis.sh                            #
#                                                                                #
# Launches an accelerated molecular dynamics simulation and the subsequent       #
# analysis via the SLURM system.                                                 #
#                                                                                #
# INPUT (RUNNING MODE 1):                                                        #
#  - In the current directory:                                                   #
#    - File $PEPID.seq, containing the amino acid sequence of the peptide in     #
#      three-letter code. The sequence must be on one line, with amino acid      #
#      names separated by spaces.                                                #
#                                                                                #
# INPUT (RUNNING MODE 2):                                                        #
#  - In the current directory:                                                   #
#    - File $PEPID.pdb, containing the starting structure of the peptide. The    #
#      PDB file must contain atom names that are understood by tleap with no     #
#      errors.                                                                   #
#                                                                                #
# INPUT (CONTINUATION MODE):                                                     #
#  - In the current directory:                                                   #
#    - File amd_$PEPID.in: protocol for each aMD iteration                       #
#    - equilibration/$PEPID/$PEPID\.prmtop: prmtopology file of solvated peptide #
#    - $PEPID\.amd_{X}.rst7: last restart file produced by previous              #
#      simulation. Here, {X} denotes the zero-padded three-digit                 #
#      representation of some integer X.                                         #
#    - $PEPID\.amd_{1}.log,...,$PEPID\.amd_{X-1}.log: log files of               #
#      aMD iterations 1 through X-1.                                             #
#    - $PEPID\.amd_{1}.nc,...,$PEPID\.amd_{X-1}.nc: trajectory files             #
#      of aMD iterations 1 through X-1.                                          #
#                                                                                #
# PRIMARY OUTPUT:                                                                #
#  In the current directory:                                                     #
#   - the output of inst_aMD.pl (see that script)                                #
#   - the output of inst_aMD-analysis.pl (see that script)                       #
#   - amd_out_and_err.txt: error and output messages from inst_aMD.pl            #
#   - amd_analysis_out_and_err.txt: error and output messages from               #
#     inst_aMD-analysis.pl                                                       #
#                                                                                #
# SECONDARY OUTPUT:                                                              #
#   - inst_aMD.pl: instance of aMD.pl relative to this particular simulation     #
#   - inst_aMD-analysis.pl: corresponding instance of aMD-analysis.pl            #
#                                                                                #
# ASSUMPTIONS:                                                                   #
#  - variables $FFIELD, $SOLV, $PEPID, $NNAA, AMD_NUM_CHUNKS, and $PCA_REFDIR    #
#    are initialized correctly.                                                  #
#  - variable $AMD_BASEDIR is the absolute path to the directory containing      #
#    aMD.pl and aMD-analysis.pl.                                                 #
#  - variables $NON_NATURAL_AA_DIR and $AMD_BASEDIR in aMD.pl are specified      #
#    correctly.                                                                  #
#  - variables $PRINTDIH, $PLOTTER, $FLOSTATS, $AMBERHOME, $AMBERBIN,            #
#    $AMBERPY, and $AMBERLIB in aMD-analysis.pl are specified correctly.         #
#  - if $PCA_REFDIR is not '', files PCA_REFPDB, PCA_REFTOP, PCA_REFVEC, and     #
#    PCA_REF_MIN_MAX as specified in aMD-analysis.pl must be present.            #
#                                                                                #
# ATTENTION:                                                                     #
# - in this version AMD_BASEDIR is set in crescenzo directory                    #
# - you should modify $amd_work_dir like the directory you are                   #
#   working in                                                                   #
#                                                                                #
##################################################################################
source /data/software/amber22/amber22.sh                                          
# force field: can be ff14SB or ff99SB                                          
FFIELD=ff19SB

# solvation model: can be opc or tip3p
#SOLV=tip3p

# peptide id
PEPID=BOC-ALA-RFP-ALA-BDP-OME 

# list of non-natural amino acids in the peptide (e.g., "'AIB', 'TBT'"). Use "" for an empty list.
NNAA="'BDP', 'BOC', 'BSP', 'OME', 'RFP', 'SFP'"

# number of iterations into which aMD is decomposed
AMD_NUM_CHUNKS=50

# path to 'analysis' directory of reference trajectory ('' for no reference)
PCA_REFDIR='/mnt/sharedfs/ahmed/Clorofenile'

###################### DO NOT MODIFY BELOW THIS LINE ##########################

AMD_BASEDIR='/mnt/sharedfs/ahmed/script_andrea/'

user=`whoami`
#amd_work_dir=/home/$user/scratch/$PEPID-$SLURM_JOB_ID
amd_work_dir=$SLURM_SUBMIT_DIR
#mkdir -p $amd_work_dir
hostname
echo copying input files to local scratch directory
#cp -r * $amd_work_dir
cd $amd_work_dir
cp $AMD_BASEDIR/cuda_device.sh .
# aMD simulation
echo doing aMD simulation
cp $AMD_BASEDIR/aMD_implicit.pl inst_aMD.pl
sed -i "s/!!!PEPID!!!/$PEPID/" inst_aMD.pl
sed -i "s/!!!FFIELD!!!/$FFIELD/" inst_aMD.pl
sed -i "s/!!!SOLV!!!/$SOLV/" inst_aMD.pl
sed -i "s/!!!AMD_NUM_CHUNKS!!!/$AMD_NUM_CHUNKS/" inst_aMD.pl
if [ "$NNAA" = '' ]
then
	sed -i "s/!!!NNAA!!!//" inst_aMD.pl
else
	sed -i "s/!!!NNAA!!!/$NNAA/" inst_aMD.pl
fi

./inst_aMD.pl &> amd_out_and_err.txt
errors=`grep ERROR amd_out_and_err.txt | wc -l`
if [ $errors -gt 0 ]
then
	echo "aMD has errors. Leaving."
	exit;
fi

# aMD analysis
echo doing aMD analysis
cp $AMD_BASEDIR/aMD_implicit-analysis.pl inst_aMD-analysis.pl
# source amber in the script also
sed -i '1i\source /data/software/amber22/amber22.sh' inst_aMD-analysis.pl
cp equilibration/$PEPID/$PEPID.prmtop .

sed -i "s/!!!TRAJECTORY!!!/$PEPID.amd.nc/" inst_aMD-analysis.pl
sed -i "s/!!!TOPOLOGY!!!/$PEPID.prmtop/" inst_aMD-analysis.pl
sed -i "s/!!!AMDLOG!!!/$PEPID.amd.log/" inst_aMD-analysis.pl

if [ "$PCA_REFDIR" = '' ]
then
	sed -i "s/!!!PCA_REFDIR!!!//" inst_aMD-analysis.pl
else
	PCA_REFDIR=${PCA_REFDIR//\//\\/}
	sed -i "s/!!!PCA_REFDIR!!!/$PCA_REFDIR/" inst_aMD-analysis.pl
fi

NRES=`grep 'There are' equilibration/$PEPID/num_res.txt | awk {'print $3'}`
sed -i "s/!!!NRES!!!/$NRES/" inst_aMD-analysis.pl

./inst_aMD-analysis.pl &> amd_analysis_out_and_err.txt

#echo copying output files to launch directory
#rm -fr $SLURM_SUBMIT_DIR/equilibration
#rm -fr $SLURM_SUBMIT_DIR/preparation
#rm -fr $SLURM_SUBMIT_DIR/analysis
#rm $SLURM_SUBMIT_DIR/*
#cp -r * $SLURM_SUBMIT_DIR
echo done
