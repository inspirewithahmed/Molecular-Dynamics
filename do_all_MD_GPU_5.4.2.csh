#!/bin/tcsh -f
#
# Written by A. Contini, 2014
#
# Given a directory containing multiple .top and .crd files and a directory 
# "protocol" with MD input files, this script prepares,launches and analyzes all MDs.
# It is mandatory that .top and .crd files use the following standard names:
# "PDB_CODE"_wat.top and "PDB_CODE"_wat.crd
#
# sintax: tcsh do_all_MD_GPU_5.4.csh >& do_all_MD_GPU_5.4.log &
#
# Amber needs to be installed
# pmemd.GPU needs to be installed; both standard and DPFP pmemd versions need to be compiled
#
# changelog from previous version
# v5.4.1 Dec 2016: trajectories are saved in NetCDF format (include protocol_NPT_NetCDF directory)
#				   all restart file changed to .rst7 for auto-recognition by VMD
#				   trajectories are also wrapped into the center box
# v5.4 Oct 22th 2015: added the possibility to extend previous MD run
#
######################################################
# HERE ARE VARIABLES THAT NEED TO BE MODIFIED BY USER#
######################################################
#
set length = 1 # set number of 1 ns cycles of production MD to be run
set extend = 0 # is this an extension of a previus job? 0 = no; >0 = yes
#
set AMBER = /data/software/amber22 # modify accordingly to your Amber installation
#
##################################################### 
# END OF USER MODIFIABLE VARIABLES                  #
#####################################################
#
source $AMBER/amber22.sh

# hardlink CUDA_VISIBLE_DEVICES for zeus, kelvin, planck
if ( "$HOSTNAME" == "kelvin" || "$HOSTNAME" == "zeus" || "$HOSTNAME" == "planck" ) then
        set load0 = `nvidia-smi -i 0 -q | grep Gpu | awk -F" " '{print $3}'`
        set load1 = `nvidia-smi -i 1 -q | grep Gpu | awk -F" " '{print $3}'`

        if ( $load0 < $load1 ) then
                setenv CUDA_VISIBLE_DEVICES 0
        else
                setenv CUDA_VISIBLE_DEVICES 1
        endif

        echo "job is running on $HOSTNAME on GPU $CUDA_VISIBLE_DEVICES"
endif

#
setenv WORKDIR `pwd`
#
# do some preliminary checks
#
cd $WORKDIR
if (! -d protocol) then
	echo "protocol directory not found"
	exit
else        
	if ( $extend == 0 ) then
		# prepare directories and do MD
		foreach z (`ls *top | sed "s/_wat.top//g"`)		
			mkdir $WORKDIR/$z
			mv $WORKDIR/$z*.* $WORKDIR/$z
                	cd $WORKDIR/$z
                	# the MD protocol begins here; modify if needed
			#do H minimization"
			$AMBERHOME/bin/pmemd.cuda_DPFP -O -i $WORKDIR/protocol/md1.inp -o "$z"_wat.equil1.out -p "$z"_wat.top -c "$z"_wat.crd -x "$z"_wat.equil1.nc -v "$z"_wat.equil1.mdvel -e "$z"_wat.equil1.mden -inf "$z"_wat.equil1.mdinfo -r "$z"_wat.equil1.rst7 -ref "$z"_wat.crd
			#do wat and ions minimization
			$AMBERHOME/bin/pmemd.cuda_DPFP -O -i $WORKDIR/protocol/md2.inp -o "$z"_wat.equil2.out -p "$z"_wat.top -c "$z"_wat.equil1.rst7 -x "$z"_wat.equil2.nc -v "$z"_wat.equil2.mdvel -e "$z"_wat.equil2.mden -inf "$z"_wat.equil2.mdinfo -r "$z"_wat.equil2.rst7 -ref "$z"_wat.equil1.rst7
			#do NVT equilibration
			$AMBERHOME/bin/pmemd.cuda -O -i $WORKDIR/protocol/md3.inp -o "$z"_wat.equil3.out -p "$z"_wat.top -c "$z"_wat.equil2.rst7 -x "$z"_wat.equil3.nc -v "$z"_wat.equil3.mdvel -e "$z"_wat.equil3.mden -inf "$z"_wat.equil3.mdinfo -r "$z"_wat.equil3.rst7 -ref "$z"_wat.equil2.rst7
			#do NPT equilibration 1 of 5
			$AMBERHOME/bin/pmemd.cuda -O -i $WORKDIR/protocol/md4.inp -o "$z"_wat.equil4A.out -p "$z"_wat.top -c "$z"_wat.equil3.rst7 -x "$z"_wat.equil4A.nc -v "$z"_wat.equil4A.mdvel -e "$z"_wat.equil4A.mden -inf "$z"_wat.equil4A.mdinfo -r "$z"_wat.equil4A.rst7 -ref "$z"_wat.equil3.rst7 
			#do NPT equilibration 2 of 5
			$AMBERHOME/bin/pmemd.cuda -O -i $WORKDIR/protocol/md4.inp -o "$z"_wat.equil4B.out -p "$z"_wat.top -c "$z"_wat.equil4A.rst7 -x "$z"_wat.equil4B.nc -v "$z"_wat.equil4B.mdvel -e "$z"_wat.equil4B.mden -inf "$z"_wat.equil4B.mdinfo -r "$z"_wat.equil4B.rst7 -ref "$z"_wat.equil4A.rst7 
			#do NPT equilibration 3 of 5
			$AMBERHOME/bin/pmemd.cuda -O -i $WORKDIR/protocol/md4.inp -o "$z"_wat.equil4C.out -p "$z"_wat.top -c "$z"_wat.equil4B.rst7 -x "$z"_wat.equil4C.nc -v "$z"_wat.equil4C.mdvel -e "$z"_wat.equil4C.mden -inf "$z"_wat.equil4C.mdinfo -r "$z"_wat.equil4C.rst7 -ref "$z"_wat.equil4B.rst7 
			#do NPT equilibration 4 of 5
			$AMBERHOME/bin/pmemd.cuda -O -i $WORKDIR/protocol/md4.inp -o "$z"_wat.equil4D.out -p "$z"_wat.top -c "$z"_wat.equil4C.rst7 -x "$z"_wat.equil4D.nc -v "$z"_wat.equil4D.mdvel -e "$z"_wat.equil4D.mden -inf "$z"_wat.equil4D.mdinfo -r "$z"_wat.equil4D.rst7 -ref "$z"_wat.equil4C.rst7 
			#do NPT equilibration 5 of 5
			$AMBERHOME/bin/pmemd.cuda -O -i $WORKDIR/protocol/md4.inp -o "$z"_wat.equil4.out -p "$z"_wat.top -c "$z"_wat.equil4D.rst7 -x "$z"_wat.equil4.nc -v "$z"_wat.equil4.mdvel -e "$z"_wat.equil4.mden -inf "$z"_wat.equil4.mdinfo -r "$z"_wat.equil4.rst7 -ref "$z"_wat.equil4D.rst7 
			#do sidechains, water and ions minimization
			$AMBERHOME/bin/pmemd.cuda_DPFP -O -i $WORKDIR/protocol/md5.inp -o "$z"_wat.equil5.out -p "$z"_wat.top -c "$z"_wat.equil4.rst7 -x "$z"_wat.equil5.nc -v "$z"_wat.equil5.mdvel -e "$z"_wat.equil5.mden -inf "$z"_wat.equil5.mdinfo -r "$z"_wat.equil5.rst7 -ref "$z"_wat.equil4.rst7
			#do total minimization (backbone restraint 10 kcal/mol)
			$AMBERHOME/bin/pmemd.cuda_DPFP -O -i $WORKDIR/protocol/md6.inp -o "$z"_wat.equil6.out -p "$z"_wat.top -c "$z"_wat.equil5.rst7 -x "$z"_wat.equil6.nc -v "$z"_wat.equil6.mdvel -e "$z"_wat.equil6.mden -inf "$z"_wat.equil6.mdinfo -r "$z"_wat.equil6.rst7 -ref "$z"_wat.equil5.rst7
			#do heating
			# heat 0->50 (backbone restraint 10 kcal/mol)
			$AMBERHOME/bin/pmemd.cuda -O -i $WORKDIR/protocol/heat1.in -o "$z"_wat.equil7.heat1.out -p "$z"_wat.top -c "$z"_wat.equil6.rst7 -x "$z"_wat.equil7.heat1.nc -r "$z"_wat.equil7.heat1.rst7 -ref "$z"_wat.equil6.rst7
			# heat 50->100 (backbone restraint 9 kcal/mol)
			$AMBERHOME/bin/pmemd.cuda -O -i $WORKDIR/protocol/heat2.in -o "$z"_wat.equil7.heat2.out -p "$z"_wat.top -c "$z"_wat.equil7.heat1.rst7 -x "$z"_wat.equil7.heat2.nc -r "$z"_wat.equil7.heat2.rst7 -ref "$z"_wat.equil7.heat1.rst7 
			# heat 100->150 (backbone restraint 8 kcal/mol)
			$AMBERHOME/bin/pmemd.cuda -O -i $WORKDIR/protocol/heat3.in -o "$z"_wat.equil7.heat3.out -p "$z"_wat.top -c "$z"_wat.equil7.heat2.rst7 -x "$z"_wat.equil7.heat3.nc -r "$z"_wat.equil7.heat3.rst7 -ref "$z"_wat.equil7.heat2.rst7 
			# heat 150->200 (backbone restraint 7 kcal/mol)
			$AMBERHOME/bin/pmemd.cuda -O -i $WORKDIR/protocol/heat4.in -o "$z"_wat.equil7.heat4.out -p "$z"_wat.top -c "$z"_wat.equil7.heat3.rst7 -x "$z"_wat.equil7.heat4.nc -r "$z"_wat.equil7.heat4.rst7 -ref "$z"_wat.equil7.heat3.rst7 
			# heat 200->250 (backbone restraint 6 kcal/mol)
		        $AMBERHOME/bin/pmemd.cuda -O -i $WORKDIR/protocol/heat5.in -o "$z"_wat.equil7.heat5.out -p "$z"_wat.top -c "$z"_wat.equil7.heat4.rst7 -x "$z"_wat.equil7.heat5.nc -r "$z"_wat.equil7.heat5.rst7 -ref "$z"_wat.equil7.heat4.rst7 
			# heat 250->300 (backbone restraint 5 kcal/mol)
			$AMBERHOME/bin/pmemd.cuda -O -i $WORKDIR/protocol/heat6.in -o "$z"_wat.equil7.heat6.out -p "$z"_wat.top -c "$z"_wat.equil7.heat5.rst7 -x "$z"_wat.equil7.heat6.nc -r "$z"_wat.equil7.heat6.rst7 -ref "$z"_wat.equil7.heat5.rst7  
			#do NVT MD 100ps (backbone restraint 5 kcal/mol)
			$AMBERHOME/bin/pmemd.cuda -O -i $WORKDIR/protocol/md7.inp -o "$z"_wat.equil7.out -p "$z"_wat.top -c "$z"_wat.equil7.heat6.rst7 -x "$z"_wat.equil7.nc -v "$z"_wat.equil7.mdvel -e "$z"_wat.equil7.mden -inf "$z"_wat.equil7.mdinfo -r "$z"_wat.equil7.rst7 -ref "$z"_wat.equil7.heat6.rst7
			#do NPT MD 100ps (backbone restraint 5 kcal/mol)
			$AMBERHOME/bin/pmemd.cuda -O -i $WORKDIR/protocol/md8.inp -o "$z"_wat.equil8.out -p "$z"_wat.top -c "$z"_wat.equil7.rst7 -x "$z"_wat.equil8.nc -v "$z"_wat.equil8.mdvel -e "$z"_wat.equil8.mden -inf "$z"_wat.equil8.mdinfo -r "$z"_wat.equil8.rst7 -ref "$z"_wat.equil7.rst7
			#do NPT MD 100ps (backbone restraint 4 kcal/mol)
			$AMBERHOME/bin/pmemd.cuda -O -i $WORKDIR/protocol/md9.inp -o "$z"_wat.equil9.out -p "$z"_wat.top -c "$z"_wat.equil8.rst7 -x "$z"_wat.equil9.nc -v "$z"_wat.equil9.mdvel -e "$z"_wat.equil9.mden -inf "$z"_wat.equil9.mdinfo -r "$z"_wat.equil9.rst7 -ref "$z"_wat.equil8.rst7
			#do NPT MD 100ps (backbone restraint 3 kcal/mol)
			$AMBERHOME/bin/pmemd.cuda -O -i $WORKDIR/protocol/md10.inp -o "$z"_wat.equil10.out -p "$z"_wat.top -c "$z"_wat.equil9.rst7 -x "$z"_wat.equil10.nc -v "$z"_wat.equil10.mdvel -e "$z"_wat.equil10.mden -inf "$z"_wat.equil10.mdinfo -r "$z"_wat.equil10.rst7 -ref "$z"_wat.equil9.rst7
			#do NPT MD 100ps (backbone restraint 2 kcal/mol)
			$AMBERHOME/bin/pmemd.cuda -O -i $WORKDIR/protocol/md11.inp -o "$z"_wat.equil11.out -p "$z"_wat.top -c "$z"_wat.equil10.rst7 -x "$z"_wat.equil11.nc -v "$z"_wat.equil11.mdvel -e "$z"_wat.equil11.mden -inf "$z"_wat.equil11.mdinfo -r "$z"_wat.equil11.rst7 -ref "$z"_wat.equil10.rst7
			#do NPT MD 500ps (backbone restraint 1 kcal/mol, equilibration)
			$AMBERHOME/bin/pmemd.cuda -O -i $WORKDIR/protocol/md12.inp -o "$z"_wat.equil12.out -p "$z"_wat.top -c "$z"_wat.equil11.rst7 -x "$z"_wat.equil12.nc -v "$z"_wat.equil12.mdvel -e "$z"_wat.equil12.mden -inf "$z"_wat.equil12.mdinfo -r "$z"_wat.equil12.rst7 -ref "$z"_wat.equil11.rst7
			#do NPT MD 500ps (no backbone restraint, equilibration)
                        $AMBERHOME/bin/pmemd.cuda -O -i $WORKDIR/protocol/md13.inp -o "$z"_wat.equil13.out -p "$z"_wat.top -c "$z"_wat.equil12.rst7 -x "$z"_wat.equil13.nc -v "$z"_wat.equil13.mdvel -e "$z"_wat.equil13.mden -inf "$z"_wat.equil13.mdinfo -r "$z"_wat.equil13.rst7
	
        		# equilibration ends, production starts
			echo "equil ended on "`date`
		
                	#do f.rst7 NPT MD 1000ps (no backbone restraints production run)
			$AMBERHOME/bin/pmemd.cuda -O -i $WORKDIR/protocol/md14.inp -o "$z"_wat.prod1.out -p "$z"_wat.top -c "$z"_wat.equil13.rst7 -x "$z"_wat.prod1.nc -v "$z"_wat.prod1.mdvel -e "$z"_wat.prod1.mden -inf "$z"_wat.prod1.mdinfo -r "$z"_wat.prod1.rst7
			
                        #do additional NPT MD 1000ps cycles, if requested
                        if ( $length > 1 ) then
                		@ x=2
                        	@ y=( $x - 1 ) 
                        	while ( $x <= $length)	
					$AMBERHOME/bin/pmemd.cuda -O -i $WORKDIR/protocol/md14.inp -o "$z"_wat.prod$x.out -p "$z"_wat.top -c "$z"_wat.prod$y.rst7 -x "$z"_wat.prod$x.nc -v "$z"_wat.prod$x.mdvel -e "$z"_wat.prod$x.mden -inf "$z"_wat.prod$x.mdinfo -r "$z"_wat.prod$x.rst7
					@ x=( $x + 1 )
                                	@ y=( $x - 1 )
                        	end
                	endif
			
                        # production ends
			echo "production ended on "`date`
                	rm "$z"_wat.equil.nc
		end
        else
        	# extend previous run
                if ( $length == 1 ) then
                	echo "If you are extending a previous run, please set length > 1"
                        exit
        	else
        	if ( $length > 1 ) then
			# if you are extending a MD run locally, you'll probably have folders containg .top and .nc or .rst7 from previous run;
                        # if you are extending a MD run remotely, you'll probably find easier to upload just .top and .rst7 files
                        set topol = `ls *top | wc -l`
			if ( "$topol" != "0" ) then
				foreach z (`ls *.top | sed "s/_wat.top//g"`)		
					mkdir $WORKDIR/$z
					mv $WORKDIR/$z*.* $WORKDIR/$z
                                end
                        endif
                        foreach z (`ls */*.top | awk -F "/" '{print $1}'`)		
                		cd $WORKDIR/$z
                        	@ x=( 1 + `ls *prod*.rst7 | awk -F "." '{print $2}' | sed 's/prod//g' | awk 'max=="" || $1 > max {max=$1} END{print max}'` )
                        	@ y=( $x - 1 ) 
                        	if ( $y >= $length ) then
                        		echo "please set a higher length"
                        	else
                                	echo "MD extension of $z started on "`date`
                                        while ( $x <= $length)
                                        	$AMBERHOME/bin/pmemd.cuda -O -i $WORKDIR/protocol/md14.inp -o "$z"_wat.prod$x.out -p "$z"_wat.top -c "$z"_wat.prod$y.rst7 -x "$z"_wat.prod$x.nc -v "$z"_wat.prod$x.mdvel -e "$z"_wat.prod$x.mden -inf "$z"_wat.prod$x.mdinfo -r "$z"_wat.prod$x.rst7
						@ x=( $x + 1 )
                                		@ y=( $x - 1 )
                        		end
                                        echo "MD extension of $z terminated on "`date`
                                endif
                        end
                endif
	endif        
endif
