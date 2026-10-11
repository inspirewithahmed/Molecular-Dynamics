#!/usr/bin/perl
################################################################################
#                                                                              #
#                              print-dihedrals.pl                              #
#                                                                              #
# Prints cpptraj's 'dihedral' statements for all phi and psi angles of         #
# residues 2 through N-1 for a protein with N residues.                        #
#                                                                              #
# ARGUMENTS:                                                                   #
#  ---> $N: number of residues in the protein.                                 #                     
#                                                                              #
# OUTPUT:                                                                      #
#  - On screen, can be seen as a sequence of N-2 blocks, each composed of      #
#    two lines. The ith block contains the 'dihedral' statement for phi(i+1)   #
#    on the first line, and the the 'dihedral' statement for psi(i+1) on the   #
#    second line (i=1,..,N-2)                                                  #
#                                                                              #
################################################################################

$N = $ARGV[0];

for($i=2; $i<$N; $i++) {
	
	$prev = $i-1;
	$next = $i+1;

	print "dihedral phi$i :$prev\@C :$i\@N :$i\@CA :$i\@C out Phi$i\_Psi$i.dat\n";
	print "dihedral psi$i :$i\@N :$i\@CA :$i\@C :$next\@N out Phi$i\_Psi$i.dat\n";
}
