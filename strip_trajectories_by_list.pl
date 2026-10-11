#!/usr/bin/perl

# strips waters from the 0–1500 trajectory for a list of $pep\_$start experiments.

# ARGUMENTS:
#  ---> EXPLIST: path to a file containing a list of experiment identifiers. Identifiers are one per line,
#                starting at the start of the line and being immediately followed by a line terminator.
#                Identifiers have the $pep\_$start format, with $start in {EXTENDED, MISFOLDED}.
#
# INPUT:
#  For every identifier $pep\_$start in EXPLIST:
#  - ../0_1500/$pep/$pep\_$start/$pep\_wat.amd.nc
#  - ../0_1500/$pep/$pep\_$start/equilibration/$pep/$pep\_wat.top
#
# OUTPUT:
#  For every identifier $pep\_$start in EXPLIST:
#  - $pep/$pep\_$start/0-1500__imaged__closest_100.$pep\_wat.nc
#  - $pep/$pep\_$start/closest_100.$pep\_wat.top
#  - $pep/$pep\_$start/check_rms.txt

$EXP_NUM_FRAMES = 750000;

open(EXPLIST, $ARGV[0]);
while($exp = <EXPLIST>) {

	chomp($exp);
	@fields = split '_', $exp;
	$pep = $fields[0];
	
	`mkdir -p $pep/$exp`;
	chdir "$pep/$exp";

	print "$exp\n";

	# concatenate trajectories and then strip waters
	open(CATTRAJ, ">cat.traj");
	print CATTRAJ "parm ../../../0_1500/$pep/$exp/equilibration/$pep/$pep\_wat.top\n";
	print CATTRAJ "trajin ../../../0_1500/$pep/$exp/$pep\_wat.amd.nc\n";
	print CATTRAJ "autoimage\n";
	print CATTRAJ "closest 100 \@CA outprefix closest_100\n";
	print CATTRAJ "trajout 0-1500__imaged__closest_100.$pep\_wat.nc\n";
	print CATTRAJ "rms \@N,CA,C first out rms_first.dat\n";
	close(CATTRAJ);
	`cpptraj < cat.traj >cat.out 2>cat.err`;

	# check that output trajectory has expected number of frames
	open(RMSCHK, ">check_rms.txt");
	chomp(my $num_frames = `tail -n+2 rms_first.dat | wc -l`);
	if($num_frames != $EXP_NUM_FRAMES) {
           	print RMSCHK "ERROR: expected $EXP_NUM_FRAMES but found $num_frames\n";
	}
	else {
		print RMSCHK "OK: found $num_frames as expected\n";
	}
        close(RMSCHK);

	chdir '../..';
}
close(EXPLIST);
