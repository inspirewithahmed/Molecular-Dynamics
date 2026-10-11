#!/usr/bin/perl

# checks that file $pep\_amd.nc is present for all peptides $pep and all
# (force field, solvation model, start conformation) combinations

$SRCDIR='/mnt/sharedfs/maral/amd_peptides';
$DESTDIR='/mnt/sharedfs/andrea/amd_peptides';
$INFIX='0_500';
$INFIX2='';

@FF=('ff99SB', 'ff99SB', 'ff14SB');
@SOLV=('TIP3P', 'OPC', 'OPC');
@PEPTIDES=('H1', 'H2', 'B1', 'B2', 'B3', 'ID1', 'ID2', 'ID3');
@STARTS=('EXTENDED','MISFOLDED');

# ith output block <-- $FF[i]-$SOLV[i] (i=0,...,@SOLV-1)
for($i=0; $i<@SOLV; $i++) {
	$ff = $FF[$i];
	$solv = $SOLV[$i];
	print "--- $ff\_$solv ---\n";

	# jth line <-- jth peptide (j=0,...,@PEPTIDES-1)
	for($j=0; $j<@PEPTIDES; ++$j) {
		$pep = $PEPTIDES[$j];
		printf "%3s: ", $pep;
		for($k=0; $k<@STARTS; ++$k) {
			$start = $STARTS[$k];
			$srcfil = "$SRCDIR/$ff\_$solv/$INFIX2/$pep/$pep\_$start/$pep\_wat.amd1.nc";
			$destfil = "$DESTDIR/$ff\_$solv/$INFIX/$pep/$pep\_$start/$pep\_wat.amd1.nc";
			chomp($diff = `diff $srcfil $destfil`);
			if(!$diff) {
				print "  -  ";
			}
			else {
				print " ERR ";
			}
		}
		print "\n";
	}
	print "\n";
}
