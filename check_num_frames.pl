#!/usr/bin/perl

#
# SUBROUTINE: check_num_frames()
#
# PURPOSE: checks that the output for a trajectory chunk has been produced for
#          the expected number of frames.
#
# ARGUMENTS:
#  ---> $LOG: path to the chunk's log file
#  ---> $TRAJECTORY: path to the chunk's trajectory file
#  ---> $TOPOLOGY: path to the topology file
#  ---> $EXP_NUM_FRAMES: expected number of frames
#
# OUTPUT:
#  - If the number of frames represented in either the log file or the
#    trajectory file is not as expected, an error message is printed and the
#    program is terminated.
#
sub check_num_frames {

	my $LOG = $_[0];
	my $TRAJECTORY = $_[1];
	my $TOPOLOGY = $_[2];
	my $EXP_NUM_FRAMES = $_[3];

	# check log file
	`wc -l $LOG` =~ /(\d+)/;
	my $nlines = $1;
	if($EXP_NUM_FRAMES != ($nlines - 3)) {
		printf "ERROR: in $LOG expected $EXP_NUM_FRAMES frames, but found %d\n", $nlines - 3;
		exit;
	}

	# check trajectory file
	open(CHECKF, ">check_num_frames.traj");
	print CHECKF "parm $TOPOLOGY\n";
	print CHECKF "trajin $TRAJECTORY\n";
	print CHECKF "trajout trj_chunk.nc\n";
	close(CHECKF);
	my $trajout = `cpptraj < check_num_frames.traj`;
	$trajout =~ /Coordinate processing will occur on (\S+) frames/;
	my $num_frames = $1;
	if($num_frames != $EXP_NUM_FRAMES) {
		printf "ERROR: in $TRAJECTORY expected $EXP_NUM_FRAMES frames, but found %d\n", $num_frames;
		exit;
	}

	`rm trj_chunk.nc check_num_frames.traj`;
}

check_num_frames('../../unit-tests/H1/H1_wat.amd.log', '../../unit-tests/H1/H1_wat.amd.nc', '../../unit-tests/H1/equilibration/H1/H1_wat.top', 20);
