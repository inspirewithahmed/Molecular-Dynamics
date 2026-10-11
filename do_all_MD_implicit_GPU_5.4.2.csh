#!/bin/tcsh -f
#
# Written by A. Contini, 2014
#
# Given a directory containing multiple .prmtop and .crd files and a directory 
# "protocol" with MD input files, this script prepares,launches and analyzes all MDs.
# It is mandatory that .prmtop and .crd files use the following standard names:
# "PDB_CODE"_wat.prmtop and "PDB_CODE"_wat.crd
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
if ( "$HOSTNAME" == "Boltzmann" || "$HOSTNAME" == "franklin" || "$HOSTNAME" == "planck" || "$HOSTNAME" == "marie" ) then
        set load0 = `nvidia-smi -i 0 -q | grep Gpu | awk -F" " '{print $3}'`
        set load1 = `nvidia-smi -i 1 -q | grep Gpu | awk -F" " '{print $3}'`

        if ( $load0 < $load1 ) then
                setenv CUDA_VISIBLE_DEVICES 0
        else
                setenv CUDA_VISIBLE_DEVICES 1
        endif
endif

echo "job is running on $HOSTNAME on GPU $CUDA_VISIBLE_DEVICES"
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
		foreach z (`ls *top | sed "s/.prmtop//g"`)		
			mkdir $WORKDIR/$z
			mv $WORKDIR/$z*.* $WORKDIR/$z
                	cd $WORKDIR/$z
                	# the MD protocol begins here; modify if needed
			#do total minimization (backbone restraint 10 kcal/mol)
			$AMBERHOME/bin/pmemd.cuda_DPFP -O -i $WORKDIR/protocol/md1.inp -o "$z".equil1.out -p "$z".prmtop -c "$z".crd -x "$z".equil1.nc -v "$z".equil1.mdvel -e "$z".equil1.mden -inf "$z".equil1.mdinfo -r "$z".equil1.rst7 -ref "$z".crd
			#do heating
			#do equilibation 200ps (no backbone restraint, equilibration)
                        $AMBERHOME/bin/pmemd.cuda -O -i $WORKDIR/protocol/md2.inp -o "$z".equil2.out -p "$z".prmtop -c "$z".equil1.rst7 -x "$z".equil2.nc -v "$z".equil2.mdvel -e "$z".equil2.mden -inf "$z".equil2.mdinfo -r "$z".equil2.rst7
	
        		# equilibration ends, production starts
			echo "equil ended on "`date`
		
                	#do MD 1000ps (no backbone restraints production run)
			$AMBERHOME/bin/pmemd.cuda -O -i $WORKDIR/protocol/md14.inp -o "$z".prod1.out -p "$z".prmtop -c "$z".equil2.rst7 -x "$z".prod1.nc -v "$z".prod1.mdvel -e "$z".prod1.mden -inf "$z".prod1.mdinfo -r "$z".prod1.rst7
			
                        #do additional NPT MD 1000ps cycles, if requested
                        if ( $length > 1 ) then
                		@ x=2
                        	@ y=( $x - 1 ) 
                        	while ( $x <= $length)	
					$AMBERHOME/bin/pmemd.cuda -O -i $WORKDIR/protocol/md14.inp -o "$z".prod$x.out -p "$z".prmtop -c "$z".prod$y.rst7 -x "$z".prod$x.nc -v "$z".prod$x.mdvel -e "$z".prod$x.mden -inf "$z".prod$x.mdinfo -r "$z".prod$x.rst7
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
			# if you are extending a MD run locally, you'll probably have folders containg .prmtop and .nc or .rst7 from previous run;
                        # if you are extending a MD run remotely, you'll probably find easier to upload just .prmtop and .rst7 files
                        set topol = `ls *top | wc -l`
			if ( "$topol" != "0" ) then
				foreach z (`ls *top | sed "s/.prmtop//g"`)		
					mkdir $WORKDIR/$z
					mv $WORKDIR/$z*.* $WORKDIR/$z
                                end
                        endif
                        foreach z (`ls */*.prmtop | awk -F "/" '{print $1}'`)		
                		cd $WORKDIR/$z
                        	@ x=( 1 + `ls *prod*.rst7 | awk -F "." '{print $2}' | sed 's/prod//g' | awk 'max=="" || $1 > max {max=$1} END{print max}'` )
                        	@ y=( $x - 1 ) 
                        	if ( $y >= $length ) then
                        		echo "please set a higher length"
                        	else
                                	echo "MD extension of $z started on "`date`
                                        while ( $x <= $length)
                                        	$AMBERHOME/bin/pmemd.cuda -O -i $WORKDIR/protocol/md14.inp -o "$z".prod$x.out -p "$z".prmtop -c "$z".prod$y.rst7 -x "$z".prod$x.nc -v "$z".prod$x.mdvel -e "$z".prod$x.mden -inf "$z".prod$x.mdinfo -r "$z".prod$x.rst7
						@ x=( $x + 1 )
                                		@ y=( $x - 1 )
                        		end
                                        echo "MD extension of $z terminated on "`date`
                                endif
                        end
                endif
	endif        
endif
