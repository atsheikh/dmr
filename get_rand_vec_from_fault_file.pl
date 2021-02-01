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
use Time::HiRes;
use File::Basename;

sub readFaultsFile {		
	
	my $start_time = [Time::HiRes::gettimeofday()];
	
	open (FILE, "$inputFile") or die $!;		

	while (<FILE>) {
		chomp;
		if ($_ =~ m/\*/) {	
			$flag = 1;
			next;			
		}
		elsif($_ =~ m/Number of primary inputs(.*)/) {						
		}
		elsif($_ =~ m/Number of primary outputs(.*)/) {			
		}
		elsif($_ =~ m/Number of combinational gates(.*)/) {			
		}
		elsif($_ =~ m/Number of flip-flops(.*)/) {					
		}
		elsif($_ =~ m/Level of the circuit(.*)/) {						
		}
		elsif($_ =~ m/Number of test patterns applied(.*)/) {
		}
		elsif($_ =~ m/Number of collapsed faults(.*)/) {
		}
		elsif($_ =~ m/Number of detected faults(.*)/) {
		}
		elsif($_ =~ m/Number of undetected faults(.*)/) {
		}
		elsif($_ =~ m/Fault coverage(.*)/) {
		}
		elsif (!$flag) {
			$row = [ split ];
			if (@$row[0] =~ m/test/) {					
				push @testVectors, @$row[2];
			}			
		}		
	}
	close(FILE);	
	my $run_time = Time::HiRes::tv_interval($start_time);
	print  "\tTime taken Reading Faults file = $run_time sec.\n\n";
}
#######################################################


$cwd = getcwd; #get Current Working Directory
$inputFile = $ARGV[0]; #input PLA file.

$fileName = fileparse($inputFile, ".faults");
$outStatsFile = $fileName.".vecs";

readFaultsFile();

#-------------------------------------------
#	Printing the Probabilities
#-------------------------------------------
open (OUTPUT_FILE, ">$outStatsFile") or die "Cannot open the file for writing";
foreach $index (0..scalar @testVectors - 1)  {	
	print OUTPUT_FILE "$testVectors[$index] \n";
}
close(OUTPUT_FILE);