#########################################################################################
# Description: 	This file splits the pla file into multiple PLAs depending on the 		#
#				the number of outputs. 										 			#
#																						#
#																						#
# USAGE: perl splitPLA.pl [PLA file] 													#
#		[PLA File] = original PLA file.													#
# 																						#
# 																						#
# Author: Ahmad Tariq Sheikh.															#
#																						#
# Date: Sep 04, 2013																	#
#																						#
#########################################################################################

#!/usr/bin/perl -w

use warnings;
use Cwd;
use Time::HiRes;
use File::Basename;
use Data::Dumper qw(Dumper); 
#---------------------

sub readMINPLAFile {		

	$minPLA = $_[0];
	
	print "\tReading MIN PLA $minPLA file ...\n";
	my $start_time = [Time::HiRes::gettimeofday()];	

	open (FILE, "$minPLA") or die $!;			

	while (<FILE>) {
		#chomp;
		if($_ =~ m/\.i\s(.*)/) {
			if ($1 =~ m/(\d+)/) {				
			}			
		}
		elsif($_ =~ /\.o\s(.*)/i) {			
			if ($1 =~ m/(\d+)/) {								
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
			push @inputPLARows, $_;
		}				
	}
	close(FILE);	
	
	my $run_time = Time::HiRes::tv_interval($start_time);
	print  "\tTime taken Reading MIN PLA file = $run_time sec.\n";		
}
#######################################################


sub readAndSplitPLAFile {		
	print "\tReading $inputFile file ...\n";
	
	my $fileHeader = ();
	my $phaseInfo = ();
	
	my %input = ();
	my %output = ();
	my $counter = 0;
	
	my $start_time = [Time::HiRes::gettimeofday()];	

	open (FILE, "$inputFile") or die $!;			

	while (<FILE>) {
		chomp;
		if($_ =~ m/\.i\s(.*)/) {
			$fileHeader .= $_."\n";
			if ($1 =~ m/(\d+)/) {
				$numberOfPrimaryInputs = $1;				
			}			
		}
		elsif($_ =~ /\.o\s(.*)/i) {						
			if ($1 =~ m/(\d+)/) {				
				$numberOfPrimaryOutputs = $1;						
				$fileHeader .= ".o 1\n";
			}			
		}
		elsif($_ =~ m/\.p\s(.*)/) {
			$fileHeader .= $_."\n";
			if ($1 =~ m/(\d+)/) 	{
				$sop = $1;
			}			
		}	
		elsif($_ =~ m/\.ilb\s/) {			
			$fileHeader .= $_."\n";
		}	
		elsif($_ =~ /\.ob\s/) {			
			$fileHeader .= $_."\n";
		}			
		elsif($_ =~ m/e/) {			
			last;			
		}		
		else {
			$row = [ split ];	
			$input{$counter} = @$row[0];
			$output{$counter} = @$row[1];		
			$counter++;			
		}				
	}
	close(FILE);	
	
	#create PLA files.
	foreach $i (0..$numberOfPrimaryOutputs - 1)  {
		$outFile = $fileName."_$i.pla";
		open (OUT,  ">$outFile") or die $!;	
		
		#Write header to the out file.
		print OUT $fileHeader;
		print OUT ".phase ".substr($phaseIn, $i, 1)."\n";
		
		#write the remaining parts.
		foreach $k (0..$counter - 1)  {
			print OUT $input{$k}." ";
			print OUT substr($output{$k}, $i, 1)."\n";
		}
		print OUT ".e\n";
		
			
		# Perform two level single output minimization with espresso.
		# DONOT change the following 2 lines unless desire to change
		# the synthesis mechanism.
		$out = $fileName."_$i"."_min.pla";
		
		system("espresso -Dso $outFile > $out");		
		# system("rm -rf $outFile");

		close(OUT);
	}
	
	my $run_time = Time::HiRes::tv_interval($start_time);
	print  "\tTime taken Reading PLA file = $run_time sec.\n";
}
#######################################################


sub creatBenchFromPla {

	@allgates = ();
	%inputs = ();
	%inverterList = ();
	$gatesCounter = 0;
	
	foreach $output (0..$numberOfPrimaryOutputs - 1) {
	
		$minFile = $fileName."_$output"."_min.pla";
		$benchFile = $fileName."_$output".".bench";
		
		print "MIN FILE: $minFile\n";
		print "BENCH FILE: $benchFile\n"; 
		
		readMINPLAFile($minFile);
		
		# print "IN:\n@inputPLARows\n";
					
		open (OUT, ">$benchFile") or die $!;
		
		#Create outputs
		print OUT "\n#$benchFile\n";
		print OUT "#$numberOfPrimaryInputs inputs\n";
		print OUT "#1 output\n\n";
		
		foreach $i (0..$numberOfPrimaryInputs - 1) {
			print OUT "INPUT(v$i)\n";
		}		
		print OUT "\n";		
		
		print OUT "OUTPUT(v".$numberOfPrimaryInputs."_$output)\n";		
		print OUT "\n";
		
		my @rowGates = ();
		foreach $plaRow (@inputPLARows) {
						
			@row = split(" ", $plaRow);
			@row = split("", $row[0]);
			
			@temp = ();			
			
			foreach $ii (0..scalar @row - 1) {
			
				if ($row[$ii] eq "0") {
					#If inverter of current Input doesnot exist, then we insert new inverter
					if (!(exists($inverterList{$ii}))) {
						$gatesCounter++;
						$inverterList{$ii} = "g$gatesCounter";
						push @allgates, "g$gatesCounter";
						$inputs{"g$gatesCounter"} = "NOT-v$ii";						
						push @temp, "g$gatesCounter";
					}
					else {
						push @temp, $inverterList{$ii};
					}
				}
				elsif ($row[$ii] ne "-") {
					push @temp, "v$ii";
				}
			}#Iteration through a row ends here
			
			my $conn = join("-", @temp);
			$gatesCounter++;
			push @rowGates, "g$gatesCounter";
			push @allgates, "g$gatesCounter";
			$inputs{"g$gatesCounter"} = "AND-$conn";			
			
			# print "CONN: $conn\n"; 
			# print "GC: $gatesCounter\n";
			# print "All Gates: @allgates\n";					
		}
		
		$gatesCounter++;
		push @allgates, "v".$numberOfPrimaryInputs."_$output";
		$inputs{"v".$numberOfPrimaryInputs."_$output"} = "OR-".join("-", @rowGates);
		
		# print "All Gates: @allgates\n";
		# print Dumper \%inputs;		
			
		foreach $gate (@allgates) {
			
			@row = split("-", $inputs{$gate});
			
			my @conString = ();
			print OUT "$gate = $row[0](";
			for ($k=1; $k < scalar @row; $k++) {
				push @conString, $row[$k];
			}
			$string = join(", ", @conString);
			print OUT "$string)\n";
			
			if (grep {$_ eq $gate} @primaryOutputs) {
				print OUT "\n";
			}
		}
		
		
		close (OUT);		
		@inputPLARows = ();		

		system("dos2unix $benchFile");
	}
}
#######################################################

#-----------------------------------------------
#		Main Program
#-----------------------------------------------

$cwd = getcwd; #get Current Working Directory
$inputFile = $ARGV[0]; #PLA file.
$phaseIn = $ARGV[1]; #phase in

#-----------------------------------------------
#		Variables Initialization
#-----------------------------------------------

@inputPLARows = ();
$numberOfPrimaryInputs = 0;
$numberOfPrimaryOutputs = 0;
$sop = 0;
$fileName = fileparse($inputFile, ".pla");
#-----------------------------------------------

readAndSplitPLAFile();
creatBenchFromPla();


