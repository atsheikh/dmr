#########################################################################################
# Description: 	This file generates Reliable file with Duplication at gate-level and	#
#				final output gates are marked for redundancy at the transistor 			#
#				level of an input Bench file.											#
#																						#
# USAGE: perl dmr.pl [PLA File] [p]														#
#		[PLA File] 	=	PLA file benchmark												#
#		[p] 		=	If specified as 'p' then phase will be 							#
#						used to minimize each output, otherwise not.					#
#																						#
# Author: Ahmad Tariq Sheikh.															#
#																						#
# Date: October 30, 2013																#
#																						#
#########################################################################################

#!/usr/bin/perl -w

use Cwd;
use Time::HiRes;
use File::Basename;
use Data::Dumper qw(Dumper); 
use Storable qw(retrieve nstore dclone);
use Clone qw(clone);
use Sort::Naturally;
#---------------------

sub readBenchFile {
	# print "\tReading $inputFile.bench file ... \n";
	# my $start_time = [Time::HiRes::gettimeofday()];
	
	$benchFile = "$fileName.bench";
	print "B: $benchFile\n";
	open (INPUT_FILE, $benchFile) or die $!;
	
	$currentPO = ();
	$poIndexCounter = 0;
	my %tempCompleteGates = ();	
	%gateBelongings = (); 
	@primaryOutputs = ();
	@primaryInputs = ();
	@inter_IO_Gates = ();
	@allGates = ();
	@multiFanOuts = ();
	%poIndices = ();
	%inputs = ();
	%fanouts = ();
	%completeGates = ();
	%gatesCounter = ();
	%path = ();
		
	while(<INPUT_FILE>) {
		if ($_ =~ m/INPUT(.*)/) {		
			if ($1 =~ m/(\w+)/) {
				push (@primaryInputs, $1);	
			}
		}
		elsif ($_ =~ m/OUTPUT(.*)/) {
			if ($1 =~ m/(\w+)/) {
				push (@primaryOutputs, $1);					
			}
		}
		elsif ($_ =~ /#/ or $_ =~ /^\s/) {
			next;
		}		
		elsif ($_ =~ m/=/) {			
			
			my @gateList = ($_ =~ m/(\w+)/g);				
			$gateName[0] = $gateList[1];			
			@gateList = ($gateList[0], @gateList[2..$#gateList]);
				
						
			# print "@gateList,  Length = ", scalar @gateList, ", GN: $gateName[0],  POINDEX: $poIndexCounter\n";			
			# $cin=getc(STDIN); exit;
			
			if (grep {$_ eq $gateList[0]} @primaryOutputs) {
				$currentPO = shift(@primaryOutputs);
				push @primaryOutputs, $currentPO;
				$poIndices{$gateList[0]} = $poIndexCounter;
			}
			else {
				$currentPO = $primaryOutputs[0];
			}
						
			$gateBelongings{$gateList[0]} = $currentPO;
			
			#---------------------------------------------------
			# Create an output to input and input to output MAP
			#---------------------------------------------------
			my $connections = ();
			for my $i (1..scalar @gateList-1) {				
				$connections .= "$gateList[$i]";	
				if ((scalar @gateList > 1) && ($i < scalar @gateList-1)) {
					$connections .= "-";
				}
				
				if (exists($fanouts{$gateList[$i]})) {				
					$temp = $fanouts{$gateList[$i]};
					$fanouts{$gateList[$i]} = $temp."-".$gateList[0];
				}
				else {
					$fanouts{$gateList[$i]} = $gateList[0];	
				}				
			}
			$inputs{$gateList[0]} = $gateName[0]."-".$connections;	

			# if ($gateName[0] eq "NOT") {
				# if (grep {$_ eq $connections} @primaryInputs) {
					# $invertedInputs = $gateList[0];
				# }
			# }			
			
			push @inter_IO_Gates, $gateList[0];				
			#-------------------------------------------------
			
			for my $i(0..scalar @gateList - 1) {			
				if (!(exists($tempCompleteGates{$gateList[$i]}))) {				
					if ($i == 0) {					
						$tempCompleteGates{$gateList[$i]} = 0;	
						$gatesCounter{$gateList[$i]} = 0;
						$completeGates{$gateList[$i]} = 0;	
					}
					else {					
						$tempCompleteGates{$gateList[$i]} = $gateList[0];	
						$gatesCounter{$gateList[$i]} = 1;
						$completeGates{$gateList[$i]} = "$gateName[0]-$gateList[0]";	
					}
				}
				else {				
					$gatesCounter{$gateList[$i]}++;										
					if ($gatesCounter{$gateList[$i]} >= 2) {							
						$tempCompleteGates{"$gateList[$i]->$gateList[0]"} = $gateList[0];
						$tempCompleteGates{"$gateList[$i]->$tempCompleteGates{$gateList[$i]}"} = $tempCompleteGates{$gateList[$i]};												
						$gatesCounter{"$gateList[$i]->$gateList[0]"} = 0;
						$gatesCounter{"$gateList[$i]->$tempCompleteGates{$gateList[$i]}"} = 0;						
						
						if ($completeGates{$gateList[$i]} eq 0) {
							$completeGates{"$gateList[$i]->$gateList[0]"} = "$gateName[0]-$gateList[0]";	
						}
						else {
							$completeGates{"$gateList[$i]->$gateList[0]"} = "$gateName[0]-$gateList[0]";						
							@previousLine = split('-', $completeGates{$gateList[$i]});							
							$completeGates{"$gateList[$i]->$previousLine[1]"} = "$previousLine[0]-$previousLine[1]";					
							$completeGates{$gateList[$i]} = 0;
						}
					}
					else {	
						$tempCompleteGates{$gateList[$i]} = $gateList[0];							
						$completeGates{$gateList[$i]} = "$gateName[0]-$gateList[0]";													
					}
				}
			}					
			$poIndexCounter++;
		}		
	}	
	close(INPUT_FILE);	
	
	
	
	####################################################
	# Fanout Counter
	####################################################
	foreach my $node (%fanouts) {	
		
		if (exists($fanouts{$node})) {		
			# print "Node = $node, Fanouts = $fanouts{$node} \n";
			@row = split("-", $fanouts{$node});
			$fanoutCounter{$node} = scalar @row;
			if ($fanoutCounter{$node} > 1) { # and ($node =~ m/g/)) {
				push @multiFanOuts, $node;
			}			
		}
	}
	
	
	# my $run_time = Time::HiRes::tv_interval($start_time);
	# print "\tTime taken Reading Bench file = $run_time sec.\n\n";	
	
	@allGates = @{ dclone(\@inter_IO_Gates) };	
	@inter_IO_Gates = nsort @inter_IO_Gates;	
}
#######################################################

sub expandDontCares {
	my $string = $_[0];
	my $dontCares = 0;
	
	foreach $i (0..length($string)-1) {
		$char = substr $string, $i, 1;
		if ($char eq "-") {
			$dontCares++;
		}
	}	
	return $dontCares;
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
			$dontCares = expandDontCares(@$row[0]);
			$weight = 2**$dontCares;
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
}
#######################################################

sub computeStatisticsFromFaultFile {		
	
	$file = $fileName.".log";
	
	print "\tReading $file file ... \n";
	my $start_time = [Time::HiRes::gettimeofday()];
		
	open (FILE, "$file") or die $!;		

	while (<FILE>) {
		chomp;
		if ($_ =~ m/\*/) {	
			$flag = 1;
			next;			
		}
		elsif($_ =~ m/Number of primary inputs(.*)/) {
			if ($1 =~ m/(\d+)/) 	{
				$numberOfPrimaryInputs = $1;
			}			
		}
		elsif($_ =~ m/Number of primary outputs(.*)/) {
			if ($1 =~ m/(\d+)/) 	{
				$numberOfPrimaryOutputs = $1;
			}			
		}
		elsif($_ =~ m/Number of combinational gates(.*)/) {
			if ($1 =~ m/(\d+)/) 	{
				$numberOfCombGates = $1;
			}			
		}
		elsif($_ =~ m/Number of flip-flops(.*)/) {
			if ($1 =~ m/(\d+)/) 	{
				$numberOfFF = $1;
			}			
		}
		elsif($_ =~ m/Level of the circuit(.*)/) {
			if ($1 =~ m/(\d+)/) 	{
				$numberOfLevels = $1;
			}			
		}
		elsif($_ =~ m/Number of test patterns applied(.*)/) {
			if ($1 =~ m/(\d+)/) 	{
				$numberOfTestVectors = $1;
			}			
		}
		elsif($_ =~ m/Number of collapsed faults(.*)/) {
			if ($1 =~ m/(\d+)/) 	{
				$numberOfCollapsedFaults = $1;
			}			
		}
		elsif($_ =~ m/Number of detected faults(.*)/) {
			if ($1 =~ m/(\d+)/) {
				$numberOfDetectedFaults = $1;
			}			
		}
		elsif($_ =~ m/Number of undetected faults(.*)/) {
			if ($1 =~ m/(\d+)/) {
				$numberOfUndetectedFaults = $1;				
			}			
		}
		elsif($_ =~ m/Fault coverage(.*)/) {
			if ($1 =~ m/(\d+\.\d+)/) {
				$faultCoverage = $1;
			}			
		}
		elsif (!$flag) {
			$row = [ split ];
			if (@$row[0] =~ m/test/) {					
				
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

sub createPLAWithPhase {
	$phaseIn = $_[0];
	$outTemp = $inputFile.".tmp";
	
	open (IN, "$inputFile") or die $!;
	open (OUT, ">$outTemp") or die $!;
	
	$phaseFlag = 0;
	
	while (<IN>) {
		# if($_ =~ m/\.p\s(.*)/ and $phaseFlag == 0) {
		if($_ !~ m/^\./ and $phaseFlag == 0) {
			
			if ($phaseIn==-1) { #then compute the phase	
				$phase = ();
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
					
					if ($prob1 > $prob0 or $prob0 == $prob1) {
						$phase.= 1; 
						$phaseForReliableFile .= 1;

						}
					else {
						$phase.= 0;
						$phaseForReliableFile .= 0;
					}
				}			
				if ($d eq "p") {			
					print OUT ".phase $phase\n";
				}				
				$phaseFlag = 1;
			}
			else {		
				$phaseFlag = 1;
				$phase = $phaseIn;
				$phaseForReliableFile = $phaseIn;
				print OUT ".phase $phaseIn\n";				
			}
			
			print OUT $_;				
		}
		elsif($_ =~ m/phase(.*)/) {			
		}				
		else {
			print OUT $_;
		}
	}	
	close(IN);	
	close(OUT);		
	
	print "\t--Minimizing PLA with Phase $phase...\n";
	$out = $fileName."_min.pla";	
		
	# Perform two level single output minimization with espresso.
	# DONOT change the following 2 lines unless desire to change
	# the synthesis mechanism.
	system("espresso -Dso $outTemp > $out");		
	system("rm -rf $outTemp");	
	# exit;

}
#######################################################

sub synthesizeUsingSIS {
	
	open (OUT, ">synthesize.script") or die $!;
	$file = $fileName."_min.pla";	
	
	print OUT "read_pla $file\n";	
	# print OUT "fx\n";	
	# print OUT "decomp -q\n";	
	print OUT "read_library tom.mcnc.genlib\n";	
	print OUT "map\n";
	print OUT "write_blif -n $fileName.n.blif\n";
	print OUT "quit\n";	
	close(OUT);
	
	system("sis12 < synthesize.script");
	system("rm -rf utiltmp");		
	
	################################################
	#Remove line Breaks from Blif File
	################################################
	my $blifFile_IN = $fileName.".n.blif";
	my $blifFile_OUT = $fileName.".n2.blif";
	
	my $newLineBreak = 0;
	my $temp = ();

	open (OUT_BLIF, ">$filePath/$blifFile_OUT") or die $!;	
	
	print "Blif File = $blifFile_IN \n";
	open (IN_BLIF, $blifFile_IN) or die $!;	
	while(<IN_BLIF>) {
		if($_ =~ m/\\/) {
			chomp;			
			$_ =~ s/\\//;
			$temp .= $_;
			$newLineBreak = 1;
		}
		elsif(($_ !~ m/\\/) and ($newLineBreak == 1)) {
			chomp;
			print OUT_BLIF "$temp";
			print OUT_BLIF "$_\n";
			$newLineBreak = 0;
			$temp = ();
		}
		else {
			print OUT_BLIF $_;
		}
	}
		
	close(IN_BLIF);
	close(OUT_BLIF);
	
	system("move $fileName.n2.blif $fileName.n.blif");	
	system("sh script.blif.to.bench $fileName");	
	system("rm -rf $fileName.n.blif");	
	
	#Convert shared NOT gates to Independent NOT gates.
	system("perl add_not.pl $fileName");	
	system("move $fileName"."n.bench $fileName.bench");
	###############################################
	
	################################################
	#Remove Dots from Blif File
	################################################
	my $bench_TEMP = $benchFile.".temp";
	
	open (OUT_BENCH, ">$filePath/$bench_TEMP") or die $!;	

	open (INPUT_FILE, $benchFile) or die $!;		
	while (<INPUT_FILE>) {	
		if($_ =~ m/\./) {			
			$_ =~ s/\./_/;
			print OUT_BENCH $_;
		}
		else {
			print OUT_BENCH $_;
		}
	}
	close(INPUT_FILE);
	close(OUT_BENCH);
	
	system("move $bench_TEMP $benchFile");
	system("dos2unix $benchFile"); 
	################################################
}
#######################################################

sub circuitWithMajPhase {	#This function is used for TASK 1 ONLY
		
	# $ph = $_[0];
	print "================>  PH = $ph\n";
	readPLAFile();
    print "\n\tCreating PLA with or without PHASE ... \n"; 
    createPLAWithPhase($ph); 
    print "\n\tSynthesizing using SIS ... \n";  
    synthesizeUsingSIS();  
    print "\n\tReading the final created Bench file ... \n";    
    readBenchFile();
	
	my $outputsCounter = 0;
			
	print "\n\tCreating Majority Phase .bench file ... \n";	
	my $newBenchFile = $fileName."M.bench";	
	
	my $start_time = [Time::HiRes::gettimeofday()];	

	$phaseForFile = $phase;
	
	#save phase information in a hash list.
	foreach $i (0.. scalar @primaryOutputs - 1) {		
		$phase{$primaryOutputs[$i]} = substr($phase, $i, 1);	
		$phaseForFile{$primaryOutputs[$i]} = substr($phaseForFile, $i, 1);				
	}	
	
	open (OUTPUT_Bench,  ">$filePath/$newBenchFile") or die $!;	
	#-----------------------------------------------
	#Generating the Reliable file.
	#-----------------------------------------------
	print OUTPUT_Bench "# $fileName"."M\n";
	print OUTPUT_Bench "# $numberOfPrimaryInputs inputs\n";
	
	if ($d eq "p") {
		print OUTPUT_Bench "# $numberOfPrimaryOutputs outputs\n";
		print OUTPUT_Bench "# Synthesized with PHASE $phase\n\n";
	}
	else {
		print OUTPUT_Bench "# $numberOfPrimaryOutputs outputs\n";
		print OUTPUT_Bench "# Synthesized without PHASE ($phase)\n";
	}
		
	open (INPUT_FILE, $benchFile) or die $!;	
	while (<INPUT_FILE>) {	
		chomp;		
		if (/=/) {								
			my @temp = split(" = ", $_);				
			push (@gateList, $temp[0]);
			if ($temp[1] =~ m/\((.*)\)/) {			
				push (@gateList, split(", ", $1));
			}
			my @gateName = ($_ =~ m/(\w+)\(/);													
			$currentGate = $temp[0];	
			my @inputs = split("-", $inputs{$currentGate});	
			
			# print "CG = $currentGate\n";
								
			#add the final gate to the duplicate outputs.			
			if ((grep {$_ eq $currentGate} @primaryOutputs)) {						
				my $phaseBit = $phaseForFile{$currentGate};	
				# print "Gate = $currentGate, PHASE = $phaseForFile{$currentGate}\n";
				$currentGate =~ s/\./_/;	
				
				if ($phaseBit eq 1) {
					print OUTPUT_Bench "$_\n";						
				}
				elsif ($phaseBit eq 0) {						
					print OUTPUT_Bench "$currentGate"."_1 = $gateName[0](";
					for ($ii = 1; $ii < scalar @inputs; $ii++) {							
						if ($ii  == scalar @inputs - 1) {
							print OUTPUT_Bench "$inputs[$ii])\n";	
						}
						else {
							print OUTPUT_Bench "$inputs[$ii], ";	
						}							
					}						
					print OUTPUT_Bench "$currentGate = NOT($currentGate"."_1)\n";
				}						
			}
			else {
				print OUTPUT_Bench "$_\n";						
			}
		}
		elsif ($_ =~ m/OUTPUT(.*)/) {
			if ($1 =~ m/\((.*)\)/) {
				my $temp = $1;
				$temp =~ s/\./_/; #substitute dot (.) with underscore(_)
				print OUTPUT_Bench "OUTPUT($temp)\n";      
			}
		}		
		else {	
			$t = "v".($numberOfPrimaryInputs - 1);					
			if ($_ =~ /$t/) {
				print OUTPUT_Bench "INPUT($t)\n";    
				print OUTPUT_Bench "INPUT(errCntrl1)\n\n";
			}			
			else {
				print OUTPUT_Bench "$_\n";    
			}
		}
	}	
	close(INPUT_FILE);
	#-----------------------------------------------	
	
	close(OUTPUT_Bench);	
	
	my $run_time = Time::HiRes::tv_interval($start_time);
	print "\tTime taken to create Bench File = $run_time sec.\n";	
	system("dos2unix $newBenchFile");
# }
}
#######################################################

sub DMR_Proposed {
	
	$ph = $_[0];
	$finalPhase = ();
	%phaseForReliableFile = ();
	@primaryOutputs = ();
		
	for (my $k=0; $k < length($ph); $k++) {
		$cb = substr($ph, $k, 1);
		
		if ($cb eq 0) {
			$finalPhase .= 1;
		}
		elsif ($cb eq 1) {
			$finalPhase .= 0;
		}		
	}
	print "\n================>CIRCUIT = $inputFile\nMAJORITY PHASE = $ph, FINAL PH = $finalPhase\n";	
	
	readPLAFile();
    print "\n\tCreating PLA with PHASE $finalPhase... \n"; 
    createPLAWithPhase($finalPhase); 
    print "\n\tSynthesizing using SIS ... \n";  
    synthesizeUsingSIS();   
    print "\n\tReading the final created Bench file ... \n";    
    readBenchFile();
	
	# if ($d eq "p" or $d eq "P") {	
		my $outputsCounter = 0;
		my $replicationType = "R";
		
		print "\n\tCreating final Reliable .bench file ... \n";		
		my $newBenchFile = $fileName."_N.bench";	
		
		print "\n\tPhase for Reliable File ...$phaseForReliableFile\n";	
				
		my $start_time = [Time::HiRes::gettimeofday()];	

		#save phase information in a hash list.
		foreach $i (0.. scalar @primaryOutputs - 1) {		
			$phase{$primaryOutputs[$i]} = substr($finalPhase, $i, 1);	
			$phaseForReliableFile{$primaryOutputs[$i]} = substr($phaseForReliableFile, $i, 1);			
		}	
		
		open (OUTPUT_Bench,  ">$newBenchFile") or die $!;	
		#-----------------------------------------------
		#Generating the Reliable file.
		#-----------------------------------------------
		print OUTPUT_Bench "# $fileName"."WP\n";
		print OUTPUT_Bench "# $numberOfPrimaryInputs inputs\n";
		
		if ($d eq "p") {
			print OUTPUT_Bench "# $numberOfPrimaryOutputs outputs\n";
			print OUTPUT_Bench "# Synthesized with PHASE $phase\n\n";
		}
		else {
			print OUTPUT_Bench "# $numberOfPrimaryOutputs outputs\n";
			print OUTPUT_Bench "# Synthesized without PHASE ($phase)\n";
		}
			
		open (INPUT_FILE, $benchFile) or die $!;	
		while (<INPUT_FILE>) {	
			chomp;		
			if (/=/) {				
				my $errorType = 0;			
				#-------------------------------------------------
				#Generate the remaining parts of final bench file
				#-------------------------------------------------			
				my @temp = split(" = ", $_);
				push (@gateList, $temp[0]);
				if ($temp[1] =~ m/\((.*)\)/) {			
					push (@gateList, split(", ", $1));
				}
				my @gateName = ($_ =~ m/(\w+)\(/);									
				
				$currentGate = $gateList[0];
				my @inputs = split("-", $inputs{$currentGate});						
				
				$dup1 = $currentGate."_1";
				$dup1 =~ s/\./_/;			
				print OUTPUT_Bench "$dup1 = $gateName[0](";
				for ($ii = 1; $ii < scalar @inputs; $ii++) {
					if (grep $_ eq $inputs[$ii], @primaryInputs) {
						if ($ii  == scalar @inputs - 1) {
							print OUTPUT_Bench "$inputs[$ii])\n";	
						}
						else {
							print OUTPUT_Bench "$inputs[$ii], ";	
						}
					}
					else {
						if ($ii  == scalar @inputs -1) {
							if (exists($isDuplicate{$inputs[$ii]})) {
								print OUTPUT_Bench "$inputs[$ii]"."_1)\n";
							}
							else {							
								print OUTPUT_Bench "$inputs[$ii])\n";
							}
						}						
						else {
							if (exists($isDuplicate{$inputs[$ii]})) {
								print OUTPUT_Bench "$inputs[$ii]"."_1, ";
							}
							else {							
								print OUTPUT_Bench "$inputs[$ii], ";
							}
						}
					}
				}						
				$dup2 = $currentGate."_2";
				$dup2 =~ s/\./_/;
				print OUTPUT_Bench "$dup2 = $gateName[0](";
				for ($ii = 1; $ii < scalar @inputs; $ii++)
				{
					if (grep $_ eq $inputs[$ii], @primaryInputs) {
						if ($ii  == scalar @inputs -1) {
							print OUTPUT_Bench "$inputs[$ii])\n";	
						}
						else {
							print OUTPUT_Bench "$inputs[$ii], ";	
						}
					}
					else
					{
						if ($ii  == scalar @inputs -1) {
							if (exists($isDuplicate{$inputs[$ii]})) {
								print OUTPUT_Bench "$inputs[$ii]"."_2)\n";
							}
							else {							
								print OUTPUT_Bench "$inputs[$ii])\n";
							}
						}						
						else {
							if (exists($isDuplicate{$inputs[$ii]})) {
								print OUTPUT_Bench "$inputs[$ii]"."_2, ";
							}
							else {							
								print OUTPUT_Bench "$inputs[$ii], ";
							}
						}
					}
				}		
				
				#add the final gate to the duplicate outputs.			
				if ((grep {$_ eq $currentGate} @primaryOutputs)) {						
					my $phaseBit = $phaseForReliableFile{$currentGate};			
					$currentGate =~ s/\./_/;				
					if ($phaseBit eq 0) {
						print OUTPUT_Bench "$currentGate = NAND($currentGate"."_1, $currentGate"."_2)\n";						
					}
					elsif ($phaseBit eq 1) {
						# print OUTPUT_Bench "$currentGate = AND($currentGate"."_1, $currentGate"."_2)\n";
						print OUTPUT_Bench "$currentGate"."_3 = NAND($currentGate"."_1, $currentGate"."_2)\n";
						print OUTPUT_Bench "$currentGate = NOT($currentGate"."_3)\n";
					}	
					$outputsCounter++;								
				}
				
				#add duplicates of current gate in inputs hash table.
				$inputs{$dup1} = $inputs{$currentGate};
				$inputs{$dup2} = $inputs{$currentGate};
				
				$completeGates{$dup1} = $completeGates{$currentGate};
				$completeGates{$dup2} = $completeGates{$currentGate};
					
				#print "Current Gate = $currentGate \n";
				$isDuplicate{$currentGate} = 1;									
				#-------------------------------------------------
				@gateList = ();
				@gateName = ();
			}
			elsif ($_ =~ m/OUTPUT(.*)/) {
				if ($1 =~ m/\((.*)\)/) {
					my $temp = $1;
					$temp =~ s/\./_/; #substitute dot (.) with underscore(_)
					print OUTPUT_Bench "OUTPUT($temp)\n";      
				}
			}		
			else {	
				$t = "v".($numberOfPrimaryInputs - 1);	
				# print "T = $t, Dollar = $_"; $cin = getc(STDIN);
				if ($_ =~ /$t/) {
					print OUTPUT_Bench "INPUT($t)\n";    
					# print OUTPUT_Bench "INPUT(errCntrl1)\n\n";
					print OUTPUT_Bench "\n";
				}			
				else {
					print OUTPUT_Bench "$_\n";    
				}
			}
		}	
		close(INPUT_FILE);
		#-----------------------------------------------	
		
		close(OUTPUT_Bench);	
		
		my $run_time = Time::HiRes::tv_interval($start_time);
		print "\tTime taken to create Bench File = $run_time sec.\n";	
		system("dos2unix $newBenchFile");
	# }
}
#######################################################

sub DMR_WithAlternatingPhases {
	
	readPLAFile();
	
	# Compute the original phase information of input PLA file.
	# createPLAWithPhase(-1);
	# (MUST) Save the phase info in local variable.
	# $currentPhase = $phase;	
	
	#####################################################################
	# The circuit outputs have to be minimized two times. Once with 	#
	# the ON-SET and then with the OFF-SET								#
	#####################################################################
	
	# Minimize each output as OFF-SET terms 
	# and save it in a separate file.	
	$phase0 = ();
	foreach $i (0..$numberOfPrimaryOutputs - 1) {
			$phase0 .= 0;	
	}
	$phase1 = ();
	foreach $i (0..$numberOfPrimaryOutputs - 1) {
		if (substr($phase,0,1)==1) {
			$phase1 .= 0;
		}
		else {
			$phase1 .= 1;
		}
	}
	# print "Phase0 = $phase0\n";
	# print "Phase1 = $phase1\n"; exit;
	
	createPLAWithPhase($phase0); 
	synthesizeUsingSIS(); 	
	system("move $benchFile $benchFile"."0");	
				
	# Minimize each output as ON-SET terms
	# and save it in a separate file.	
	# Create PLA with custom phase. The function argument will be the new phase and 
	# original phase info will be overwritten.
	createPLAWithPhase($phase1);
	synthesizeUsingSIS();
	system("move $benchFile $benchFile"."1");	
		
	#####################################################################
	
	
	#####################################################################
	# Merge the .bench0 and .bench1 files.							  	#	
	#####################################################################
	open (OUT, ">$fileName"."_ALTP.bench") or die $!;	
	print OUT "\n";
	# print OUT "# $fileName"."_ALTP.\n";
	# print OUT "# $numberOfPrimaryInputs inputs.\n";
	# print OUT "# $numberOfPrimaryOutputs outputs\n";
	# print OUT "# ALTP denotes DMR with each output synthesized as both ON-SET and OFF-SET.\n";	
	# print OUT "# Subscript _0 denotes logic that is part of the OFF-SET.\n";
	# print OUT "# Subscript _1 denotes logic that is part of the ON-SET.\n";
	# print OUT "# GG denotes Guard Gate/C-Element.\n\n";
	# print OUT "# Phase0 = $phase0\n";
	# print OUT "# Phase1 = $phase1\n\n";	
	
	#writing the inputs and outputs.
	foreach $i (0..$numberOfPrimaryInputs - 1) {
		print OUT "INPUT(v".$i.")\n";
		push @primaryInputs, "v".$i;
	}	
	print OUT "INPUT(errCntrl1)\n";
	print OUT "\n";
	
	foreach $i (0..$numberOfPrimaryOutputs - 1) {
		# print OUT "OUTPUT(g".$numberOfPrimaryInputs."_$i"."_0)\n";
		# print OUT "OUTPUT(g".$numberOfPrimaryInputs."_$i"."_1)\n";
		# print OUT "OUTPUT(v".$numberOfPrimaryInputs."_$i"."_02)\n";
		print OUT "OUTPUT(v".$numberOfPrimaryInputs."_$i)\n";		
		push @primaryOutputs, "v".$numberOfPrimaryInputs."_$i";		
	}
	print OUT "\n";
	
	#Generarating the remaining parts for the final _ALTP bench file.
	$addr = 0;
	$flag = 0;
	open (IN0, "$fileName".".bench0") or die $!;	
	while(<IN0>) {
		if (/=/) {			
			my @temp = split(" = ", $_);
			push (@gateList, $temp[0]);
			if ($temp[1] =~ m/\((.*)\)/) {			
				push (@gateList, split(", ", $1));
			}
			my @gateName = ($_ =~ m/(\w+)\(/);	
			
			#########################################################
			#An extra condition when the final	output is derived	#
			#from a single NOT gate and the fan-in of NOT gate is	# 
			#a primary input signal.								#
			#########################################################			
			# if ((grep {$_ eq $gateList[0]} @primaryOutputs) 
				# and ($gateName[0] eq "NOT") 
				# and (grep {$_ eq $gateList[1]} @primaryInputs)) {
				
				# print OUT "$gateList[0] = QNOT($gateList[1])\n\n";
				# next;
			# }			
			#########################################################
			
			if ((grep {$_ eq $gateList[0]} @primaryOutputs)) {
				$tempOut = $gateList[0];
				$tempOut =~ s/v/g/;
				print OUT $tempOut."_01 = $gateName[0](";
			}
			else {
				print OUT $gateList[0]."_0 = $gateName[0](";
			}
			
			foreach $l (1..scalar @gateList - 1) {
				if ($l==scalar @gateList - 1) {
					if (grep {$_ eq $gateList[$l]} @primaryInputs) {
						print OUT "$gateList[$l])\n";
					}
					else {					
						print OUT "$gateList[$l]"."_0)\n";
					}
				}
				else {
					if (grep {$_ eq $gateList[$l]} @primaryInputs) {
						print OUT "$gateList[$l], ";
					}
					else {					
						print OUT "$gateList[$l]"."_0, ";
					}
				}
			}			
			if (grep {$_ eq $gateList[0]} @primaryOutputs) {
				print OUT $tempOut."_0 = NOT($tempOut"."_01)\n";
				
				open (IN1, "$fileName".".bench1") or die $!;	
				seek(IN1, $addr, 0);
				while(<IN1>) {
					$flag = 0;
					if (/=/) {						
						my @temp1 = split(" = ", $_);
						push (@gateList1, $temp1[0]);
						if ($temp1[1] =~ m/\((.*)\)/) {			
							push (@gateList1, split(", ", $1));
						}
						my @gateName1 = ($_ =~ m/(\w+)\(/);	
						
						#########################################################
						#An extra condition when the final output is derived	#
						#from a single NOT gate and the fan-in of NOT gate is	# 
						#a primary input signal.								#
						#########################################################			
						# if ((grep {$_ eq $gateList1[0]} @primaryOutputs) 
							# and ($gateName1[0] eq "NOT") 
							# and (grep {$_ eq $gateList1[1]} @primaryInputs)) {
				
								# print OUT "$gateList1[0] = QNOT($gateList1[1])\n\n";								
								# next;
						# }	
						#########################################################					
						if ((grep {$_ eq $gateList1[0]} @primaryOutputs)) {
							$tempOut = $gateList1[0];
							$tempOut =~ s/v/g/;
							print OUT $tempOut."_1 = $gateName1[0](";
						}
						else {
							print OUT $gateList1[0]."_1 = $gateName1[0](";
						}
						
						# print OUT $gateList1[0]."_1 = $gateName1[0](";
						foreach $l1 (1..scalar @gateList1 - 1) {
							if ($l1==scalar @gateList1 - 1) {
								if (grep {$_ eq $gateList1[$l1]} @primaryInputs) {
									print OUT "$gateList1[$l1])\n";
								}
								else {					
									print OUT "$gateList1[$l1]"."_1)\n";
								}
							}
							else {
								if (grep {$_ eq $gateList1[$l1]} @primaryInputs) {
									print OUT "$gateList1[$l1], ";
								}
								else {					
									print OUT "$gateList1[$l1]"."_1, ";
								}
							}
						}												
						#combine the outputs in C-Element.
						if (grep {$_ eq $gateList1[0]} @primaryOutputs) {
							$addr = tell(IN1);
							$tempOut = $gateList1[$l1];
							$tempOut =~ s/v/g/;
														
							print OUT "$gateList1[0] = OR($tempOut"."_0, $tempOut"."_1)\n\n";				
							
							# print OUT "$gateList1[0]"."_02 = OR($tempOut"."_0, $tempOut"."_1)\n";								
							# print OUT "$gateList1[0] = NOT($gateList1[0]"."_02)\n\n";				
							$flag = 1;
						}
						if ($flag==1) {
							last;
						}
					}
					@gateList1 = ();
					@gateName1 = ();	
				}
				close(IN1);				
			}
		}
		@gateList = ();
		@gateName = ();	
	}
	close(IN0);	
	close (OUT);
	#####################################################################

	my $start_time = [Time::HiRes::gettimeofday()];			
	my $run_time = Time::HiRes::tv_interval($start_time);
	print "\tTime taken to create Bench File = $run_time sec.\n";	
	system("dos2unix $fileName"."_ALTP.bench");	
	system("rm -rf $benchFile"."0");
	system("rm -rf $benchFile"."1");
	
}
#######################################################

sub DMR_WithCElement {
	
	readPLAFile();
		
	createPLAWithPhase($ph); 
	synthesizeUsingSIS(); 	
	system("move $benchFile $benchFile"."0");	
			
	createPLAWithPhase($ph);
	synthesizeUsingSIS(); 	
	readBenchFile();
	system("move $benchFile $benchFile"."1");	
	
	#####################################################################
	#save phase information in a hash list.
	%phaseForFile = ();
	foreach $i (0.. scalar @primaryOutputs - 1) {			
		$phaseForFile{$primaryOutputs[$i]} = substr($phase, $i, 1);				
	}	
	
	#####################################################################
	# Merge the .bench0 and .bench1 files.							  	#	
	#####################################################################
	open (OUT, ">$fileName"."_MAJ.bench") or die $!;	
	print OUT "\n";
	# print OUT "# $fileName"."_ALTP.\n";
	# print OUT "# $numberOfPrimaryInputs inputs.\n";
	# print OUT "# $numberOfPrimaryOutputs outputs\n";
	# print OUT "# ALTP denotes DMR with each output synthesized as both ON-SET and OFF-SET.\n";	
	# print OUT "# Subscript _0 denotes logic that is part of the OFF-SET.\n";
	# print OUT "# Subscript _1 denotes logic that is part of the ON-SET.\n";
	# print OUT "# GG denotes Guard Gate/C-Element.\n\n";
	print OUT "# Phase0 = $phase\n";
	print OUT "# Phase1 = $phase\n\n";	
	
	#writing the inputs and outputs.
	foreach $i (0..$numberOfPrimaryInputs - 1) {
		print OUT "INPUT(v".$i.")\n";
		push @primaryInputs, "v".$i;
	}	
	# print OUT "INPUT(errCntrl1)\n\n";		
	print OUT "\n";		
	
	foreach $i (0..$numberOfPrimaryOutputs - 1) {
		# print OUT "OUTPUT(g".$numberOfPrimaryInputs."_$i"."_0)\n";
		# print OUT "OUTPUT(g".$numberOfPrimaryInputs."_$i"."_1)\n";
		# print OUT "OUTPUT(v".$numberOfPrimaryInputs."_$i"."_02)\n";
		print OUT "OUTPUT(v".$numberOfPrimaryInputs."_$i)\n";		
		push @primaryOutputs, "v".$numberOfPrimaryInputs."_$i";		
	}
	print OUT "\n";		
		
	#Generarating the remaining parts for the final _ALTP bench file.
	$addr = 0;
	$flag = 0;
	open (IN0, "$fileName".".bench0") or die $!;	
	while(<IN0>) {
		if (/=/) {			
			my @temp = split(" = ", $_);
			push (@gateList, $temp[0]);
			if ($temp[1] =~ m/\((.*)\)/) {			
				push (@gateList, split(", ", $1));
			}
			my @gateName = ($_ =~ m/(\w+)\(/);	
			
			#########################################################
			#An extra condition when the final	output is derived	#
			#from a single NOT gate and the fan-in of NOT gate is	# 
			#a primary input signal.								#
			#########################################################			
			# if ((grep {$_ eq $gateList[0]} @primaryOutputs) 
				# and ($gateName[0] eq "NOT") 
				# and (grep {$_ eq $gateList[1]} @primaryInputs)) {
				
				# print OUT "$gateList[0] = QNOT($gateList[1])\n\n";
				# next;
			# }			
			#########################################################
			
			if ((grep {$_ eq $gateList[0]} @primaryOutputs)) {
				$tempOut = $gateList[0];
				$tempOut =~ s/v/g/;				
				my $phaseBit = $phaseForFile{$gateList[0]};
								
				if ($phaseBit eq 1) {
					print OUT $tempOut."_0 = $gateName[0](";
				}
				elsif ($phaseBit eq 0) {	
					print OUT $tempOut."_01 = $gateName[0](";
				}	
			}
			else {
				print OUT $gateList[0]."_0 = $gateName[0](";
			}
			
			foreach $l (1..scalar @gateList - 1) {
				if ($l==scalar @gateList - 1) {
					if (grep {$_ eq $gateList[$l]} @primaryInputs) {
						print OUT "$gateList[$l])\n";
					}
					else {					
						print OUT "$gateList[$l]"."_0)\n";
					}
				}
				else {
					if (grep {$_ eq $gateList[$l]} @primaryInputs) {
						print OUT "$gateList[$l], ";
					}
					else {					
						print OUT "$gateList[$l]"."_0, ";
					}
				}
			}			
			if (grep {$_ eq $gateList[0]} @primaryOutputs) {
				$tempOut1 = $tempOut;
				# $tempOut =~ s/g/v/;					
				if ($phaseForFile{$gateList[0]} eq 0) {	
					print OUT $tempOut."_0 = NOT($tempOut1"."_01)\n";
				}	
						
				open (IN1, "$fileName".".bench1") or die $!;	
				seek(IN1, $addr, 0);
				while(<IN1>) {
					$flag = 0;
					if (/=/) {						
						my @temp1 = split(" = ", $_);
						push (@gateList1, $temp1[0]);
						if ($temp1[1] =~ m/\((.*)\)/) {			
							push (@gateList1, split(", ", $1));
						}
						my @gateName1 = ($_ =~ m/(\w+)\(/);	
						
						#########################################################
						#An extra condition when the final output is derived	#
						#from a single NOT gate and the fan-in of NOT gate is	# 
						#a primary input signal.								#
						#########################################################			
						# if ((grep {$_ eq $gateList1[0]} @primaryOutputs) 
							# and ($gateName1[0] eq "NOT") 
							# and (grep {$_ eq $gateList1[1]} @primaryInputs)) {
				
								# print OUT "$gateList1[0] = QNOT($gateList1[1])\n\n";								
								# next;
						# }	
						#########################################################					
						if ((grep {$_ eq $gateList1[0]} @primaryOutputs)) {
							$tempOut = $gateList1[0];
							my $phaseBit = $phaseForFile{$gateList1[0]};	
							# print "Gate = $gateList1[0], PHASE = $phaseForFile{$gateList1[0]}, PH = $phase\n";
							$currentGate =~ s/\./_/;	
							$tempOut =~ s/v/g/;		
							
							if ($phaseBit eq 1) {
								print OUT $tempOut."_1 = $gateName1[0](";
							}
							elsif ($phaseBit eq 0) {	
								print OUT $tempOut."_02 = $gateName1[0](";
							}							
						}
						else {
							print OUT $gateList1[0]."_1 = $gateName1[0](";
						}						
						
						foreach $l1 (1..scalar @gateList1 - 1) {
							if ($l1==scalar @gateList1 - 1) {
								if (grep {$_ eq $gateList1[$l1]} @primaryInputs) {
									print OUT "$gateList1[$l1])\n";
								}
								else {					
									print OUT "$gateList1[$l1]"."_1)\n";
								}
							}
							else {
								if (grep {$_ eq $gateList1[$l1]} @primaryInputs) {
									print OUT "$gateList1[$l1], ";
								}
								else {					
									print OUT "$gateList1[$l1]"."_1, ";
								}
							}
						}	
						
						$tempOut1 = $tempOut;
						if ($phaseForFile{$gateList1[0]} eq 0) {	
							print OUT $tempOut."_1 = NOT($tempOut1"."_02)\n";
						}							
						
						#combine the outputs in C-Element.
						if (grep {$_ eq $gateList1[0]} @primaryOutputs) {
							$addr = tell(IN1);
							my $phaseBit = $phaseForFile{$gateList1[0]};	
							$tempOut = $gateList[$l1];
							$tempOut =~ s/v/g/;							
							
							print OUT "$gateList1[0]  = DGG($tempOut"."_0, $tempOut"."_1)\n\n";				
							
							# print OUT "$gateList1[0]"."_02  = OR($tempOut"."_0, $tempOut"."_1)\n";								
							# print OUT "$gateList1[0] = NOT($gateList1[0]"."_02)\n\n";			
							$flag = 1;
						}
						if ($flag==1) {
							last;
						}
					}
					@gateList1 = ();
					@gateName1 = ();	
				}
				close(IN1);				
			}
		}
		@gateList = ();
		@gateName = ();	
	}
	close(IN0);	
	close (OUT);
	#####################################################################

	my $start_time = [Time::HiRes::gettimeofday()];			
	my $run_time = Time::HiRes::tv_interval($start_time);
	print "\tTime taken to create Bench File = $run_time sec.\n";	
	system("dos2unix $fileName"."_MAJ.bench");	
	system("rm -rf $benchFile"."0");
	system("rm -rf $benchFile"."1");
	
}
#######################################################

sub DMR_WithCustomPhases {
	
	
	readPLAFile();
	
	$phase0 = ();
	$phase1 = ();
	$threshold = 0.55;	
	
	########################################
	# Read the phase info from .txt file
	########################################	
	open (IN, "$fileName.txt") or die $!;
	while(<IN>) {
		@row = split(" ", $_);
		$prob0 = $row[1];
		$prob1 = $row[2];
		
		if ($prob0 >= $threshold) {
			$phase0 .= 0;
			$phase1 .= 0;
		}
		elsif ($prob1 >= $threshold) {
			$phase0 .= 1;
			$phase1 .= 1;
		}
		else {
			$phase0 .= 0;
			$phase1 .= 1;
		}
		
	}
	close(IN);
		
	# print "PHASE 0 = $phase0\n";
	# print "PHASE 1 = $phase1\n";
	# exit;
		
	createPLAWithPhase($phase0); 
	synthesizeUsingSIS(); 	
	system("move $benchFile $benchFile"."0");	
			
	createPLAWithPhase($phase1);
	synthesizeUsingSIS(); 	
	readBenchFile();
	system("move $benchFile $benchFile"."1");		
	
	#####################################################################
	#save phase information in a hash list.
	%phase0ForFile = ();
	%phase1ForFile = ();
	foreach $i (0.. scalar @primaryOutputs - 1) {			
		$phase0ForFile{$primaryOutputs[$i]} = substr($phase0, $i, 1);				
		$phase1ForFile{$primaryOutputs[$i]} = substr($phase1, $i, 1);				
	}	
	
	#####################################################################
	# Merge the .bench0 and .bench1 files.							  	#	
	#####################################################################
	open (OUT, ">$fileName"."_CP$threshold.bench") or die $!;	
	print OUT "\n";	
	print OUT "# Phase0 = $phase0\n";
	print OUT "# Phase1 = $phase1\n\n";	
	
	#writing the inputs and outputs.
	foreach $i (0..$numberOfPrimaryInputs - 1) {
		print OUT "INPUT(v".$i.")\n";
		push @primaryInputs, "v".$i;
	}	
	# print OUT "INPUT(errCntrl1)\n\n";		
	print OUT "\n";		
	
	foreach $i (0..$numberOfPrimaryOutputs - 1) {
		# print OUT "OUTPUT(g".$numberOfPrimaryInputs."_$i"."_0)\n";
		# print OUT "OUTPUT(g".$numberOfPrimaryInputs."_$i"."_1)\n";
		# print OUT "OUTPUT(v".$numberOfPrimaryInputs."_$i"."_02)\n";
		print OUT "OUTPUT(v".$numberOfPrimaryInputs."_$i)\n";		
		push @primaryOutputs, "v".$numberOfPrimaryInputs."_$i";		
	}
	print OUT "\n";		
		
	#Generarating the remaining parts for the final _ALTP bench file.
	$addr = 0;
	$flag = 0;
	open (IN0, "$fileName".".bench0") or die $!;	
	while(<IN0>) {
		if (/=/) {			
			my @temp = split(" = ", $_);
			push (@gateList, $temp[0]);
			if ($temp[1] =~ m/\((.*)\)/) {			
				push (@gateList, split(", ", $1));
			}
			my @gateName = ($_ =~ m/(\w+)\(/);	
			
			#########################################################
			#An extra condition when the final	output is derived	#
			#from a single NOT gate and the fan-in of NOT gate is	# 
			#a primary input signal.								#
			#########################################################			
			# if ((grep {$_ eq $gateList[0]} @primaryOutputs) 
				# and ($gateName[0] eq "NOT") 
				# and (grep {$_ eq $gateList[1]} @primaryInputs)) {
				
				# print OUT "$gateList[0] = QNOT($gateList[1])\n\n";
				# next;
			# }			
			#########################################################
			
			if ((grep {$_ eq $gateList[0]} @primaryOutputs)) {
				$tempOut = $gateList[0];
				$tempOut =~ s/v/g/;				
				my $phaseBit = $phase0ForFile{$gateList[0]};
								
				if ($phaseBit eq 1) {
					print OUT $tempOut."_0 = $gateName[0](";
				}
				elsif ($phaseBit eq 0) {	
					print OUT $tempOut."_01 = $gateName[0](";
				}	
			}
			else {
				print OUT $gateList[0]."_0 = $gateName[0](";
			}
			
			foreach $l (1..scalar @gateList - 1) {
				if ($l==scalar @gateList - 1) {
					if (grep {$_ eq $gateList[$l]} @primaryInputs) {
						print OUT "$gateList[$l])\n";
					}
					else {					
						print OUT "$gateList[$l]"."_0)\n";
					}
				}
				else {
					if (grep {$_ eq $gateList[$l]} @primaryInputs) {
						print OUT "$gateList[$l], ";
					}
					else {					
						print OUT "$gateList[$l]"."_0, ";
					}
				}
			}			
			if (grep {$_ eq $gateList[0]} @primaryOutputs) {
				$tempOut1 = $tempOut;
				# $tempOut =~ s/g/v/;					
				if ($phase0ForFile{$gateList[0]} eq 0) {	
					print OUT $tempOut."_0 = NOT($tempOut1"."_01)\n";
				}	
						
				open (IN1, "$fileName".".bench1") or die $!;	
				seek(IN1, $addr, 0);
				while(<IN1>) {
					$flag = 0;
					if (/=/) {						
						my @temp1 = split(" = ", $_);
						push (@gateList1, $temp1[0]);
						if ($temp1[1] =~ m/\((.*)\)/) {			
							push (@gateList1, split(", ", $1));
						}
						my @gateName1 = ($_ =~ m/(\w+)\(/);	
						
						#########################################################
						#An extra condition when the final output is derived	#
						#from a single NOT gate and the fan-in of NOT gate is	# 
						#a primary input signal.								#
						#########################################################			
						# if ((grep {$_ eq $gateList1[0]} @primaryOutputs) 
							# and ($gateName1[0] eq "NOT") 
							# and (grep {$_ eq $gateList1[1]} @primaryInputs)) {
				
								# print OUT "$gateList1[0] = QNOT($gateList1[1])\n\n";								
								# next;
						# }	
						#########################################################					
						if ((grep {$_ eq $gateList1[0]} @primaryOutputs)) {
							$tempOut = $gateList1[0];
							my $phaseBit = $phase1ForFile{$gateList1[0]};	
							# print "Gate = $gateList1[0], PHASE = $phaseForFile{$gateList1[0]}, PH = $phase\n";
							$currentGate =~ s/\./_/;	
							$tempOut =~ s/v/g/;		
							
							if ($phaseBit eq 1) {
								print OUT $tempOut."_1 = $gateName1[0](";
							}
							elsif ($phaseBit eq 0) {	
								print OUT $tempOut."_02 = $gateName1[0](";
							}							
						}
						else {
							print OUT $gateList1[0]."_1 = $gateName1[0](";
						}						
						
						foreach $l1 (1..scalar @gateList1 - 1) {
							if ($l1==scalar @gateList1 - 1) {
								if (grep {$_ eq $gateList1[$l1]} @primaryInputs) {
									print OUT "$gateList1[$l1])\n";
								}
								else {					
									print OUT "$gateList1[$l1]"."_1)\n";
								}
							}
							else {
								if (grep {$_ eq $gateList1[$l1]} @primaryInputs) {
									print OUT "$gateList1[$l1], ";
								}
								else {					
									print OUT "$gateList1[$l1]"."_1, ";
								}
							}
						}	
						
						$tempOut1 = $tempOut;
						if ($phase1ForFile{$gateList1[0]} eq 0) {	
							print OUT $tempOut."_1 = NOT($tempOut1"."_02)\n";
						}							
						
						#combine the outputs in C-Element.
						if (grep {$_ eq $gateList1[0]} @primaryOutputs) {
							$addr = tell(IN1);
							my $phaseBit = $phase1ForFile{$gateList1[0]};	
							$tempOut = $gateList[$l1];
							$tempOut =~ s/v/g/;							
							
							print OUT "$gateList1[0]  = OR($tempOut"."_0, $tempOut"."_1)\n\n";				
							
							# print OUT "$gateList1[0]"."_02  = OR($tempOut"."_0, $tempOut"."_1)\n";								
							# print OUT "$gateList1[0] = NOT($gateList1[0]"."_02)\n\n";			
							$flag = 1;
						}
						if ($flag==1) {
							last;
						}
					}
					@gateList1 = ();
					@gateName1 = ();	
				}
				close(IN1);				
			}
		}
		@gateList = ();
		@gateName = ();	
	}
	close(IN0);	
	close (OUT);
	#####################################################################

	my $start_time = [Time::HiRes::gettimeofday()];			
	my $run_time = Time::HiRes::tv_interval($start_time);
	print "\tTime taken to create Bench File = $run_time sec.\n";	
	system("dos2unix $fileName"."_CP$threshold.bench");	
	system("rm -rf $benchFile"."0");
	system("rm -rf $benchFile"."1");
	
}
#######################################################

sub convertBenchToDouble {
	
	readPLAFile();
	createPLAWithPhase(-1); #change -1 to synthesize with specific phase value.
	synthesizeUsingSIS(); 
	readBenchFile();
	
	my $outputsCounter = 0;	
	
	print "\n\tCreating final Reliable GG without Guard Gates .bench file ... \n";	
	my $newBenchFile = $fileName."Q.bench";	
	
	my $start_time = [Time::HiRes::gettimeofday()];		
	open (OUTPUT_Bench,  ">$filePath/$newBenchFile") or die $!;	
	
	#-----------------------------------------------
	#Generating the Reliable file.
	#-----------------------------------------------		
	open (INPUT_FILE, $benchFile) or die $!;	
	while (<INPUT_FILE>) {	
		if (/=/) {				
			#-------------------------------------------------
			#Generate the remaining parts of final bench file
			#-------------------------------------------------			
			my @temp = split(" = ", $_);
			push (@gateList, $temp[0]);
			if ($temp[1] =~ m/\((.*)\)/) {			
				push (@gateList, split(", ", $1));
			}
			my @gateName = ($_ =~ m/(\w+)\(/);			
			$currentGate = $gateList[0];			
			my @inputs = split("-", $inputs{$currentGate});					
			
			print OUTPUT_Bench "$currentGate = Q$gateName[0](";			
			for ($ii = 1; $ii < scalar @inputs; $ii++) {				
				if ($ii  == scalar @inputs - 1) {
					print OUTPUT_Bench "$inputs[$ii])\n";	
				}
				else {
					print OUTPUT_Bench "$inputs[$ii], ";	
				}
			}			
			@gateList = ();
			@gateName = ();
		}
		elsif ($_ =~ m/OUTPUT(.*)/) {
			if ($1 =~ m/\((.*)\)/) {
				my $temp = $1;
				$temp =~ s/\./_/;
				print OUTPUT_Bench "OUTPUT($temp)\n";      
			}
		}		
		else {	
			print OUTPUT_Bench $_;    
		}		
	}	
	close(INPUT_FILE);
	#-----------------------------------------------	
	
	close(OUTPUT_Bench);	
	
	my $run_time = Time::HiRes::tv_interval($start_time);
	system("dos2unix $newBenchFile");
	print "\tTime taken to create Bench File = $run_time sec.\n";		
}
#######################################################

sub DMRWithSplitPlaFiles {	

	$phaseIn = $_[0];
	
	print "\tReading $inputFile file ...$phaseIn\n";
	
	my $fileHeader = ();
		
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
			# print "ROW: $row\n"; $cin=getc(STDIN);
			$input{$counter} = @$row[0];
			$output{$counter} = @$row[1];		
			$counter++;			
		}				
	}
	close(FILE);	
	
	#create PLA files.
	@plaFiles = ();
	@benchFiles = ();
	@phaseInfo = ();
	@finalPh = ();

	
	foreach $i (0..$numberOfPrimaryOutputs - 1)  {
		$outFile = $fileName."_$i.pla";
		
		push @plaFiles, $outFile;
		push @benchFiles, $fileName."_$i.bench";
		
		push @phaseInfo, substr($phaseIn, $i, 1);
		
		open (OUT, ">$outFile") or die $!;	
		
		#Write header to the out file.
		print OUT $fileHeader;
		# print OUT ".phase ".substr($phaseIn, $i, 1)."\n";
		
		#write the remaining parts.
		foreach $k (0..$counter - 1)  {
			print OUT $input{$k}." ";
			print OUT substr($output{$k}, $i, 1)."\n";
		}
		print OUT ".e\n";
	}
	
	my $run_time = Time::HiRes::tv_interval($start_time);
	print  "\tTime taken SPLITTING PLA files = $run_time sec.\n";
		
	#####################################################
	#Synthesize each PLA file now,
	#####################################################
	foreach $kk (0..scalar @plaFiles - 1) {
		$inputFile = $plaFiles[$kk];
		$d = "p";
		$ph = $phaseInfo[$kk];
		$fileName = fileparse($inputFile, ".pla");
		$filePath = $cwd;
		$benchFile = $fileName.".bench";
		$outStatsFile = $fileName.".STATS";
		
		$finalPhase = ();
		%phaseForReliableFile = ();
		@primaryOutputs = ();
			
		for (my $k=0; $k < length($ph); $k++) {
			$cb = substr($ph, $k, 1);
			
			if ($cb eq 0) {
				$finalPhase = 1;
			}
			elsif ($cb eq 1) {
				$finalPhase = 0;
			}		
		}
		print "\n================>CIRCUIT = $inputFile\nMAJORITY PHASE = $ph, FINAL PH = $finalPhase\n";	
		push @finalPh, $finalPhase;
		# $cin=getc(STDIN);
		
		readPLAFile();
		print "\n\tCreating PLA with PHASE $finalPhase... \n"; 
		createPLAWithPhase($finalPhase); 
		print "\n\tSynthesizing using SIS ... \n";  
		synthesizeUsingSIS();   						
	}
	
	# print "\nPLA FILES: @plaFiles\n";
	# print "BENCH FILES: @benchFiles\n"; 
	# print "PI: $numberOfPrimaryInputs\n";
	# print "PO: $numberOfPrimaryOutputs\n";	
	
	###############################################
	# Combine the Synthesized bench files
	###############################################
	@primaryInputs = ();
	@primaryOutputs = ();
	%gateRenamedTo = ();
	@allGates = ();
	
	my $newBenchFile = $fName.".bench";	
	my $phh = join("", @finalPh);
	my $phh1 = join("", @phaseInfo);
	open (OUTPUT_BENCH,  ">$newBenchFile") or die $!;	

	print OUTPUT_BENCH "\n";
	foreach $kk(0..$numberOfPrimaryInputs - 1) {
		print OUTPUT_BENCH "INPUT(v$kk)\n";
		$l = "v$kk";
		push @primaryInputs, $l;
	}
	print OUTPUT_BENCH "\n";
	
	foreach $kk(0..scalar @benchFiles - 1) {
		print OUTPUT_BENCH "OUTPUT(v",($numberOfPrimaryInputs),"_$kk)\n";
		$l = "v$numberOfPrimaryInputs"."_$kk";
		push @primaryOutputs, $l;
		$phaseForReliableFile{$l} = substr($phh, $kk, 1);
	}
	print OUTPUT_BENCH "\n";
	
	$startCounter = 1;
	
	foreach $kk (0..scalar @benchFiles - 1) {			
		open (IN, "$benchFiles[$kk]") or die $!;
		
		while (<IN>) {		
			if ($_ =~ m/=/) {
				chomp;
				my @temp = split(" = ", $_);
				
				if ( (grep {$_ eq $temp[0]} @allGates) and !(grep {$_ eq $temp[0]} @primaryOutputs) ) {
					$gateRenamedTo{$temp[0]} = "n$startCounter";
					$startCounter++;
				}
				else {
					push @allGates, $temp[0];
				}
				
				foreach $key (keys %gateRenamedTo) {
					$_ =~ s/$key/$gateRenamedTo{$key}/;
				}
				
				if (grep {$_ eq $temp[0]} @primaryOutputs) {
					$_ =~  s/$temp[0]/$primaryOutputs[$kk]/;
					print OUTPUT_BENCH "$_\n";
					print OUTPUT_BENCH "\n";
					
				}
				else {				
					print OUTPUT_BENCH "$_\n";
				}
			}
		}	
		close (IN);			
	}
	
	close (OUTPUT_BENCH);
	system("dos2unix.exe $newBenchFile");
	
	###################################################
	#Generate the FINAL PROPOSED DMR FILE
	###################################################	
	$benchFile = $fName.".bench";
	my $newBenchFile = $fName."WP.bench";	
	readBenchFile();
	
	# print "@primaryOutputs\n"; 
	
	open (OUTPUT_BENCH,  ">$newBenchFile") or die $!;	
	print OUTPUT_BENCH "# $fName"."WP\n";
	print OUTPUT_BENCH "# $numberOfPrimaryInputs inputs\n";
		
	if ($d eq "p") {
		print OUTPUT_BENCH "# ",scalar @benchFiles," outputs\n";
		print OUTPUT_BENCH "# Synthesized with PHASE $phh (Actual = $phh1)\n";
	}
	else {
		print OUTPUT_BENCH "# ",scalar @benchFiles," outputs\n";
		print OUTPUT_BENCH "# Synthesized without PHASE ($phh1)\n\n";
	}
	
	open (INPUT_FILE, $benchFile) or die $!;	
		while (<INPUT_FILE>) {	
			chomp;		
			if (/=/) {				
				#-------------------------------------------------
				#Generate the remaining parts of final bench file
				#-------------------------------------------------			
				my @temp = split(" = ", $_);
				push (@gateList, $temp[0]);
				if ($temp[1] =~ m/\((.*)\)/) {			
					push (@gateList, split(", ", $1));
				}
				my @gateName = ($_ =~ m/(\w+)\(/);									
				
				$currentGate = $gateList[0];
				my @inputs = split("-", $inputs{$currentGate});						
				
				$dup1 = $currentGate."_1";
				$dup1 =~ s/\./_/;			
				print OUTPUT_BENCH "$dup1 = $gateName[0](";
				for ($ii = 1; $ii < scalar @inputs; $ii++) {
					if (grep $_ eq $inputs[$ii], @primaryInputs) {
						if ($ii  == scalar @inputs - 1) {
							print OUTPUT_BENCH "$inputs[$ii])\n";	
						}
						else {
							print OUTPUT_BENCH "$inputs[$ii], ";	
						}
					}
					else {
						if ($ii  == scalar @inputs -1) {
							if (exists($isDuplicate{$inputs[$ii]})) {
								print OUTPUT_BENCH "$inputs[$ii]"."_1)\n";
							}
							else {							
								print OUTPUT_BENCH "$inputs[$ii])\n";
							}
						}						
						else {
							if (exists($isDuplicate{$inputs[$ii]})) {
								print OUTPUT_BENCH "$inputs[$ii]"."_1, ";
							}
							else {							
								print OUTPUT_BENCH "$inputs[$ii], ";
							}
						}
					}
				}						
				$dup2 = $currentGate."_2";
				$dup2 =~ s/\./_/;
				print OUTPUT_BENCH "$dup2 = $gateName[0](";
				for ($ii = 1; $ii < scalar @inputs; $ii++)
				{
					if (grep $_ eq $inputs[$ii], @primaryInputs) {
						if ($ii  == scalar @inputs -1) {
							print OUTPUT_BENCH "$inputs[$ii])\n";	
						}
						else {
							print OUTPUT_BENCH "$inputs[$ii], ";	
						}
					}
					else
					{
						if ($ii  == scalar @inputs -1) {
							if (exists($isDuplicate{$inputs[$ii]})) {
								print OUTPUT_BENCH "$inputs[$ii]"."_2)\n";
							}
							else {							
								print OUTPUT_BENCH "$inputs[$ii])\n";
							}
						}						
						else {
							if (exists($isDuplicate{$inputs[$ii]})) {
								print OUTPUT_BENCH "$inputs[$ii]"."_2, ";
							}
							else {							
								print OUTPUT_BENCH "$inputs[$ii], ";
							}
						}
					}
				}		
				
				#add the final gate to the duplicate outputs.			
				if ((grep {$_ eq $currentGate} @primaryOutputs)) {						
					my $phaseBit = $phaseForReliableFile{$currentGate};			
					$currentGate =~ s/\./_/;				
					if ($phaseBit eq 0) {
						print OUTPUT_BENCH "$currentGate = NAND($currentGate"."_1, $currentGate"."_2)\n";						
					}
					elsif ($phaseBit eq 1) {
						# print OUTPUT_Bench "$currentGate = AND($currentGate"."_1, $currentGate"."_2)\n";
						print OUTPUT_BENCH "$currentGate"."_3 = NAND($currentGate"."_1, $currentGate"."_2)\n";
						print OUTPUT_BENCH "$currentGate = NOT($currentGate"."_3)\n";
					}	
					$outputsCounter++;								
				}
				
				#add duplicates of current gate in inputs hash table.
				$inputs{$dup1} = $inputs{$currentGate};
				$inputs{$dup2} = $inputs{$currentGate};
				
				$completeGates{$dup1} = $completeGates{$currentGate};
				$completeGates{$dup2} = $completeGates{$currentGate};
					
				#print "Current Gate = $currentGate \n";
				$isDuplicate{$currentGate} = 1;									
				#-------------------------------------------------
				@gateList = ();
				@gateName = ();
			}
			elsif ($_ =~ m/OUTPUT(.*)/) {
				if ($1 =~ m/\((.*)\)/) {
					my $temp = $1;
					$temp =~ s/\./_/; #substitute dot (.) with underscore(_)
					print OUTPUT_BENCH "OUTPUT($temp)\n";      
				}
			}		
			else {	
				$t = "v".($numberOfPrimaryInputs - 1);	
				# print "T = $t, Dollar = $_"; $cin = getc(STDIN);
				if ($_ =~ /$t/) {
					print OUTPUT_BENCH "INPUT($t)\n";    
					print OUTPUT_BENCH "INPUT(errCntrl1)\n";
				}			
				else {
					print OUTPUT_BENCH "$_\n";    
				}
			}
		}	
		close(INPUT_FILE);
		#-----------------------------------------------	
		
		close(OUTPUT_BENCH);	
		
		my $run_time = Time::HiRes::tv_interval($start_time);
		print "\tTime taken to create Bench File = $run_time sec.\n";	
		system("dos2unix $newBenchFile");
		
		system("rm -rf *_*.pla");
		system("rm -rf *_*.bench");
	
}
#######################################################

sub DMRWithSplitPlaFiles2 {	

	$phaseIn = $_[0];
	
	print "\tReading $inputFile file ...$phaseIn\n";
	
	my $fileHeader = ();
		
	my %input = ();
	my %output = ();
	my %phaseForReliableFile = ();
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
			# print "ROW: $row\n"; $cin=getc(STDIN);
			$input{$counter} = @$row[0];
			$output{$counter} = @$row[1];		
			$counter++;			
		}				
	}
	close(FILE);	
	
	#create PLA files.
	@plaFiles = ();
	@eqnFiles = ();
	@actualPhase = ();
	@implementedPhase = ();
	
	foreach $i (0..$numberOfPrimaryOutputs - 1)  {
		$outFile = $fileName."_$i.pla";
		
		push @plaFiles, $outFile;
		push @eqnFiles, $fileName."_$i.eqn";
		
		push @actualPhase, substr($phaseIn, $i, 1);
		
		open (OUT, ">$outFile") or die $!;	
		
		#Write header to the out file.
		print OUT $fileHeader;
		# print OUT ".phase ".substr($phaseIn, $i, 1)."\n";
		
		#write the remaining parts.
		foreach $k (0..$counter - 1)  {
			print OUT $input{$k}." ";
			print OUT substr($output{$k}, $i, 1)."\n";
		}
		print OUT ".e\n";
	}
	
	my $run_time = Time::HiRes::tv_interval($start_time);
	print  "\tTime taken SPLITTING PLA files = $run_time sec.\n";
		
	#####################################################
	#FX each PLA file now,
	#####################################################
	foreach $kk (0..scalar @plaFiles - 1) {
		$inputFile = $plaFiles[$kk];
		$d = "p";
		$ph = $actualPhase[$kk];
		$fileName = fileparse($inputFile, ".pla");			
		$outStatsFile = $fileName.".STATS";
		
		$finalPhase = ();					
		for (my $k=0; $k < length($ph); $k++) {
			$cb = substr($ph, $k, 1);
			
			if ($cb eq 0) {
				$finalPhase = 1;
			}
			elsif ($cb eq 1) {
				$finalPhase = 0;
			}		
		}
		print "\n================>CIRCUIT = $inputFile\nMAJORITY PHASE = $ph, FINAL PH = $finalPhase\n";	
		push @implementedPhase, $finalPhase;
		# $cin=getc(STDIN);
		
		readPLAFile();
		
		print "\n\tCreating PLA with PHASE $finalPhase... \n"; 
		createPLAWithPhase($finalPhase); 
		
		print "\n\tConvert into EQUATION FORMAT ... \n";  
		open (OUT, ">synthesize.script") or die $!;
		$file = $fileName."_min.pla";	
		
		print OUT "read_pla $file\n";	
		print OUT "fx\n";	
		print OUT "write_eqn $fileName.eqn\n";
		print OUT "quit\n";	
		close(OUT);
		
		system("sis < synthesize.script");
		system("rm -rf utiltmp");		
	}
	
	# print "\nPLA FILES: @plaFiles\n";
	# print "EQN FILES: @eqnFiles\n"; 
	# print "PI: $numberOfPrimaryInputs\n";
	# print "PO: $numberOfPrimaryOutputs\n";
			
	###############################################
	# Combine the EQUATION files
	###############################################
	@primaryOutputs = ();
	$finalEqnFile = $fName.".eqn";
	open (OUT_EQN, ">$finalEqnFile") or die $!;
	
	print OUT_EQN "INORDER = ";
	foreach $kk (0..$numberOfPrimaryInputs - 1) {
		print OUT_EQN "v$kk ";
	}
	print OUT_EQN ";\n";
	
	print OUT_EQN "OUTORDER = ";
	foreach $kk (0..scalar @eqnFiles - 1) {
		print OUT_EQN "v".($numberOfPrimaryInputs).".$kk ";
		push @primaryOutputs, "v".($numberOfPrimaryInputs).".$kk";
		$phaseForReliableFile{"v".($numberOfPrimaryInputs)."_$kk"} = $implementedPhase[$kk];
	}
	print OUT_EQN ";\n\n";
	
	$tempOut = $primaryOutputs[0];
	$equalCounter = 0;
	
	foreach $kk (0.. scalar @eqnFiles - 1) {
		open (IN_EQN, "$eqnFiles[$kk]") or die $!;
		$st = "[".($kk+1).".";
		while (<IN_EQN>) {
			if ($_ =~ m/=/)  {
				$equalCounter++;
			}
			if ($equalCounter > 2) {
				$_ =~ s/$tempOut/$primaryOutputs[$kk]/;
				$_ =~ s/\[/$st/g;
				print OUT_EQN $_;
			}
		}
		$equalCounter = 0;
		print OUT_EQN "\n";
		close(IN_EQN);	
	}
	
	close (OUT_EQN);
	
	print "PO: @primaryOutputs, FNAME: $fName\n"; 
	# print Dumper \%phaseForReliableFile; 
	# exit;		
	###################################################
	#Generate the FINAL BENCH FILE FROM EQN FILE
	###################################################	
	$finalBenchFile = $fName.".bench";
	print "\n\tConvert Final EQUATION file into BENCH File ... \n";  
	open (OUT, ">synthesize.script") or die $!;
		
	print OUT "read_eqn $finalEqnFile\n";	
	print OUT "read_library tom.mcnc.genlib\n";	
	print OUT "map\n";
	print OUT "write_blif -n $fName.n.blif\n";
	print OUT "quit\n";	
	close(OUT);
	
	system("sis < synthesize.script");
	system("rm -rf utiltmp"); 
	
	################################################
	#Remove line Breaks from Blif File
	################################################
	my $blifFile_IN = $fName.".n.blif";
	my $blifFile_OUT = $fName.".n2.blif";
	
	my $newLineBreak = 0;
	my $temp = ();

	open (OUT_BLIF, ">$blifFile_OUT") or die $!;	
	
	print "Blif File = $blifFile_IN \n";
	open (IN_BLIF, $blifFile_IN) or die $!;	
	while(<IN_BLIF>) {
		if($_ =~ m/\\/) {
			chomp;			
			$_ =~ s/\\//;
			$temp .= $_;
			$newLineBreak = 1;
		}
		elsif(($_ !~ m/\\/) and ($newLineBreak == 1)) {
			chomp;
			print OUT_BLIF "$temp";
			print OUT_BLIF "$_\n";
			$newLineBreak = 0;
			$temp = ();
		}
		else {
			print OUT_BLIF $_;
		}
	}
		
	close(IN_BLIF);
	close(OUT_BLIF);
	
	system("move $fName.n2.blif $fName.n.blif");	
	system("sh script.blif.to.bench $fName");	
	system("rm -rf $fName.n.blif");	
	
	#Convert shared NOT gates to Independent NOT gates.
	system("perl add_not.pl $fName");	
	system("move $fName"."n.bench $fName.bench");
	###############################################
	
	################################################
	#Remove Dots from BENCH File
	################################################
	my $bench_TEMP = $finalBenchFile.".temp";
		
	open (OUT_BENCH, ">$bench_TEMP") or die $!;	
	print OUT_BENCH "\n";

	open (INPUT_FILE, $finalBenchFile) or die $!;		
	while (<INPUT_FILE>) {				
		$_ =~ s/\./_/g;
		print OUT_BENCH $_;		
	}
	close(INPUT_FILE);
	close(OUT_BENCH);
	
	system("move $bench_TEMP $finalBenchFile");
	system("dos2unix $finalBenchFile"); 
	#-------------------------------------------------------------------
	
	###################################################################3	
	#Generate the FINAL DMR FILE
	###################################################################3	
	
	$benchFile = $finalBenchFile;
	readBenchFile();
	
	$DMRBenchFile = $fName."WP.bench";
	open (OUTPUT_BENCH,  ">$DMRBenchFile") or die $!;	
	print OUTPUT_BENCH "# $fName"."WP\n";
	print OUTPUT_BENCH "# $numberOfPrimaryInputs inputs\n";
		
	if ($d eq "p") {
		print OUTPUT_BENCH "# ",scalar @eqnFiles," outputs\n";
		print OUTPUT_BENCH "# Synthesized with PHASE ",join("", @implementedPhase)," (Actual = ",join("", @actualPhase),")\n";
	}
	else {
		print OUTPUT_BENCH "# ",scalar @eqnFiles," outputs\n";
		print OUTPUT_BENCH "# Synthesized without PHASE ($phh1)\n";
	}
	
	open (INPUT_FILE, $benchFile) or die $!;	
		while (<INPUT_FILE>) {	
			chomp;		
			if (/=/) {				
				#-------------------------------------------------
				#Generate the remaining parts of final bench file
				#-------------------------------------------------			
				my @temp = split(" = ", $_);
				push (@gateList, $temp[0]);
				if ($temp[1] =~ m/\((.*)\)/) {			
					push (@gateList, split(", ", $1));
				}
				my @gateName = ($_ =~ m/(\w+)\(/);									
				
				$currentGate = $gateList[0];
				my @inputs = split("-", $inputs{$currentGate});						
				
				$dup1 = $currentGate."_1";
				$dup1 =~ s/\./_/;			
				print OUTPUT_BENCH "$dup1 = $gateName[0](";
				for ($ii = 1; $ii < scalar @inputs; $ii++) {
					if (grep $_ eq $inputs[$ii], @primaryInputs) {
						if ($ii  == scalar @inputs - 1) {
							print OUTPUT_BENCH "$inputs[$ii])\n";	
						}
						else {
							print OUTPUT_BENCH "$inputs[$ii], ";	
						}
					}
					else {
						if ($ii  == scalar @inputs -1) {
							if (exists($isDuplicate{$inputs[$ii]})) {
								print OUTPUT_BENCH "$inputs[$ii]"."_1)\n";
							}
							else {							
								print OUTPUT_BENCH "$inputs[$ii])\n";
							}
						}						
						else {
							if (exists($isDuplicate{$inputs[$ii]})) {
								print OUTPUT_BENCH "$inputs[$ii]"."_1, ";
							}
							else {							
								print OUTPUT_BENCH "$inputs[$ii], ";
							}
						}
					}
				}						
				$dup2 = $currentGate."_2";
				$dup2 =~ s/\./_/;
				print OUTPUT_BENCH "$dup2 = $gateName[0](";
				for ($ii = 1; $ii < scalar @inputs; $ii++)
				{
					if (grep $_ eq $inputs[$ii], @primaryInputs) {
						if ($ii  == scalar @inputs -1) {
							print OUTPUT_BENCH "$inputs[$ii])\n";	
						}
						else {
							print OUTPUT_BENCH "$inputs[$ii], ";	
						}
					}
					else
					{
						if ($ii  == scalar @inputs -1) {
							if (exists($isDuplicate{$inputs[$ii]})) {
								print OUTPUT_BENCH "$inputs[$ii]"."_2)\n";
							}
							else {							
								print OUTPUT_BENCH "$inputs[$ii])\n";
							}
						}						
						else {
							if (exists($isDuplicate{$inputs[$ii]})) {
								print OUTPUT_BENCH "$inputs[$ii]"."_2, ";
							}
							else {							
								print OUTPUT_BENCH "$inputs[$ii], ";
							}
						}
					}
				}		
				
				#add the final gate to the duplicate outputs.		
				if ((grep {$_ eq $currentGate} @primaryOutputs)) {						
					my $phaseBit = $phaseForReliableFile{$currentGate};		
					if ($phaseBit eq 0) {
						print OUTPUT_BENCH "$currentGate = NAND($currentGate"."_1, $currentGate"."_2)\n";						
					}
					elsif ($phaseBit eq 1) {
						print OUTPUT_BENCH "$currentGate"."_3 = NAND($currentGate"."_1, $currentGate"."_2)\n";
						print OUTPUT_BENCH "$currentGate = NOT($currentGate"."_3)\n";
					}	
					$outputsCounter++;								
				}
				
				#add duplicates of current gate in inputs hash table.
				$inputs{$dup1} = $inputs{$currentGate};
				$inputs{$dup2} = $inputs{$currentGate};
				
				$completeGates{$dup1} = $completeGates{$currentGate};
				$completeGates{$dup2} = $completeGates{$currentGate};
					
				#print "Current Gate = $currentGate \n";
				$isDuplicate{$currentGate} = 1;									
				#-------------------------------------------------
				@gateList = ();
				@gateName = ();
			}
			elsif ($_ =~ m/OUTPUT(.*)/) {
				if ($1 =~ m/\((.*)\)/) {
					my $temp = $1;
					print OUTPUT_BENCH "OUTPUT($temp)\n";      
					if ($temp eq $primaryOutputs[$#primaryOutputs]) {
						print OUTPUT_BENCH "\n";
					}					
				}
			}		
			else {	
				$t = "v".($numberOfPrimaryInputs - 1);	
				if ($_ =~ /$t/) {
					print OUTPUT_BENCH "INPUT($t)\n";    
					print OUTPUT_BENCH "INPUT(errCntrl1)\n\n";
				}			
				else {
					print OUTPUT_BENCH "$_\n";    
				}
			}
		}	
		close(INPUT_FILE);
		#-----------------------------------------------	
		
		close(OUTPUT_BENCH);	
		
		my $run_time = Time::HiRes::tv_interval($start_time);
		print "\tTime taken to create FINAL DMR Bench File = $run_time sec.\n";	
		system("dos2unix $DMRBenchFile");
		
		# print Dumper \%phaseForReliableFile;
		# print "@primaryOutputs ";
		
		system("rm -rf *_*.pla");
		system("rm -rf *_*.bench");
		system("rm -rf *.eqn");		
	
}
#######################################################


#-----------------------------------------------
#		Main Program
#-----------------------------------------------

$cwd = getcwd; #get Current Working Directory
$inputFile = $ARGV[0]; #input PLA file.
$d = $ARGV[1]; #to synthesize w.r.t to phase, then $d must be "p".
$ph = $ARGV[2]; #phase value for DMR


#-----------------------------------------------
#		Variables Initialization
#-----------------------------------------------
@primaryOutputs = ();
@primaryInputs = ();
@inter_IO_Gates = ();
%completeGates = ();
%inputs = ();
%input2Output = ();
%isDuplicate = ();
@ORLogicGates = ();
%gateNames = ();

$numberOfPrimaryInputs = 0;
$numberOfPrimaryOutputs = 0;
$sop = 100000;
@probOfZero = ();
@probOfOne = ();
%phase = ();
$totalSops = 0;
$phase = ();
$phaseForReliableFile = ();
#-----------------------------------------------

$fileName = fileparse($inputFile, ".pla");
$fName = $fileName;
$filePath = $cwd;
$benchFile = $fileName.".bench";
$outStatsFile = $fileName.".STATS";


#-----------------------------------------------------
my $start_time = [Time::HiRes::gettimeofday()];

# circuitWithMajPhase(); # This function is used to generate circuits for TASK 1.
# DMRWithSplitPlaFiles2($ph);
DMR_Proposed($ph);
# DMR_WithCustomPhases();
# DMR_WithCElement();
# DMR_WithAlternatingPhases();


my $run_time = Time::HiRes::tv_interval($start_time);

#-------------------------------------------
#	Printing the Probabilities
#-------------------------------------------
open (OUTPUT_FILE, ">$outStatsFile") or die "Cannot open the file for writing";
print OUTPUT_FILE "Outputs\t\tProb. Of 0\t\tProb. of 1\tTotal SOPs = $totalSops\n";
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

print "\n\n\tTotal Time taken = $run_time sec.\n";

# system("del $fileName"."_min.pla");

