#!/usr/bin/perl -w

#########################################################################################
# Computes output probabilities of a PLA file.											#
#																						#
# USAGE: perl compute-stats.pl [PLA File] 												#
#		[PLA File] = PLA file benchmark													#
#																						#
# Author: Ahmad Tariq Sheikh.															#
#																						#
# Date: September 15, 2013																#
#																						#
#########################################################################################

use Cwd;
use Time::HiRes;
use File::Basename;


sub computeDontCares {
	my $string = $_[0];
	my $dashCount = 0;
	
	foreach $i (0..length($string)-1) {
		$char = substr $string, $i, 1;
		if ($char eq "-") {
			$dashCount++;
		}
	}
	return $dashCount;
}
#######################################################

sub readPLAFile {		
	print "\tReading $inputFile file ...\n";
	my $start_time = [Time::HiRes::gettimeofday()];	

	open (FILE, "$inputFile") or die $!;			

	while (<FILE>) {
		chomp;
		if($_ =~ m/\.i\s(.*)/) {
			if ($1 =~ m/(\d+)/) {
				$numberOfPrimaryInputs = $1;
			}			
		}
		elsif($_ =~ /\.o\s(.*)/i) {			
			if ($1 =~ m/(\d+)/) {				
				$numberOfPrimaryOutputs = $1;
			}			
		}
		elsif($_ =~ m/\.p\s(.*)/) {
			if ($1 =~ m/(\d+)/) 	{
				$sop = $1;
			}			
		}	
		elsif($_ =~ m/\.ilb\s/) {			
		}	
		elsif($_ =~ /\.ob\s/) {			
		}	
		elsif($_ =~ m/phase\s/) {			
		}
		elsif($_ =~ m/e/) {
			last;			
		}		
		else {
			$row = [ split ];					
			$dashCount = computeDontCares(@$row[0]);
			$weight = 2**$dashCount;
			$totalSops += $weight;					
			
			foreach $index (0..length(@$row[1]) - 1) {
				$bit = substr @$row[1], $index, 1;				
				if ($bit eq 0) {
					$probOfZero{$index} += $weight*1;
				}
				elsif ($bit eq 1) {
					$probOfOne{$index} += $weight*1;
				}
				elsif ($bit eq "~") {
					$probOfZero{$index} += 0;
					$probOfOne{$index} += 0;
				}
			}
		}				
	}
	close(FILE);	
	
	my $run_time = Time::HiRes::tv_interval($start_time);
	print  "\tTime taken Reading PLA file = $run_time sec.\n";
	
	# print "Total SOPs = $totalSops \n";
	# print "Inputs = $numberOfPrimaryInputs\nOutputs = $numberOfPrimaryOutputs\nSOPs = $sop \n";
	# exit;
}
#######################################################

$cwd = getcwd; #get Current Working Directory
$inputFile = $ARGV[0]; #input PLA file.

$numberOfPrimaryInputs = 0;
$numberOfPrimaryOutputs = 0;
$sop = 0;
%probOfZero = ();
%probOfOne = ();
%phase = ();
%phaseForReliableFile = ();
$totalSops = 0;
$phase = ();
$phaseForReliableFile = ();

$fileName = fileparse($inputFile, ".pla");
$outStatsFile = $fileName.".STATS";

readPLAFile();

#-------------------------------------------
#	Printing the Probabilities
#-------------------------------------------
open (OUTPUT_FILE, ">$outStatsFile") or die "Cannot open the file for writing";
print OUTPUT_FILE "Outputs\t\tProb. Of 0\t\tProb. of 1\n";
print OUTPUT_FILE "----------------------------------------\n";
foreach $index (0..$numberOfPrimaryOutputs - 1)  {	
	my $prob0 = 0;
	my $prob1 = 0;
	
	if (!exists($probOfZero{$index})) {
		$prob0 = 0;
		$probOfZero{$index} = 0;
	}
	else {
		$prob0 = $probOfZero{$index}/$totalSops;		
	}
	if (!exists($probOfOne{$index})) {
		$prob1 = 0;
		$probOfOne{$index} = 0;
	}
	else {
		$prob1 = $probOfOne{$index}/$totalSops;			
	}
	printf(OUTPUT_FILE " O$index\t\t%.4f($probOfZero{$index})\t%.4f($probOfOne{$index})\n", $prob0, $prob1);
}
close(OUTPUT_FILE);