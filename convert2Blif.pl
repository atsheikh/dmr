#!/usr/bin/perl -w

$inputFile = $ARGV[0]; #input PLA file.


$benchFile = $inputFile.".bench";
$blifFile = $inputFile.".blif";


open(OUT, ">script1") or die $!;
print OUT "read_bench $benchFile\n";
print OUT "write_blif $blifFile\n";
print OUT "quit\n";
close(OUT);

system("abc < script1");

system("del script1");
system("dos2unix $blifFile");