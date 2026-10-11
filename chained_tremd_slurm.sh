#!/bin/bash
#
# usage: bash chained_remd_cineca.sh >& chained_remd_cineca.log&
#
# setup variables
sys=D1Cl1_TR # System Name
Nmax=4 # total number (including previous run, if any) of cycles you want to do
Ncyc=4  # starting cycle; 1 if it is a new run, 2..n if it is a restart
do_equil=0 # 1 do equilibration, != 1 don't do it
nodes=1 # how many nodes?
gpu=1   # how many gpus per node?
# script starts here
# Calculate the number of replica
NG=`cat equilibrate.groupfile | wc -l`

# Calculate the number of tasks per node
tasks=$(($NG/$nodes))

here=`pwd`

if [ $do_equil -eq 1 ]; then 
	# do equilibration and remd cycle 1
	mkdir equilibration
	cd equilibration
	cp $here/equilibrate.groupfile .
	sed -i "s:-p $sys.prmtop:-p $here/$sys.prmtop:" equilibrate.groupfile
	sed -i "s:-c $sys.min.rst:-c $here/$sys.min.rst:" equilibrate.groupfile
	sed -i "s:-i equilibrate.mdin:-i $here/equilibrate.mdin:" equilibrate.groupfile
	ln -s $here/*CHIR.dat .	
	cd $here
	
	mkdir cycle_1
	cd cycle_1			
	cp $here/remd.groupfile .			
	sed -i "s:-c equilibrate.rst:-c $here/equilibration/equilibrate.rst:" remd.groupfile
	sed -i "s:-p $sys.prmtop:-p $here/$sys.prmtop:" remd.groupfile
	sed -i "s:-i remd.mdin:-i $here/remd.mdin:" remd.groupfile
	sed -i "s:-remlog rem.log:-remlog rem_R1.log:" remd.groupfile
	ln -s $here/*CHIR.dat .	
	cd $here

cat > equil_and_first_remd.slurm << EOF
#!/bin/bash
#SBATCH --job-name D1Cl1_TR
#SBATCH --nodes=$nodes
#SBATCH --gres=gpu:$gpu
#SBATCH --cpus-per-task=1
#SBATCH --ntasks-per-node=$tasks
#SBATCH --output job.out
#SBATCH --error job.err
EOF
	cat >> equil_and_first_remd.slurm << 'EOF'
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
EOF
	# submit job
	one=$(sbatch equil_and_first_remd.slurm | awk '{print $NF}')
	echo "$one started at `date`" 
	cd $here
	Ncyc=$(( $Ncyc +1 ))
else
	# do the first cycle for extended run
	pN=$(( $Ncyc - 1 ))
	if [ -d  "$here/cycle_$pN/" ]; then		
		if [ -d "cycle_$Ncyc" ]; then
			echo "cycle_$Ncyc already exist; please fix and resubmit"
			exit
		else
			mkdir cycle_$Ncyc 
		fi
		cd cycle_$Ncyc			
		cp $here/remd.groupfile .
		sed -i "s:-c equilibrate.rst:-c $here/cycle_$pN/remd.rst:" remd.groupfile
		sed -i "s:-p $sys.prmtop:-p $here/$sys.prmtop:" remd.groupfile
		sed -i "s:-i remd.mdin:-i $here/remd.mdin:" remd.groupfile
		sed -i "s:-remlog rem.log:-remlog rem_R$Ncyc.log:" remd.groupfile
		ln -s $here/*CHIR.dat .
		cat > remd_$Ncyc.slurm << EOF
#!/bin/bash
#SBATCH --job-name D1Cl1_TR
#SBATCH --nodes=$nodes
#SBATCH --gres=gpu:$gpu
#SBATCH --cpus-per-task=1
#SBATCH --ntasks-per-node=$tasks
#SBATCH --output job.out
#SBATCH --error job.err
EOF
	cat >> remd_$Ncyc.slurm << 'EOF'
# start from launch dir
cd $SLURM_SUBMIT_DIR

# load amber module + mpi environment
source /data/software/amber24/amber24.sh

# Calculate the number of replica
NG=`cat remd.groupfile | wc -l`

# do remd (no backbone restraints production run)

mpirun --mca btl_tcp_if_include 10.8.0.0/24 -np $NG pmemd.cuda.MPI -ng $NG -groupfile remd.groupfile
wait
exit
EOF
		# submit job
		one=$(sbatch remd_$Ncyc.slurm | awk '{print $NF}')
		echo "$one started at `date`" 
		cd $here
		Ncyc=$(( $Ncyc +1 ))
	else 
		echo "cycle_$pN directory do not exist; please fix and resubmit"
		exit 0
	fi
fi

# do additional remd cycles
while [ $Ncyc -le $Nmax ];
do
	echo "creating cycle $Ncyc directory" 
	mkdir cycle_$Ncyc
	cd cycle_$Ncyc			
	cp $here/remd.groupfile .
	pN=$(( $Ncyc - 1 ))
	sed -i "s:-c equilibrate.rst:-c $here/cycle_$pN/remd.rst:" remd.groupfile
	sed -i "s:-p $sys.prmtop:-p $here/$sys.prmtop:" remd.groupfile
	sed -i "s:-i remd.mdin:-i $here/remd.mdin:" remd.groupfile
	sed -i "s:-remlog rem.log:-remlog rem_R$Ncyc.log:" remd.groupfile
	ln -s $here/*CHIR.dat .
	cat > remd_$Ncyc.slurm << EOF
#!/bin/bash
#SBATCH --job-name D1Cl1_TR
#SBATCH --nodes=$nodes
#SBATCH --gres=gpu:$gpu
#SBATCH --cpus-per-task=1
#SBATCH --ntasks-per-node=$tasks
#SBATCH --output job.out
#SBATCH --error job.err
EOF
	cat >> remd_$Ncyc.slurm << 'EOF'
# start from launch dir
cd $SLURM_SUBMIT_DIR

# load amber module + mpi environment
source /data/software/amber24/amber24.sh

# Calculate the number of replica
NG=`cat remd.groupfile | wc -l`

# do remd (no backbone restraints production run)
mpirun --mca btl_tcp_if_include 10.8.0.0/24 -np $NG pmemd.cuda.MPI -ng $NG -groupfile remd.groupfile
wait
exit
EOF
	#submit job
	two=$(sbatch --dependency=afterok:$one remd_$Ncyc.slurm | awk '{print $NF}')
	one=$two	
	cd $here
	Ncyc=$(( $Ncyc +1 ))
done



