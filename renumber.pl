#!/usr/bin/perl
################################################################################
#                                                                              #
#                                 renumber.pl                                  #
#                                                                              #
# Renumbers the residues in a PDB file.                                        #
#                                                                              #
# ARGUMENT:                                                                    #
#  - PDBFILE: path to the PDB file.                                            #
#                                                                              #
# NOTES:                                                                       #
#  - the output file is printed on screen.                                     #
#  - The i-th residue in the input protein is assigned index i, for            #
#    i=1,...,N, where N is the number of residues.                             #
#                                                                              #
# ASSUMPTIONS:                                                                 #
#  - the PDB file contains only one protein chain.                             #
#  - no HETATM records describe the protein atoms.                             #
#                                                                              #
################################################################################

open(PDB, "<$ARGV[0]");

# go to the first ATOM record (while printing)
while($line=<PDB>) {
  if(substr($line, 0, 4) eq 'ATOM') {
    last;
  }
  else {
    print $line;
  }
}

# renumber (while printing)
$REPCOD = ' ';
$repidx = sprintf "%4d", 1;

$oldidx = substr($line, 22, 4, $repidx);
$oldcod = substr($line, 26, 1, $REPCOD);
print $line;
while($line=<PDB>) {

  $recname = substr($line, 0, 6);
  if(($recname eq 'ATOM  ') || ($recname eq 'ANISOU')) {
    $newidx = substr($line, 22, 4);
    $newcod = substr($line, 26, 1);
    if(($newidx ne $oldidx) || ($newcod ne $oldcod)) {
      $repidx =~ /(\d+)/;
      $ri = $1;
      $repidx = sprintf "%4d", ++$ri;
    }
    $oldidx = substr($line, 22, 4, $repidx);
    $oldcod = substr($line, 26, 1, $REPCOD);
  }
  print $line;
}
