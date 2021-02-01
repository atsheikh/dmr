#!/usr/bin/perl -w

#########################################################################################
# Rertieves Random Vectors from Faults File.											#
#																						#
#																						#
# Author: Ahmad Tariq Sheikh.															#
#																						#
# Date: February 25, 2014																#
#																						#
#########################################################################################

use Cwd;
use Bit::Vector;
srand(time ^ $$);

$cwd = getcwd; #get Current Working Directory
my $length = $ARGV[0]; #length of each binary vector.
my $inFile = $ARGV[1]; #length of each binary vector.


#-------------------------------------------
#	Generating Random Vectors.
#-------------------------------------------
open (OUTPUT_FILE, ">$inFile.test") or die "Cannot open the file for writing";

if ($length > 20) {
	for ($m = 0; $m < 1000000; $m++) { 
		$bin = ();
		for ($n = 1; $n <= $length; $n++) {
			$rn = rand(1);
			if ($rn > 0.5) {
				$bin .= 1;
			}
			else {
				$bin .= 0;
			}
		}
		print OUTPUT_FILE "$m: $bin\n";
	
	}
}
else {
	for ($m = 0; $m < (2**$length); $m++) { 
		$bin = ();
		my $vec = Bit::Vector->new_Dec($length, $m);
		my $bin = $vec->to_Bin();		
		print OUTPUT_FILE "$m: $bin\n";	
	}
}



close (OUTPUT_FILE);