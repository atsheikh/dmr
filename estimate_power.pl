#!/usr/bin/perl -w

$inputFile = $ARGV[0]; 


$eqnFile = $inputFile.".eqn";
# $blifFile = $inputFile.".blif";


open(OUT, ">script1") or die $!;
print OUT "read_eqn $eqnFile\n";
# print OUT "read_blif $blifFile\n";
print OUT "read_library syn.genlib\n";
print OUT "map\n";
# print OUT "power_estimate -m SAMPLING -n 100\n";
print OUT "power_estimate\n";
print OUT "quit\n";
close(OUT);

system("sis < script1");

system("rm -rf script1");
