#!/usr/bin/perl -w

use Cwd;
use Time::HiRes;
use File::Basename;
use Data::Dumper qw(Dumper);
use Storable qw(nstore retrieve);
#---------------------

sub computeStatisticeFromFaultFile {		
	
	$file = $inputFile.".log";
	
	print "\tReading $file file ... \n";
	my $start_time = [Time::HiRes::gettimeofday()];
		
	open (FILE, "$file") or die $!;		

	while (<FILE>) {
		chomp;
		if ($_ =~ m/\*/) {	
			$flag = 1;
			next;			
		}		
		elsif (!$flag) {
			$row = [ split ];
			if (@$row[0] =~ m/test/) {
				$SOPS++;				
				@currentOutput = split('', @$row[3]);				
								
				foreach $k (0..scalar @currentOutput - 1) {
					if ($currentOutput[$k] == 0) {
						$probOfZero[$k] += 1;
					}
					elsif ($currentOutput[$k] == 1) {
						$probOfOne[$k] += 1;
					}
				}				
			}#end of output vectors evaluation
		} #end of last elsif on line 232		
	}#end of while input loop
	
	close(FILE);					
	
	my $run_time = Time::HiRes::tv_interval($start_time);
	print  "\tTime taken Reading Faults file = $run_time sec.\n\n";		
}
#######################################################


#-----------------------------------------------
#		Main Program
#-----------------------------------------------

$cwd = getcwd; #get Current Working Directory
$inputFile = $ARGV[0]; #input bench file


#-----------------------------------------------
#		Variables Initialization
#-----------------------------------------------
@probOfZero = ();
@probOfOne = ();
$SOPS = 0;

computeStatisticeFromFaultFile();
$phase = ();
foreach $k (0..scalar @probOfZero - 1) {		
		if ($probOfZero[$k] > $probOfOne[$k]){
			$phase .= 0;			
		}
		else {
			$phase .= 1;			
		}
	}	
	
open (PH, ">$inputFile.txt") or die $!;
# print PH "---PHASE of $inputFile = $phase, SOPS: $SOPS\n\n";
print PH "Out\tProb. 0\tProb. 1\n";
print PH "--------------------------\n";
# foreach $k (0..scalar @probOfZero - 1) {
	# printf(PH " O$k\t\t$probOfZero[$k]\t\t$probOfOne[$k]\n");
# }

# open (PH, ">$inputFile.txt") or die $!;
foreach $k (0..scalar @probOfZero - 1) {
	printf(PH "$k\t%0.4f\t%0.4f\n", $probOfZero[$k]/$SOPS, $probOfOne[$k]/$SOPS);
}

close(PH);

