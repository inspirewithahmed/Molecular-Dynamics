#!/usr/bin/perl


iterative_aMD('amd_H2.in', 'H2_wat.top', 1, 10, 'H2_wat');

#
# SUBROUTINE: iterative_aMD()
#
# PURPOSE: performs a number of aMD iterations for a given biological system
#
# ARGUMENTS:
#  ---> $AMD_IN: path to a file containing the aMD protocol
#  ---> $TOPOLOGY: path to a file containing the system's topology
#  ---> $START_ITER: index of the start iteration (must be > 0)
#  ---> $MAX_ITER: index of the last iteration
#  ---> $SYSID: system identifier
#
# INPUT:
#  - $SYSID.amd_{$START_ITER-1}.rst7: start rst file
#
# OUTPUT:
#  - File $SYSID.amd_{i}.rst7 for each i in {$START_ITER,...,$MAX_ITER}.
#    The file is the output .rst file of iteration i.
#  - File $SYSID.amd_{i}.out for each i in {$START_ITER,...,$MAX_ITER}.
#    The file is the output .out file of iteration i.
#  - File $SYSID.amd_{i}.nc for each i in {$START_ITER,...,$MAX_ITER}.
#    The file is the output .nc file of iteration i.
#  - File $SYSID.amd_{i}.log for each i in {$START_ITER,...,$MAX_ITER}.
#    The file is the output amd.log file of iteration i.
#
# NOTES:
#  - In the above documentation, {x} indicates the zero-padded three-digit
#    representation of integer x
#  - The script creates temporary files amd.log and mdinfo
#
sub iterative_aMD() {

	my $AMD_IN = $_[0];
	my $TOPOLOGY = $_[1];
	my $START_ITER = $_[2];
	my $MAX_ITER = $_[3];
	my $SYSID = $_[4];

	my $start3 = sprintf "%03d", ($START_ITER-1);
	my $in_rst = "$SYSID.amd_$start3.rst7";
	if(!(-e $in_rst)) {
		print "ERROR: cannot find aMD start rst file $in_rst\n";
		exit;
	}

	for($i=$START_ITER; $i<=$MAX_ITER; ++$i) {

		my $i3 = sprintf "%03d", $i;
		my $out_rst = "$SYSID.amd_$i3.rst7";
		my $out_out = "$SYSID.amd_$i3.out";
		my $out_nc = "$SYSID.amd_$i3.nc";
		my $out_log = "$SYSID.amd_$i3.log";

		`pmemd.cuda -O -i $AMD_IN -o $out_out -p $TOPOLOGY -c $in_rst -x $out_nc -r $out_rst`;
		if(!(`cat $out_out` =~ 'Final Performance Info')) {
			print "ERROR: failed aMD iteration $i\n";
			exit;
		}
		`mv amd.log $out_log`;
		`rm mdinfo`;

		$in_rst = $out_rst;
	}
}
