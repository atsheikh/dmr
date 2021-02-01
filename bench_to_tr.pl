#! /usr/bin/perl 

###############################################################
#                                                             #
# Description: A perl script to convert from bench format     #
#              to transistor-level verilog format.            #
#                                                             #
#                                                             #
# Author: Aiman H. El-Maleh (KFUPM)                           #
#                                                             #
# Date: July 11, 2006.                                        #
#															  #		
# Updated by: Ahmad Tariq Sheikh (KFUPM)    				  # 	
#															  #		
# Updates: Support for Quadded-transistor logic with  		  #
#		   duplication of gates and Double-transistor 		  #
#		   logic has been added.				  			  #
#															  #		
# Date: September 18, 2013.                                   #
#                                                             #
#                                                             #
###############################################################



#************************************************************************
#                                                                       *
#    Main Program                                                       *
#                                                                       *
#************************************************************************

$start = time;

$circuit=$ARGV[0];
$d=$ARGV[1];

open(IN,"$circuit".".bench") || die " Cannot open input file $circuit".".bench \n";
open(OUT_TEMP,">$circuit".".v") || die " Cannot open input file $circuit".".v \n";
open(OUT,">test".".v") || die " Cannot open input file $circuit".".v \n";
open(OUT2,">test".".temp") || die " Cannot open input file $circuit".".v \n";


$in = 0; #number of inouts
$out = 0; #number of outputs
$ino = 0;	#nuber of inout pins
$tout=0;

$ninv=0;
$nbuff=0;
$nnand=0;
$nand=0;
$nnor=0;
$nor=0;
$dff=0;

$dninv=0;
$dnbuff=0;
$dnnand=0;
$dnand=0;
$dnnor=0;
$dnor=0;
$dgg=0;
$mv=0;

$qninv=0;
$qnbuff=0;
$qnnand=0;
$qnand=0;
$qnnor=0;
$qnor=0;

$maj=0;
$mux=0;
$gg=0;
$qmaj=0;
$qmux=0;
$qgg=0;

@connectionPattern_DNAND = ();
@connectionPattern_DNOR =  ();
@connectionPattern_DOR =  ();
@connectionPattern_DAND = ();
@connectionPattern_DNOT = ();
@connectionPattern_DBUFF = ();

@connectionPattern_QNAND = ();
@connectionPattern_QNOR =  ();
@connectionPattern_QOR =  ();
@connectionPattern_QAND = ();
@connectionPattern_QNOT = ();
@connectionPattern_QMAJ = ();
@connectionPattern_MAJ = ();

print OUT_TEMP "module $circuit (";

while(<IN>){
   
	# Matching Inputs   
	if (/^#/) {
		next;
	}
	
	
	if (/INPUT\((.*)\)/) {          
		$INPUT[$in]=$1;
	    $flag{$INPUT[$in]}=1;
	    $in++;		           
	}

	
	# Matching Outputs
	if (/OUTPUT\((.*)\)/) {
		$TOUT[$tout]=$1;
		$tout++;
	}	    
         
	
	# Matching NOT gates	
    if (/(.*) = NOT\((.*)\)/) {
		
		$i=0;		
		$INV[$i][0]=$1;	#output is stored here
		$INV[$i][1]=$2;	#first input is stored here				
		
		#print "Matched an INV gate  $INV[$ninv][0] = NOT ( $INV[$ninv][1] ) \n"; 
		print OUT2 "N".$INV[$i][0]."\n";
		
		$ninv++;
		if ($d == 1) {
			print OUT "// N".$INV[$i][0]." = NOT( N".$INV[$i][1]." ) \n";
		}

		#  nmos transistors
		print OUT "nmos ( N".$INV[$i][0].", GND, N".$INV[$i][1]." ); \n";				

		#  pmos transistors
		print OUT "pmos ( N".$INV[$i][0].", VDD, N".$INV[$i][1]." ); \n\n";			
	}

	
	# Matching BUFF gates	
    if (/(.*) = BUFF\((.*)\)/) {				
		$i=0;
		$BUFF[$i][0]=$1;	#output is stored here
		$BUFF[$i][1]=$2;	#first input is stored here				
		
		#print "Matched a BUFF gate  $BUFF[$nbuff][0] = BUFF ( $BUFF[$nbuff][1] ) \n"; 		
		print OUT2 "N".$BUFF[$i][0]."\n";
		
		if ($d == 1) {
			print OUT "// N".$BUFF[$i][0]." = BUFF( N".$BUFF[$i][1]." ) \n";
		}

		#  first inverter
		print OUT "nmos ( nb".$nbuff."_1, GND, N".$BUFF[$i][1]." ); \n";
		print OUT "pmos ( nb".$nbuff."_1, VDD, N".$BUFF[$i][1]." ); \n";		
		
		#  second inverter
		print OUT "nmos ( N".$BUFF[$i][0].", GND, nb".$nbuff."_1 ); \n";			
		print OUT "pmos ( N".$BUFF[$i][0].", VDD, nb".$nbuff."_1 ); \n";		
		
		$nbuff++;		
	}

	
	# Matching D Flip-Flops gates	   
	if (/\bDFF\b/i) {	
		
		my @gateList = ($_ =~ m/(\w+)/g);				
		$gateName[0] = $gateList[1];		
		@gateList = ($gateList[0], @gateList[2..$#gateList]);
		
		$i=0;
		$DFF[$i][0] = scalar @gateList - 1; #number of inputs.
		$DFF[$i][1] = $gateList[0]; #output is stored here		
			
		foreach $k (2..scalar @gateList)
		{	$DFF[$i][$k] = $gateList[$k-1];	}			
		
		print OUT2 "N".$DFF[$i][1]."\n";		
		if ($d == 1) {	
		print OUT "\n// N".$DFF[$i][1]." = DFF( ";
			for ($j=0; $j < $DFF[$i][0] ; $j++){
				if ($j == $DFF[$i][0]-1){
					print OUT "N".$DFF[$i][2+$j]." ) \n";
				} else {
					print OUT "N".$DFF[$i][2+$j].", ";
				}
			}
		}
		print OUT "N".$DFF[$i][1]." = DFF( ";
		for ($j=0; $j < $DFF[$i][0] ; $j++){
			if ($j == $DFF[$i][0]-1){
				print OUT "N".$DFF[$i][2+$j]." ) \n";
			} else {
				print OUT "N".$DFF[$i][2+$j].", ";
			}
		}
		$dff++;
	}
		
	
	# Matching NAND gates	
	if (/\bNAND\b/i) {	
		
		my @gateList = ($_ =~ m/(\w+)/g);				
		$gateName[0] = $gateList[1];		
		@gateList = ($gateList[0], @gateList[2..$#gateList]);
		
		$i = 0;
		$NAND[$i][0] = scalar @gateList - 1; #number of inputs.
		$NAND[$i][1] = $gateList[0]; #output is stored here		
			
		foreach $k (2..scalar @gateList)
		{	$NAND[$i][$k] = $gateList[$k-1];	}			
		
		print OUT2 "N".$NAND[$i][1]."\n";
		if ($d == 1) {		
			print OUT "\n// N".$NAND[$i][1]." = NAND( ";
			for ($j=0; $j < $NAND[$i][0] ; $j++){
				if ($j == $NAND[$i][0]-1){
					print OUT "N".$NAND[$i][2+$j]." ) \n";
				} else {
					print OUT "N".$NAND[$i][2+$j].", ";
				}
			}
		}

		# printing the nmos transistors
		$i=0;
		$j=0;
		print OUT "nmos ( N".$NAND[$i][1].", nd".$nnand."_".($j+1).", N".$NAND[$i][$j+2]." ); \n";		
		for ($j=1; $j < $NAND[$i][0]-1 ; $j++){
			print OUT "nmos ( nd".$nnand."_".($j).", nd".$nnand."_".($j+1).", N".$NAND[$i][$j+2]." ); \n";								
		}

		$j = ($NAND[$i][0]-2);
		print OUT "nmos  (   nd".$nnand."_".($j+1)."  , GND , N".$NAND[$i][$j+3]." ); \n";
		if ($d == 1) {
			print OUT "\n";
		}

		# printing the pmos transistors

		for ($k=0; $k < $NAND[$i][0] ; $k++){
			print OUT "pmos  (  N".$NAND[$i][1]." , VDD , N".$NAND[$i][$k+2]." ); \n";					
		}	

		$nnand++;		
    }
       
	
	#Matching AND gates		
	if (/\bAND\b/i) {	
		
		my @gateList = ($_ =~ m/(\w+)/g);				
		$gateName[0] = $gateList[1];		
		@gateList = ($gateList[0], @gateList[2..$#gateList]);
		
		$i=0;
		$AND[$i][0] = scalar @gateList - 1; #number of inputs.
		$AND[$i][1] = $gateList[0]; #output is stored here		
			
		foreach $k (2..scalar @gateList)
		{	$AND[$i][$k] = $gateList[$k-1];	}			
		
		print OUT2 "N".$AND[$i][1]."\n";		
		if ($d == 1) {	
		print OUT "\n// N".$AND[$i][1]." = AND( ";
			for ($j=0; $j < $AND[$i][0] ; $j++){
				if ($j == $AND[$i][0]-1){
					print OUT "N".$AND[$i][2+$j]." ) \n";
				} else {
					print OUT "N".$AND[$i][2+$j].", ";
				}
			}
		}

		# printing the nmos transistors
		$i=0;
		$j=0;
		print OUT "nmos  (  na".$nand."_out , na".$nand."_".($j+1)." , N".$AND[$i][$j+2]." ); \n";
	
		for ($j=1; $j < $AND[$i][0]-1 ; $j++) {
			print OUT "nmos  (   na".$nand."_".($j)." , na".$nand."_".($j+1)." , N".$AND[$i][$j+2]." ); \n";
        }
		$j = ($AND[$i][0]-2);
		print OUT "nmos  (   na".$nand."_".($j+1)."  , GND , N".$AND[$i][$j+3]." ); \n";
			
		if ($d == 1) {
			print OUT "\n";
		}

		# printing the pmos transistors

		for ($k=0; $k < $AND[$i][0] ; $k++) {
			print OUT "pmos  (  na".$nand."_out , VDD , N".$AND[$i][$k+2]." ); \n";		
		
		}

		# Generating the inverter
		print OUT "nmos  (  N".$AND[$i][1]." , GND ,  na".$nand."_out ); \n";
		print OUT "pmos  (  N".$AND[$i][1]." , VDD ,  na".$nand."_out ); \n";
		
		if ($d == 1) {
			print OUT "\n";
		}
		$nand++;
    }
		
	
	#Matching NOR gates		
	if (/\bNOR\b/i) {	
		
		my @gateList = ($_ =~ m/(\w+)/g);				
		$gateName[0] = $gateList[1];		
		@gateList = ($gateList[0], @gateList[2..$#gateList]);
				
		$i=0;
		$NOR[$i][0] = scalar @gateList - 1; #number of inputs.
		$NOR[$i][1] = $gateList[0]; #output is stored here		
			
		foreach $k (2..scalar @gateList)
		{	$NOR[$i][$k] = $gateList[$k-1];	}			                  				
				
		print OUT2 "N".$NOR[$i][1]."\n";
		if ($d == 1) {	
		print OUT "\n// N".$NOR[$i][1]." = NOR( ";
			for ($j=0; $j < $NOR[$i][0] ; $j++){
				if ($j == $NOR[$i][0]-1){
					print OUT "N".$NOR[$i][2+$j]." ) \n";
				} else {
					print OUT "N".$NOR[$i][2+$j].", ";
				}
			}
		}

		# printing the pmos transistors
		$i=0;
		$j=0;
		print OUT "pmos  (  N".$NOR[$i][1]." , nr".$nnor."_".($j+1)." , N".$NOR[$i][$j+2]." ); \n";
	
		for ($j=1; $j < $NOR[$i][0]-1 ; $j++) {
			print OUT "pmos  (   nr".$nnor."_".($j)." , nr".$nnor."_".($j+1)." , N".$NOR[$i][$j+2]." ); \n";
        }
		
		$j = ($NOR[$i][0]-2);	
		print OUT "pmos  (   nr".$nnor."_".($j+1)."  , VDD , N".$NOR[$i][$j+3]." ); \n";
			
		if ($d == 1) {
			print OUT "\n";
		}

		# printing the nmos transistors
		for ($k=0; $k < $NOR[$i][0] ; $k++) {
			print OUT "nmos  (  N".$NOR[$i][1]." , GND , N".$NOR[$i][$k+2]." ); \n";
		}
		$nnor++;
	}
	
	
	#Matching OR gates		
	if (/\bOR\b/i) {	
		
		my @gateList = ($_ =~ m/(\w+)/g);				
		$gateName[0] = $gateList[1];		
		@gateList = ($gateList[0], @gateList[2..$#gateList]);

		$i = 0;
		$OR[$i][0] = scalar @gateList - 1; #number of inputs.
		$OR[$i][1] = $gateList[0]; #output is stored here		
				
		foreach $k (2..scalar @gateList)
		{	$OR[$i][$k] = $gateList[$k-1];	}			                  				
				
		print OUT2 "N".$OR[$i][1]."\n";
		if ($d == 1) {	
		print OUT "\n// N".$OR[$i][1]." = OR( ";
			for ($j=0; $j < $OR[$i][0] ; $j++){
				if ($j == $OR[$i][0]-1){
					print OUT "N".$OR[$i][2+$j]." ) \n";
				} else {
					print OUT "N".$OR[$i][2+$j].", ";
				}
			}
		}

		# printing the pmos transistors
		$i=0;
		$j=0;
		print OUT "pmos  (  no".$nor."_out , no".$nor."_".($j+1)." , N".$OR[$i][$j+2]." ); \n";
		
		for ($j=1; $j < $OR[$i][0]-1 ; $j++) {
			print OUT "pmos  (   no".$nor."_".($j)." , no".$nor."_".($j+1)." , N".$OR[$i][$j+2]." ); \n";
		}
		
		$j = ($OR[$i][0]-2);
		print OUT "pmos  (   no".$nor."_".($j+1)."  , VDD , N".$OR[$i][$j+3]." ); \n";
			
		if ($d == 1) {
			print OUT "\n";
		}

		# printing the nmos transistors
		for ($k=0; $k < $OR[$i][0] ; $k++) {
			print OUT "nmos  (  no".$nor."_out , GND , N".$OR[$i][$k+2]." ); \n";
		
		}

		# Generating the inverter
		print OUT "nmos  (  N".$OR[$i][1]." , GND ,  no".$nor."_out ); \n";
		print OUT "pmos  (  N".$OR[$i][1]." , VDD ,  no".$nor."_out ); \n";		
		
		$nor++;
	}                				
	

	# Matching QNOT gates	
    if (/(.*) = QNOT\((.*)\)/) {
	
		my @gateList = ($_ =~ m/(\w+)/g);				
		$gateName[0] = $gateList[1];		
		@gateList = ($gateList[0], @gateList[2..$#gateList]);
		
		# my @allGates = ($_ =~ m/\((\w.*)\)/ig);  	#Read all Gates including 's' and 'p' keywords							
		#print "Gate List = @gateList  size = ",scalar @gateList,"\n All Gates = @allGates \n Gate Name = $gateName[0]\n";
				
		push (@connectionPattern_QNOT, [ split(m/,\s|,/, $allGates[0]) ]);					
				
		$i=0;
		$QINV[$i][0] = $gateList[0]; #output is stored here						
		$QINV[$i][1] = $gateList[1]; #input is stored here						
				
		my $conpat = shift(@connectionPattern_QNOT);
		print OUT2 "N".$QINV[$i][1]."\n";
		if ($d == 1) {	
			print OUT "// N".$QINV[$i][0]." = QNOT( N".$QINV[$i][1]." ) \n";
		}

		#-----------------------------------------------
		#Find out which input gates should be connected
		#in series and which in parallel.
		#-----------------------------------------------	
		$series = 0;
		$parallel = 0;
		
		@QNOT_nmos = ();
		@QNOT_pmos = ();	
		
		$kk = 2;
		
		$QNOT_nmos[$series]		=   @$conpat[0]; 
		$QNOT_nmos[$series+1]	=  	@$conpat[0]; 
		$QNOT_nmos[$series+2]	=	@$conpat[0]; 
		$QNOT_nmos[$series+3]	=	@$conpat[0]; 		 				
			
		$QNOT_pmos[$parallel]	=   @$conpat[0]; 
		$QNOT_pmos[$parallel+1]	=  	@$conpat[0]; 
		$QNOT_pmos[$parallel+2]	=	@$conpat[0]; 
		$QNOT_pmos[$parallel+3]	=	@$conpat[0]; 		 				
				
		$series += 4;	
		$parallel += 4;				
		
		$i=0;
		$output = $QINV[$i][0];

		#nmos transistors
		$j=0;
		print OUT "nmos  (  N".$output." , niq".$qninv."_1 , N".$QNOT_nmos[$j]." ); \n";
		print OUT "nmos  (  N".$output." , niq".$qninv."_1 , N".$QNOT_nmos[$j+1]." ); \n";
		print OUT "nmos  (   niq".$qninv."_1  , GND , N".$QNOT_nmos[$j+2]." ); \n";
		print OUT "nmos  (   niq".$qninv."_1  , GND , N".$QNOT_nmos[$j+3]." ); \n";
		if ($d == 1) {
			print OUT "\n";
		}

		#pmos transistors
		print OUT "pmos  (  N".$output." , niq".$qninv."_2 , N".$QNOT_pmos[$j]." ); \n";
		print OUT "pmos  (  N".$output." , niq".$qninv."_2 , N".$QNOT_pmos[$j+1]." ); \n";
		print OUT "pmos  (   niq".$qninv."_2  , VDD , N".$QNOT_pmos[$j+2]." ); \n";
		print OUT "pmos  (   niq".$qninv."_2  , VDD , N".$QNOT_pmos[$j+3]." ); \n";
		if ($d == 1) {
			print OUT "\n";
		}
		$qninv++;		
	}
	    

	#Matching QBUFF gates	
    if (/(.*) = QBUFF\((.*)\)/) {
	
		$i=0;		
		$QBUFF[$i][0]=$1;	#output is stored here
		$QBUFF[$i][1]=$2;	#first input is stored here				
		
		#print "Matched a BUFF gate  $VBUFF[$vnbuff][0] = BUFF ( $VBUFF[$vnbuff][1] ) \n"; 
		print OUT2 "N".$QBUFF[$i][0]."\n";		
		if ($d == 1) {
			print OUT "\n// N".$QBUFF[$i][0]." = BUFF( N".$QBUFF[$i][1]." ) \n\n";
		}
		
		#  first inverter
		print OUT "nmos  (   nbq".$qnbuff."_3 , nbq".$qnbuff."_1 , N".$QBUFF[$i][1]." ); \n";
		print OUT "nmos  (   nbq".$qnbuff."_3 , nbq".$qnbuff."_1 , N".$QBUFF[$i][1]." ); \n";
		print OUT "nmos  (   nbq".$qnbuff."_1  , GND , N".$QBUFF[$i][1]." ); \n";
		print OUT "nmos  (   nbq".$qnbuff."_1  , GND , N".$QBUFF[$i][1]." ); \n";
		if ($d == 1) {
			print OUT "\n";
		}

		print OUT "pmos  (   nbq".$qnbuff."_3 , nbq".$qnbuff."_2 , N".$QBUFF[$i][1]." ); \n";
		print OUT "pmos  (   nbq".$qnbuff."_3 , nbq".$qnbuff."_2 , N".$QBUFF[$i][1]." ); \n";
		print OUT "pmos  (   nbq".$qnbuff."_2  , VDD , N".$QBUFF[$i][1]." ); \n";
		print OUT "pmos  (   nbq".$qnbuff."_2  , VDD , N".$QBUFF[$i][1]." ); \n";
		if ($d == 1) {
			print OUT "\n";
		}

		#  second inverter
		print OUT "nmos  (  N".$QBUFF[$i][0]." , nbq".$qnbuff."_4 , nbq".$qnbuff."_3 ); \n";
		print OUT "nmos  (  N".$QBUFF[$i][0]." , nbq".$qnbuff."_4 , nbq".$qnbuff."_3 ); \n";
		print OUT "nmos  (   nbq".$qnbuff."_4  , GND , nbq".$qnbuff."_3 ); \n";
		print OUT "nmos  (   nbq".$qnbuff."_4  , GND , nbq".$qnbuff."_3 ); \n";
		if ($d == 1) {
			print OUT "\n";
		}

		print OUT "pmos  (  N".$QBUFF[$i][0]." , nbq".$qnbuff."_5 , nbq".$qnbuff."_3 ); \n";
		print OUT "pmos  (  N".$QBUFF[$i][0]." , nbq".$qnbuff."_5 , nbq".$qnbuff."_3 ); \n";
		print OUT "pmos  (   nbq".$qnbuff."_5  , VDD , nbq".$qnbuff."_3 ); \n";
		print OUT "pmos  (   nbq".$qnbuff."_5  , VDD , nbq".$qnbuff."_3 ); \n";
		if ($d == 1) {
			print OUT "\n";
		}
		$qnbuff++;
	}

	
	#Matching DBUFF gates	
    if ((/\bDBUFF\b/i)) {
	
		my @gateList = ($_ =~ m/(\w+)/g);				
		$gateName[0] = $gateList[1];		
		@gateList = ($gateList[0], @gateList[2..$#gateList]);
				
		#print "Gate List = @gateList  size = ",scalar @gateList,"\n All Gates = @allGates\n";	

		push (@connectionPattern_DBUFF, [ split(m/,\s|,/, $allGates[0]) ]);					

		$i = 0;
		$DBUFF[$i][0] = $gateList[0]; #output is stored here		
		$DBUFF[$i][1] = $gateList[1]; #input is stored here		
		my $con = shift(@connectionPattern_DBUFF);
		my $conType = @$con[0];
		
		#print "ConType = $conType \n";
		
		print OUT2 "N".$DBUFF[$i][0]."\n";		
		if ($d == 1) {
			print OUT "//$_\n";
		}
		
		$i=0;
		$output = $DBUFF[$i][0];	
		
		if ($conType =~ m/p/i) { #then First inverter is realized as sa0 and the second as sa1
			#First inverter
			$j=0;
			print OUT "nmos  ( N".$output."_1, nbd".$dnbuff."_".($j+1).", N".$DBUFF[$i][1]." ); \n";
			print OUT "nmos  ( nbd".$dnbuff."_".($j+1).", GND, N".$DBUFF[$i][1]." ); \n";			
						
			print OUT "pmos  ( N".$output."_1, VDD, N".$DBUFF[$i][1]." ); \n";
			print OUT "pmos  ( N".$output."_1, VDD, N".$DBUFF[$i][1]." ); \n";		
			if ($d == 1) {
				print OUT "\n";
			}

			#Second inverter
			$j=1;
			print OUT "nmos  ( N".$output.", GND, N".$output."_1 ); \n";
			print OUT "nmos  ( N".$output.", GND, N".$output."_1 ); \n";
			
			print OUT "pmos  ( N".$output.", nbd".$dnbuff."_".($j+1).", N".$output."_1 ); \n";
			print OUT "pmos  ( nbd".$dnbuff."_".($j+1).", VDD, N".$output."_1 ); \n";
			$j += 1;
			if ($d == 1) {
				print OUT "\n";
			}	
		}
		if ($conType =~ m/s/i) { #then First inverter is realized as sa0 and the second as sa1
			#First inverter
			$j=0;
			print OUT "nmos  ( N".$output."_1, GND, N".$DBUFF[$i][1]." ); \n";
			print OUT "nmos  ( N".$output."_1, GND, N".$DBUFF[$i][1]." ); \n";
			
			print OUT "pmos  ( N".$output.", nbd".$dnbuff."_".($j+1).", N".$DBUFF[$i][1]." ); \n";
			print OUT "pmos  ( nbd".$dnbuff."_".($j+1).", VDD, N".$DBUFF[$i][1]." ); \n";
			$j += 1;
			if ($d == 1) {
				print OUT "\n";
			}		

			#Second inverter
			$j=1;
			print OUT "nmos  ( N".$output.", nbd".$dnbuff."_".($j+1).", N".$output."_1 ); \n";
			print OUT "nmos  ( nbd".$dnbuff."_".($j+1).", GND, N".$output."_1 ); \n";			
				
			print OUT "pmos  ( N".$output.", VDD, N".$output."_1 ); \n";
			print OUT "pmos  ( N".$output.", VDD, N".$output."_1 ); \n";		
			if ($d == 1) {
				print OUT "\n";
			}
		}
		$dnbuff++;
	}
	
	
	# Matching DNOT gates	
    if (/\bDNOT\b/i) {	
	
		my @gateList = ($_ =~ m/(\w+)/g);				
		$gateName[0] = $gateList[1];		
		@gateList = ($gateList[0], @gateList[2..$#gateList]);
		
		# my @allGates = ($_ =~ m/\((\w.*)\)/ig);  	#Read all Gates including 's' and 'p' keywords						
		# print "Gate List = @gateList  size = ",scalar @gateList,"\n All Gates = @allGates \n Gate Name = $gateName[0]\n";				
		# push (@connectionPattern_DNOT, [ split(m/,\s|,/, $allGates[0]) ]);					
		
		$i = 0;
		$DINV[$i][0] = $gateList[0]; #output is stored here		
		$DINV[$i][1] = $gateList[1]; #output is stored here									

		my $conpat = shift(@connectionPattern_DNOT);
		
		print OUT2 "N".$DINV[$i][1]."\n";
		if ($d == 1) {	
			print OUT "// N".$DINV[$i][0]." = DNOT(@$conpat[0], N".$DINV[$i][1]." ) \n";
		}	
		
		$i=0;
		$output = $DINV[$i][0];		

		# series case	
		if (@$conpat[0] =~ m/s/i) {
			$j=0;
			print OUT "nmos  ( N".$output.", nid".$dninv."_".($j+1).", N".@$conpat[1]." ); \n";
			print OUT "nmos  ( nid".$dninv."_".($j+1).", GND, N".@$conpat[1]." ); \n";			
			if ($d == 1) {
				print OUT "\n";
			}		
			
			# printing the pmos transistors		
			print OUT "pmos  ( N".$output.", VDD, N".@$conpat[1]." ); \n";
			print OUT "pmos  ( N".$output.", VDD, N".@$conpat[1]." ); \n";		
			if ($d == 1) {
				print OUT "\n";
			}		
		}
		#parallel case
		elsif (@$conpat[0] =~ m/p/i) {
			$j=0;
			print OUT "nmos  ( N".$output.", GND, N".@$conpat[1]." ); \n";
			print OUT "nmos  ( N".$output.", GND, N".@$conpat[1]." ); \n";
			if ($d == 1) {
				print OUT "\n";
			}
			
			# printing the pmos transistors		
			print OUT "pmos  ( N".$output.", nid".$dninv."_".($j+1).", N".@$conpat[1]." ); \n";
			print OUT "pmos  ( nid".$dninv."_".($j+1).", VDD, N".@$conpat[1]." ); \n";
			$j += 1;
			if ($d == 1) {
				print OUT "\n";
			}	
		}	
		$dninv++;		
	}
	
	
	# Matching DNAND gates	
	if (/\bDNAND\b/i) {		
		
		my @gateList = ($_ =~ m/(\w+\d)/g);			#Read All the Gates
		my @gateName = ($_ =~ m/(\w+)\(/i);  		#Read the gate Name i.e. DNAND				
		my @allGates = ($_ =~ m/\((\w.*)\)/ig);  	#Read all Gates including 's' and 'p' keywords			
				
		#print "Gate List = @gateList  size = ",scalar @gateList,"\n All Gates = @allGates \n Gate Name = $gateName[0]\n";
		
		
		push (@connectionPattern_DNAND, [ split(m/,\s|,/, $allGates[0]) ]);		
		
		$i=0;		
		$DNAND[$i][0] = scalar @gateList - 1; #number of inputs.
		$DNAND[$i][1] = $gateList[0]; #output is stored here		
			
		foreach $k (2..scalar @gateList)
		{	$DNAND[$i][$k] = $gateList[$k-1];	}	
		
		#print "Gates = @gateList  GateName = $gateName[0]  @$conpat[0]\n";				
		
		my $conpat = shift(@connectionPattern_DNAND);
		
		print OUT2 "N".$DNAND[$i][1]."\n";
		if ($d == 1) {	
			print OUT "\n// N".$DNAND[$i][1]." = DNAND(@$conpat[0], ";
			for ($j=0; $j < $DNAND[$i][0] ; $j++){
				if ($j == $DNAND[$i][0]-1){
					print OUT "N".$DNAND[$i][2+$j]." ) \n";
				} else {
					print OUT "N".$DNAND[$i][2+$j].", ";
				}
			}
		}					
		
		$i=0;
		$output = $DNAND[$i][1];
		$type = @$conpat[0];
			
		$j=0;
		foreach $kk (1..scalar @$conpat - 1)
		{			
			if (@$conpat[0] =~ m/s/i and $kk == 1) { #insert first transistor.
				print OUT "nmos  ( N".$output.", ndd".$dnnand."_".($j+1).", N".@$conpat[$kk]." ); \n";
				print OUT "nmos  ( ndd".$dnnand."_".($j+1).", ndd".$dnnand."_".($j+2).", N".@$conpat[$kk]." ); \n";
				$j += 2;				
			}
			elsif(@$conpat[0] =~ m/p/i and $kk == 1) { #insert first transistor.					
				print OUT "nmos  ( N".$output.", ndd".$dnnand."_".($j+1).", N".@$conpat[$kk]." ); \n";
				print OUT "nmos  ( N".$output.", ndd".$dnnand."_".($j+1).", N".@$conpat[$kk]." ); \n";
				$j += 1;				
			}
			else {
				# printing the nmos transistors			
				if (@$conpat[0] =~ m/s/i) {
								
					if ($kk == scalar @$conpat - 1) { #if last gate
						print OUT "nmos  ( ndd".$dnnand."_".($j).", ndd".$dnnand."_".($j+1).", N".@$conpat[$kk]." ); \n";
						print OUT "nmos  ( ndd".$dnnand."_".($j+1).", GND, N".@$conpat[$kk]." ); \n";
						$j += 1;						
					}
					else {
						print OUT "nmos  ( ndd".$dnnand."_".($j).", ndd".$dnnand."_".($j+1).", N".@$conpat[$kk]." ); \n";
						print OUT "nmos  ( ndd".$dnnand."_".($j+1).", ndd".$dnnand."_".($j+2).", N".@$conpat[$kk]." ); \n";
						$j += 2;						
					}
				}
				elsif (@$conpat[0] =~ m/p/i) {						
					if ($kk == scalar @$conpat - 1) { #if last gate
						print OUT "nmos  ( ndd".$dnnand."_".($j).", GND, N".@$conpat[$kk]." ); \n";
						print OUT "nmos  ( ndd".$dnnand."_".($j).", GND, N".@$conpat[$kk]." ); \n";
						$j += 1;						
					}
					else {
						print OUT "nmos  ( ndd".$dnnand."_".($j).", ndd".$dnnand."_".($j+1).", N".@$conpat[$kk]." ); \n";
						print OUT "nmos  ( ndd".$dnnand."_".($j).", ndd".$dnnand."_".($j+1).", N".@$conpat[$kk]." ); \n";
						$j += 1;						
					}				
				}		
			}				
		}	
		if ($d == 1) {
			print OUT "\n";
		}
		# printing the pmos transistors		
		foreach $kk (1..scalar @$conpat - 1) {			
			if (@$conpat[0] =~ m/p/i) {								
					print OUT "pmos  ( N".$output.", ndd".$dnnand."_".($j).", N".@$conpat[$kk]." ); \n";
					print OUT "pmos  ( ndd".$dnnand."_".($j).", VDD, N".@$conpat[$kk]." ); \n";
					$j += 1;					
			}		
			elsif (@$conpat[0] =~ m/s/i) {					
				print OUT "pmos  ( N".$output.", VDD, N".@$conpat[$kk]." ); \n";
				print OUT "pmos  ( N".$output.", VDD, N".@$conpat[$kk]." ); \n";				
			}							
		}
		$dnnand++;	
		print OUT "\n";
	}
	
	
	# Matching DAND gates	
	if (/\bDAND\b/i) {		
		
		my @gateList = ($_ =~ m/(\w+\d)/g);			#Read All the Gates
		my @gateName = ($_ =~ m/(\w+)\(/i);  		#Read the gate Name i.e. DAND				
		my @allGates = ($_ =~ m/\((\w.*)\)/ig);  	#Read all Gates including 's' and 'p' keywords			
			
		#print "Gate List = @gateList  size = ",scalar @gateList,"\n All Gates = @allGates \n Gate Name = $gateName[0]\n";
		#exit;
		
		push (@connectionPattern_DAND, [ split(m/,\s|,/, $allGates[0]) ]);					
		$i=0;
		$DAND[$i][0] = scalar @gateList - 1; #number of inputs.
		$DAND[$i][1] = $gateList[0]; #output is stored here		
			
		foreach $k (2..scalar @gateList)
		{	$DAND[$i][$k] = $gateList[$k-1];	}	
		
		#print "Gates = @gateList  GateName = $gateName[0] \n";		
				
		my $conpat = shift(@connectionPattern_DAND);
		
		print OUT2 "N".$DAND[$i][1]."\n";
		if ($d == 1) {	
			print OUT "\n// N".$DAND[$i][1]." = DAND(@$conpat[0], ";
			for ($j=0; $j < $DAND[$i][0] ; $j++){
				if ($j == $DAND[$i][0]-1){
					print OUT "N".$DAND[$i][2+$j]." ) \n";
				} else {
					print OUT "N".$DAND[$i][2+$j].", ";
				}
			}
		}		
		
		$i=0;
		$output = $DAND[$i][1];
			
		$j=0;
		foreach $kk (1..scalar @$conpat - 1) {			
			if (@$conpat[0] =~ m/s/i and $kk == 1) { #insert first transistor.			
				print OUT "nmos ( nad".$dnand."_out, nad".$dnand."_".($j+1).", N".@$conpat[$kk]." ); \n";
				print OUT "nmos ( nad".$dnand."_out, nad".$dnand."_".($j+1).", N".@$conpat[$kk]." ); \n";			
				$j += 1;							
			}
			elsif(@$conpat[0] =~ m/p/i and $kk == 1) { #insert first transistor.								
				print OUT "nmos ( nad".$dnand."_out, nad".$dnand."_".($j+1).", N".@$conpat[$kk]." ); \n";
				print OUT "nmos ( nad".$dnand."_".($j+1).", nad".$dnand."_".($j+2).", N".@$conpat[$kk]." ); \n";			
				$j += 2;				
			}
			else {
				# printing the nmos transistors			
				if (@$conpat[0] =~ m/s/i) {							
					if ($kk == scalar @$conpat - 1) { #if last gate
						print OUT "nmos  ( nad".$dnand."_".($j).", GND, N".@$conpat[$kk]." ); \n";
						print OUT "nmos  ( nad".$dnand."_".($j).", GND, N".@$conpat[$kk]." ); \n";
						$j += 1;						
					}
					else {
						print OUT "nmos  ( nad".$dnand."_".($j).", nad".$dnand."_".($j+1).", N".@$conpat[$kk]." ); \n";
						print OUT "nmos  ( nad".$dnand."_".($j).", nad".$dnand."_".($j+1).", N".@$conpat[$kk]." ); \n";
						$j += 1;						
					}				
				}
				elsif (@$conpat[0] =~ m/p/i) {				
					if ($kk == scalar @$conpat - 1) { #if last gate
						print OUT "nmos  ( nad".$dnand."_".($j).", nad".$dnand."_".($j+1).", N".@$conpat[$kk]." ); \n";
						print OUT "nmos  ( nad".$dnand."_".($j+1).", GND, N".@$conpat[$kk]." ); \n";
						$j += 1;						
					}
					else {
						print OUT "nmos  ( nad".$dnand."_".($j).", nad".$dnand."_".($j+1).", N".@$conpat[$kk]." ); \n";
						print OUT "nmos  ( nad".$dnand."_".($j+1).", nad".$dnand."_".($j+2).", N".@$conpat[$kk]." ); \n";
						$j += 2;						
					}			
				}		
			}				
		}	
		if ($d == 1) {
			print OUT "\n";
		}
		
		# printing the pmos transistors		
		foreach $kk (1..scalar @$conpat - 1) {			
			if (@$conpat[0] =~ m/p/i) {								
				print OUT "pmos  ( nad".$dnand."_out, VDD, N".@$conpat[$kk]." ); \n";
				print OUT "pmos  ( nad".$dnand."_out, VDD, N".@$conpat[$kk]." ); \n";	
				
			}		
			elsif (@$conpat[0] =~ m/s/i) {					
				print OUT "pmos  ( nad".$dnand."_out, nad".$dnand."_".($j).", N".@$conpat[$kk]." ); \n";
				print OUT "pmos  ( nad".$dnand."_".($j).", VDD, N".@$conpat[$kk]." ); \n";
				$j += 1;				
			}							
		}
		if ($d == 1) {
			print OUT "\n";
		}
		
		# Generating the inverter
		# series case	
		if (@$conpat[0] =~ m/s/i) {		
			print OUT "nmos  ( N".$output.", nad".$dnand."_".($j).", nad".$dnand."_out ); \n";
			print OUT "nmos  ( nad".$dnand."_".($j).", GND,  nad".$dnand."_out ); \n";	
			$j += 1;					
			
			# printing the pmos transistors		
			print OUT "pmos  ( N".$output.", VDD, nad".$dnand."_out ); \n";
			print OUT "pmos  ( N".$output.", VDD, nad".$dnand."_out ); \n";					
		}
		#parallel case
		elsif (@$conpat[0] =~ m/p/i) {		
			print OUT "nmos  ( N".$output.", GND, nad".$dnand."_out ); \n";
			print OUT "nmos  ( N".$output.", GND, nad".$dnand."_out ); \n";
						
			# printing the pmos transistors		
			print OUT "pmos  ( N".$output.", nad".$dnand."_".($j+1).", nad".$dnand."_out ); \n";
			print OUT "pmos  ( nad".$dnand."_".($j+1).", VDD, nad".$dnand."_out ); \n";
			$j += 1;				
		}	
		$dnand++;
		print OUT "\n";
	}
	
	
	# Matching DNOR gates	
	if (/\bDNOR\b/i) {		
		
		my @gateList = ($_ =~ m/(\w+\d)/g);			#Read All the Gates
		my @gateName = ($_ =~ m/(\w+)\(/i);  		#Read the gate Name i.e. DNOR			
		my @allGates = ($_ =~ m/\((\w.*)\)/ig);  	#Read all Gates including 's' and 'p' keywords			
				
		#print "Gate List = @gateList  size = ",scalar @gateList,"\n All Gates = @allGates \n Gate Name = $gateName[0]\n";
				
		push (@connectionPattern_DNOR, [ split(m/,\s|,/, $allGates[0]) ]);					
		$i=0;
		$DNOR[$i][0] = scalar @gateList - 1; #number of inputs.
		$DNOR[$i][1] = $gateList[0]; #output is stored here		
			
		foreach $k (2..scalar @gateList)
		{	$DNOR[$i][$k] = $gateList[$k-1];	}	
		
		#print "Gates = @gateList  GateName = $gateName[0] Conpat = @conpat  Inputs = $DNOR[0][4]\n";						
			
		my $conpat = shift(@connectionPattern_DNOR);
		
		print OUT2 "N".$DNOR[$i][1]."\n";		
		if ($d == 1) {	
			print OUT "\n// N".$DNOR[$i][1]." = DNOR(@$conpat[0], ";
			for ($j=0; $j < $DNOR[$i][0] ; $j++){
				if ($j == $DNOR[$i][0]-1){
					print OUT "N".$DNOR[$i][2+$j]." ) \n";
				} else {
					print OUT "N".$DNOR[$i][2+$j].", ";
				}
			}
		}		
		
		$i=0;
		$output = $DNOR[$i][1];
		
		$j=0;
		# printing the nmos transistors		
		foreach $kk (1..scalar @$conpat - 1)
		{			
			if (@$conpat[0] =~ m/s/i) {								
					print OUT "nmos  ( N".$output.", nrd".$dnnor."_".($j+1).", N".@$conpat[$kk]." ); \n";
					print OUT "nmos  ( nrd".$dnnor."_".($j+1).", GND, N".@$conpat[$kk]." ); \n";
					$j += 1;									
			}		
			elsif (@$conpat[0] =~ m/p/i) {					
				print OUT "nmos  ( N".$output.", GND, N".@$conpat[$kk]." ); \n";
				print OUT "nmos  ( N".$output.", GND, N".@$conpat[$kk]." ); \n";							
			}							
		}	
		
		if ($d == 1) {
			print OUT "\n";
		}
		
		# printing the pmos transistors					
		foreach $kk (1..scalar @$conpat - 1) {			
			if (@$conpat[0] =~ m/p/i and $kk == 1) { #insert first transistor.
				print OUT "pmos  ( N".$output.", nrd".$dnnor."_".($j+1).", N".@$conpat[$kk]." ); \n";
				print OUT "pmos  ( nrd".$dnnor."_".($j+1).", nrd".$dnnor."_".($j+2).", N".@$conpat[$kk]." ); \n";
				$j += 2;				
			}
			elsif(@$conpat[0] =~ m/s/i and $kk == 1) { #insert first transistor.					
				print OUT "pmos  ( N".$output.", nrd".$dnnor."_".($j+1).", N".@$conpat[$kk]." ); \n";
				print OUT "pmos  ( N".$output.", nrd".$dnnor."_".($j+1).", N".@$conpat[$kk]." ); \n";
				$j += 1;				
			}
			else {			
				if (@$conpat[0] =~ m/p/i) {							
					if ($kk == scalar @$conpat - 1) { #if last gate
						print OUT "pmos  ( nrd".$dnnor."_".($j).", nrd".$dnnor."_".($j+1).", N".@$conpat[$kk]." ); \n";
						print OUT "pmos  ( nrd".$dnnor."_".($j+1).", VDD, N".@$conpat[$kk]." ); \n";
						$j += 1;						
					}
					else {
						print OUT "pmos  ( nrd".$dnnor."_".($j).", nrd".$dnnor."_".($j+1).", N".@$conpat[$kk]." ); \n";
						print OUT "pmos  ( nrd".$dnnor."_".($j+1).", nrd".$dnnor."_".($j+2).", N".@$conpat[$kk]." ); \n";
						$j += 2;						
					}
				}
				elsif (@$conpat[0] =~ m/s/i) {							
					if ($kk == scalar @$conpat - 1) { #if last gate
						print OUT "pmos  ( nrd".$dnnor."_".($j).", VDD, N".@$conpat[$kk]." ); \n";
						print OUT "pmos  ( nrd".$dnnor."_".($j).", VDD, N".@$conpat[$kk]." ); \n";
						$j += 1;						
					}
					else {
						print OUT "pmos  ( nrd".$dnnor."_".($j).", nrd".$dnnor."_".($j+1).", N".@$conpat[$kk]." ); \n";
						print OUT "pmos  ( nrd".$dnnor."_".($j).", nrd".$dnnor."_".($j+1).", N".@$conpat[$kk]." ); \n";
						$j += 1;						
					}				
				}		
			}				
		}
		$dnnor++;		
		print OUT "\n";
	}
	
	
	# Matching DOR gates	
	if (/\bDOR\b/i) {		
		
		my @gateList = ($_ =~ m/(\w+\d)/g);			#Read All the Gates
		my @gateName = ($_ =~ m/(\w+)\(/i);  		#Read the gate Name i.e. DOR			
		my @allGates = ($_ =~ m/\((\w.*)\)/ig);  	#Read all Gates including 's' and 'p' keywords			
				
		#print "Gate List = @gateList  size = ",scalar @gateList,"\n All Gates = @allGates \n Gate Name = $gateName[0]\n";
		
		
		push (@connectionPattern_DOR, [ split(m/,\s|,/, $allGates[0]) ]);					
		$i=0;
		$DOR[$i][0] = scalar @gateList - 1; #number of inputs.
		$DOR[$i][1] = $gateList[0]; #output is stored here		
			
		foreach $k (2..scalar @gateList)
		{	$DOR[$i][$k] = $gateList[$k-1];	}	
		
		#print "Gates = @gateList  GateName = $gateName[0] Conpat = @conpat  Inputs = $DOR[0][4]\n";						
				
		my $conpat = shift(@connectionPattern_DOR);
		
		print OUT2 "N".$DOR[$i][1]."\n";
		if ($d == 1) {	
			print OUT "\n// N".$DOR[$i][1]." = DOR(@$conpat[0], ";
			for ($j=0; $j < $DOR[$i][0] ; $j++){
				if ($j == $DOR[$i][0]-1){
					print OUT "N".$DOR[$i][2+$j]." ) \n";
				} else {
					print OUT "N".$DOR[$i][2+$j].", ";
				}
			}
		}				
		
		$i=0;
		$output = $DOR[$i][1];	

		# printing the nmos transistors		
		$j=0;
		foreach $kk (1..scalar @$conpat - 1) {			
			if (@$conpat[0] =~ m/p/i) {								
					print OUT "nmos  ( nod".$dnor."_out, nod".$dnor."_".($j+1).", N".@$conpat[$kk]." ); \n";
					print OUT "nmos  ( nod".$dnor."_".($j+1).", GND, N".@$conpat[$kk]." ); \n";
					$j += 1;					
			}		
			elsif (@$conpat[0] =~ m/s/i) {					
				print OUT "nmos  ( nod".$dnor."_out, GND, N".@$conpat[$kk]." ); \n";
				print OUT "nmos  ( nod".$dnor."_out, GND, N".@$conpat[$kk]." ); \n";																	
			}
		}
		if ($d == 1) {
					print OUT "\n";
		}
		
		# printing the pmos transistors				
		foreach $kk (1..scalar @$conpat - 1) {			
			if (@$conpat[0] =~ m/s/i and $kk == 1) { #insert first transistor.
				print OUT "pmos ( nod".$dnor."_out, nod".$dnor."_".($j+1).", N".@$conpat[$kk]." ); \n";
				print OUT "pmos ( nod".$dnor."_".($j+1).", nod".$dnor."_".($j+2).", N".@$conpat[$kk]." ); \n";
				$j += 2;				
			}
			elsif(@$conpat[0] =~ m/p/i and $kk == 1) { #insert first transistor.					
				print OUT "pmos  ( nod".$dnor."_out, nod".$dnor."_".($j+1).", N".@$conpat[$kk]." ); \n";
				print OUT "pmos  ( nod".$dnor."_out, nod".$dnor."_".($j+1).", N".@$conpat[$kk]." ); \n";
				$j += 1;				
			}
			else {			
				if (@$conpat[0] =~ m/s/i) {							
					if ($kk == scalar @$conpat - 1) { #if last gate
						print OUT "pmos  ( nod".$dnor."_".($j).", nod".$dnor."_".($j+1).", N".@$conpat[$kk]." ); \n";
						print OUT "pmos  ( nod".$dnor."_".($j+1).", VDD, N".@$conpat[$kk]." ); \n";
						$j += 1;						
					}
					else {
						print OUT "pmos  ( nod".$dnor."_".($j).", nod".$dnor."_".($j+1).", N".@$conpat[$kk]." ); \n";
						print OUT "pmos  ( nod".$dnor."_".($j+1).", nod".$dnor."_".($j+2).", N".@$conpat[$kk]." ); \n";
						$j += 2;						
					}
				}
				elsif (@$conpat[0] =~ m/p/i) {			
					
					if ($kk == scalar @$conpat - 1) { #if last gate
						print OUT "pmos  ( nod".$dnor."_".($j).", VDD, N".@$conpat[$kk]." ); \n";
						print OUT "pmos  ( nod".$dnor."_".($j).", VDD, N".@$conpat[$kk]." ); \n";
						$j += 1;						
					}
					else {
						print OUT "pmos  ( nod".$dnor."_".($j).", nod".$dnor."_".($j+1).", N".@$conpat[$kk]." ); \n";
						print OUT "pmos  ( nod".$dnor."_".($j).", nod".$dnor."_".($j+1).", N".@$conpat[$kk]." ); \n";
						$j += 1;						
					}				
				}		
			}				
		}		
		if ($d == 1) {
				print OUT "\n";
		}

		# Generating the inverter
		# series case	
		if (@$conpat[0] =~ m/s/i) {		
			print OUT "nmos  ( N".$output.", nod".$dnor."_".($j+1).", nod".$dnor."_out ); \n";
			print OUT "nmos  ( nod".$dnor."_".($j+1).", GND,  nod".$dnor."_out ); \n";	
			$j += 1;					
			
			# printing the pmos transistors		
			print OUT "pmos  ( N".$output.", VDD, nod".$dnor."_out ); \n";
			print OUT "pmos  ( N".$output.", VDD, nod".$dnor."_out ); \n";							
		}
		#parallel case
		elsif (@$conpat[0] =~ m/p/i) {		
			print OUT "nmos  ( N".$output.", GND, nod".$dnor."_out ); \n";
			print OUT "nmos  ( N".$output.", GND, nod".$dnor."_out ); \n";
			
			
			# printing the pmos transistors		
			print OUT "pmos  ( N".$output.", nod".$dnor."_".($j).", nod".$dnor."_out ); \n";
			print OUT "pmos  ( nod".$dnor."_".($j).", VDD, nod".$dnor."_out ); \n\n";
			$j += 1;				
		}
		$dnor++;		
	}
	
	
	# Matching QNAND gates	
	if (/\bQNAND\b/i) {		
		
		my @gateList = ($_ =~ m/(\w+\d)/g);			#Read All the Gates
		my @gateName = ($_ =~ m/(\w+)\(/i);  		#Read the gate Name i.e. QNAND				
		my @allGates = ($_ =~ m/\((\w.*)\)/ig);  	#Read all Gates including 's' and 'p' keywords			
				
		#print "Gate List = @gateList  size = ",scalar @gateList,"\n All Gates = @allGates \n Gate Name = $gateName[0]\n";
				
		push (@connectionPattern_QNAND, [ split(m/,\s|,/, $allGates[0]) ]);					
		$i=0;
		$QNAND[$i][0] = scalar @gateList - 1; #number of inputs.
		$QNAND[$qi][1] = $gateList[0]; #output is stored here		
			
		foreach $k (2..scalar @gateList)
		{	$QNAND[$i][$k] = $gateList[$k-1];	}	
		
		#print "Gates = @gateList  GateName = $gateName[0] Conpat = @conpat  Inputs = $QNAND[0][4]\n";								
		
		my $conpat = shift(@connectionPattern_QNAND);
		
		print OUT2 "N".$QNAND[$i][1]."\n";
		if ($d == 1) {	
			print OUT "\n// N".$QNAND[$i][1]." = QNAND( ";
			for ($j=0; $j < $QNAND[$i][0] ; $j++){
				if ($j == $QNAND[$i][0]-1){
					print OUT "N".$QNAND[$i][2+$j]." ) \n";
				} else {
					print OUT "N".$QNAND[$i][2+$j].", ";
				}
			}
		}		
			
		#-----------------------------------------------
		#Find out which input gates should be connected
		#in series and which in parallel.
		#-----------------------------------------------	
		$series = 0;
		$parallel = 0;
		
		@QNAND_nmos = ();
		@QNAND_pmos = ();
		
		foreach $kk (0..scalar @$conpat - 1)
		{				
			$QNAND_nmos[$series]	=   @$conpat[$kk]; 
			$QNAND_nmos[$series+1]	=  	@$conpat[$kk]; 
			$QNAND_nmos[$series+2]	=	@$conpat[$kk]; 
			$QNAND_nmos[$series+3]	=	@$conpat[$kk]; 		 				
			
			$QNAND_pmos[$parallel]		=   @$conpat[$kk]; 
			$QNAND_pmos[$parallel+1]	=  	@$conpat[$kk]; 
			$QNAND_pmos[$parallel+2]	=	@$conpat[$kk]; 
			$QNAND_pmos[$parallel+3]	=	@$conpat[$kk]; 		 				
			
			$series += 4;	
			$parallel += 4;				
		}	
		#--------------------------------------------
		#print "@$con";
		#print "Conpat = @$conpat ",scalar @$conpat,"\n";
		#print "QNAND_nmos = @QNAND_nmos  QNAND_pmos = @QNAND_pmos \n";	
		#exit;
		$i=0;
		$output = $QNAND[$i][1];
		
		# printing the nmos transistors
		
		$j=0;
		print OUT "nmos  ( N".$output.", ndq".$qnnand."_".($j+1).", N".$QNAND_nmos[$j]." ); \n";
		print OUT "nmos  ( N".$output.", ndq".$qnnand."_".($j+1).", N".$QNAND_nmos[$j+1]." ); \n";
		print OUT "nmos  ( ndq".$qnnand."_".($j+1).", ndq".$qnnand."_".($j+2).", N".$QNAND_nmos[$j+2]." ); \n";
		print OUT "nmos  ( ndq".$qnnand."_".($j+1).", ndq".$qnnand."_".($j+2).", N".$QNAND_nmos[$j+3]." ); \n";
		if ($d == 1) {
			print OUT "\n";
		}

		$l=1;	
		for ($j=4; $j < scalar @QNAND_nmos - 4 - 1; $j+=4){
			print OUT "nmos  ( ndq".$qnnand."_".($l+1).", ndq".$qnnand."_".($l+2).", N".$QNAND_nmos[$j]." ); \n";
			print OUT "nmos  ( ndq".$qnnand."_".($l+1).", ndq".$qnnand."_".($l+2).", N".$QNAND_nmos[$j+1]." ); \n";
			print OUT "nmos  ( ndq".$qnnand."_".($l+2).", ndq".$qnnand."_".($l+3).", N".$QNAND_nmos[$j+2]." ); \n";
			print OUT "nmos  ( ndq".$qnnand."_".($l+2).", ndq".$qnnand."_".($l+3).", N".$QNAND_nmos[$j+3]." ); \n";
			$l=$l+2;
				if ($d == 1) {
					print OUT "\n";
				}
		}
		
		$j = scalar @QNAND_nmos - 4;				
		#$l = $j<<1;		
		print OUT "nmos  ( ndq".$qnnand."_".($l+1).", ndq".$qnnand."_".($l+2).", N".$QNAND_nmos[$j]." ); \n";
		print OUT "nmos  ( ndq".$qnnand."_".($l+1).", ndq".$qnnand."_".($l+2).", N".$QNAND_nmos[$j+1]." ); \n";
		print OUT "nmos  ( ndq".$qnnand."_".($l+2).", GND, N".$QNAND_nmos[$j+2]." ); \n";
		print OUT "nmos  ( ndq".$qnnand."_".($l+2).", GND, N".$QNAND_nmos[$j+3]." ); \n";	
		if ($d == 1) {
			print OUT "\n";
		}

		# printing the pmos transistors
		$ind = 0;
		for ($k=0; $k < scalar @QNAND_pmos/4; $k++){
			print OUT "pmos  ( N".$output.", ndq".$qnnand."_".($k+$l+3).", N".$QNAND_pmos[$k+$ind]." ); \n";
			print OUT "pmos  ( N".$output.", ndq".$qnnand."_".($k+$l+3).", N".$QNAND_pmos[$k+$ind+1]." );  \n";
			print OUT "pmos  ( ndq".$qnnand."_".($k+$l+3).", VDD , N".$QNAND_pmos[$k+$ind+2]." ); \n";
			print OUT "pmos  ( ndq".$qnnand."_".($k+$l+3).", VDD , N".$QNAND_pmos[$k+$ind+3]." ); \n";		
			$ind +=  3; 
			if ($d == 1) {
				print OUT "\n";
			}
		}			
		$qnnand++;
	}
		
		
	# Matching QAND gates	
	if (/\bQAND\b/i) {		
		
		my @gateList = ($_ =~ m/(\w+\d)/g);			#Read All the Gates
		my @gateName = ($_ =~ m/(\w+)\(/i);  		#Read the gate Name i.e. QAND				
		my @allGates = ($_ =~ m/\((\w.*)\)/ig);  	#Read all Gates including 's' and 'p' keywords				
					
		
		push (@connectionPattern_QAND, [ split(m/,\s|,/, $allGates[0]) ]);			
		$i=0;
		$QAND[$i][0] = scalar @gateList - 1; #number of inputs.
		$QAND[$i][1] = $gateList[0]; #output is stored here		
			
		foreach $k (2..scalar @gateList)
		{	$QAND[$i][$k] = $gateList[$k-1];	}	
		
		#print "Gates = @gateList  GateName = $gateName[0] Conpat = @conpat  Inputs = $VNAND[$vnnand][0]\n";							
		my $conpat = shift(@connectionPattern_QAND);
		
		print OUT2 "N".$QAND[$i][1]."\n";		
		if ($d == 1) {	
			print OUT "\n// N".$QAND[$i][1]." = QAND( ";
			for ($j=0; $j < $QAND[$i][0] ; $j++){
				if ($j == $QAND[$i][0]-1){
					print OUT "N".$QAND[$i][2+$j]." ) \n";
				} else {
					print OUT "N".$QAND[$i][2+$j].", ";
				}
			}
		}
		
		#-----------------------------------------------
		#Find out which input gates should be connected
		#in series and which in parallel.
		#-----------------------------------------------	
		$series = 0;
		$parallel = 0;
		
		@QAND_nmos = ();
		@QAND_pmos = ();
		
		foreach $kk (0..scalar @$conpat - 1)
		{				
			$QAND_nmos[$series]	=   @$conpat[$kk]; 
			$QAND_nmos[$series+1]	=  	@$conpat[$kk]; 
			$QAND_nmos[$series+2]	=	@$conpat[$kk]; 
			$QAND_nmos[$series+3]	=	@$conpat[$kk]; 		 				
				
			$QAND_pmos[$parallel]	=   @$conpat[$kk]; 
			$QAND_pmos[$parallel+1]	=  	@$conpat[$kk]; 
			$QAND_pmos[$parallel+2]	=	@$conpat[$kk]; 
			$QAND_pmos[$parallel+3]	=	@$conpat[$kk]; 		 				
			
			$series += 4;	
			$parallel += 4;				
		}	
		#--------------------------------------------
		#print "@$con";
		# print "Conpat = @$conpat ",scalar @$conpat,"\n";
		#print "QAND_nmos = @QAND_nmos  QAND_pmos = @QAND_pmos \n";	
		#exit;
		$i=0;
		$output = $QAND[$i][1];
		
		# printing the nmos transistors
		
		$j=0;
		print OUT "nmos ( naq".$qnand."_out, naq".$qnand."_".($j+1).", N".$QAND_nmos[$j]." ); \n";
		print OUT "nmos ( naq".$qnand."_out, naq".$qnand."_".($j+1).", N".$QAND_nmos[$j+1]." ); \n";
		print OUT "nmos ( naq".$qnand."_".($j+1).", naq".$qnand."_".($j+2).", N".$QAND_nmos[$j+2]." ); \n";
		print OUT "nmos ( naq".$qnand."_".($j+1).", naq".$qnand."_".($j+2).", N".$QAND_nmos[$j+3]." ); \n";
		if ($d == 1) {
			print OUT "\n";
		}

		$l=1;	
		for ($j=4; $j < scalar @QAND_nmos - 4 - 1; $j+=4){
			print OUT "nmos ( naq".$qnand."_".($l+1).", naq".$qnand."_".($l+2).", N".$QAND_nmos[$j]." ); \n";
			print OUT "nmos ( naq".$qnand."_".($l+1).", naq".$qnand."_".($l+2).", N".$QAND_nmos[$j+1]." ); \n";
			print OUT "nmos ( naq".$qnand."_".($l+2).", naq".$qnand."_".($l+3).", N".$QAND_nmos[$j+2]." ); \n";
			print OUT "nmos ( naq".$qnand."_".($l+2).", naq".$qnand."_".($l+3).", N".$QAND_nmos[$j+3]." ); \n";
			$l=$l+2;
				if ($d == 1) {
					print OUT "\n";
				}
		}
		$j = scalar @QAND_nmos - 4;
		#$l = $j<<1;					
		print OUT "nmos ( naq".$qnand."_".($l+1).", naq".$qnand."_".($l+2).", N".$QAND_nmos[$j]." ); \n";
		print OUT "nmos ( naq".$qnand."_".($l+1).", naq".$qnand."_".($l+2).", N".$QAND_nmos[$j+1]." ); \n";
		print OUT "nmos ( naq".$qnand."_".($l+2).", GND, N".$QAND_nmos[$j+2]." ); \n";
		print OUT "nmos ( naq".$qnand."_".($l+2).", GND, N".$QAND_nmos[$j+3]." ); \n";	
		if ($d == 1) {
			print OUT "\n";
		}

		# printing the pmos transistors
					
		$ind = 0;
		for ($k=0; $k < scalar @QAND_pmos/4; $k++){
			print OUT "pmos ( naq".$qnand."_out, naq".$qnand."_".($k+$l+3).", N".$QAND_pmos[$k+$ind]." ); \n";
			print OUT "pmos ( naq".$qnand."_out, naq".$qnand."_".($k+$l+3).", N".$QAND_pmos[$k+$ind+1]." );  \n";
			print OUT "pmos ( naq".$qnand."_".($k+$l+3).", VDD, N".$QAND_pmos[$k+$ind+2]." ); \n";
			print OUT "pmos ( naq".$qnand."_".($k+$l+3).", VDD, N".$QAND_pmos[$k+$ind+3]." ); \n";
			$ind +=  3;
			if ($d == 1) {
				print OUT "\n";
			}
		}	

		# Generating the inverter
		#print OUT "// Generarting the inverter for QAND \n";
		print OUT "nmos ( N".$output.", naq".$qnand."_t1,  naq".$qnand."_out ); \n";
		print OUT "nmos ( N".$output.", naq".$qnand."_t1,  naq".$qnand."_out ); \n";
		print OUT "nmos ( naq".$qnand."_t1, GND,  naq".$qnand."_out ); \n";
		print OUT "nmos ( naq".$qnand."_t1, GND,  naq".$qnand."_out ); \n";
		if ($d == 1) {
			print OUT "\n";
		}

		print OUT "pmos ( N".$output.", naq".$qnand."_t2, naq".$qnand."_out ); \n";
		print OUT "pmos ( N".$output.", naq".$qnand."_t2, naq".$qnand."_out ); \n";
		print OUT "pmos ( naq".$qnand."_t2, VDD, naq".$qnand."_out ); \n";
		print OUT "pmos ( naq".$qnand."_t2, VDD, naq".$qnand."_out ); \n";
		if ($d == 1) {
			print OUT "\n";
		}	
		$qnand++;		
	}
	

	# Matching QNOR gates		
	if (/\bQNOR\b/i) {				
		my @gateList = ($_ =~ m/(\w+\d)/g);			#Read All the Gates
		my @gateName = ($_ =~ m/(\w+)\(/i);  		#Read the gate Name i.e. QNAND				
		my @allGates = ($_ =~ m/\((\w.*)\)/ig);  	#Read all Gates including 's' and 'p' keywords		
				
		push (@connectionPattern_QNOR, [ split(m/,\s|,/, $allGates[0]) ]);				
		$i=0;
		$QNOR[$i][0] = scalar @gateList - 1; #number of inputs.
		$QNOR[$i][1] = $gateList[0]; #output is stored here		
			
		foreach $k (2..scalar @gateList)
		{	$QNOR[$i][$k] = $gateList[$k-1];	}	
		
		#print "Gates = @gateList  GateName = $gateName[0] Conpat = @conpat  Inputs = $VNOR[$vnnor][0]\n";		             						
				
		my $conpat = shift(@connectionPattern_QNOR);
		
		print OUT2 "N".$QNOR[$i][1]."\n";
		if ($d == 1) {	
			print OUT "\n// N".$QNOR[$i][1]." = QNOR( ";
			for ($j=0; $j < $QNOR[$i][0] ; $j++){
				if ($j == $QNOR[$i][0]-1){
					print OUT "N".$QNOR[$i][2+$j]." ) \n";
				} else {
					print OUT "N".$QNOR[$i][2+$j].", ";
				}
			}
		}
			
		#-----------------------------------------------
		#Find out which input gates should be connected
		#in series and which in parallel.
		#-----------------------------------------------	
		$series = 0;
		$parallel = 0;
		
		@QNOR_nmos = ();
		@QNOR_pmos = ();
		
		foreach $kk (0..scalar @$conpat - 1)
		{
			$QNOR_pmos[$series]		=   @$conpat[$kk]; 
			$QNOR_pmos[$series+1]	=  	@$conpat[$kk]; 
			$QNOR_pmos[$series+2]	=	@$conpat[$kk]; 
			$QNOR_pmos[$series+3]	=	@$conpat[$kk]; 		 				
				
			$QNOR_nmos[$parallel]	=   @$conpat[$kk]; 
			$QNOR_nmos[$parallel+1]	=  	@$conpat[$kk]; 
			$QNOR_nmos[$parallel+2]	=	@$conpat[$kk]; 
			$QNOR_nmos[$parallel+3]	=	@$conpat[$kk]; 		 				
			
			$series += 4;	
			$parallel += 4;				
		}	
		#--------------------------------------------
		#print "@$con";
		#print "Conpat = @$conpat ",scalar @$conpat,"\n";
		#print "QNOR_nmos = @QNOR_nmos  QNOR_pmos = @QNOR_pmos \n";	
		#exit;
		$i=0;
		$output = $QNOR[$i][1];
		
		# printing the pmos transistors	
		$j=0;
		print OUT "pmos ( N".$output.", nrq".$qnnor."_".($j+1).", N".$QNOR_pmos[$j]." ); \n";
		print OUT "pmos ( N".$output.", nrq".$qnnor."_".($j+1).", N".$QNOR_pmos[$j+1]." ); \n";
		print OUT "pmos ( nrq".$qnnor."_".($j+1).", nrq".$qnnor."_".($j+2).", N".$QNOR_pmos[$j+2]." ); \n";
		print OUT "pmos ( nrq".$qnnor."_".($j+1).", nrq".$qnnor."_".($j+2).", N".$QNOR_pmos[$j+3]." ); \n";
		if ($d == 1) {
			print OUT "\n";
		}

		$l=1;	
		for ($j=4; $j < scalar @QNOR_pmos - 4 - 1; $j+=4){
			print OUT "pmos ( nrq".$qnnor."_".($l+1).", nrq".$qnnor."_".($l+2).", N".$QNOR_pmos[$j]." ); \n";
			print OUT "pmos ( nrq".$qnnor."_".($l+1).", nrq".$qnnor."_".($l+2).", N".$QNOR_pmos[$j+1]." ); \n";
			print OUT "pmos ( nrq".$qnnor."_".($l+2).", nrq".$qnnor."_".($l+3).", N".$QNOR_pmos[$j+2]." ); \n";
			print OUT "pmos ( nrq".$qnnor."_".($l+2).", nrq".$qnnor."_".($l+3).", N".$QNOR_pmos[$j+3]." ); \n";
			$l=$l+2;
				if ($d == 1) {
					print OUT "\n";
				}
		}
		
		$j = scalar @QNOR_pmos - 4;		
		#$l = $j<<1;					
		print OUT "pmos ( nrq".$qnnor."_".($l+1).", nrq".$qnnor."_".($l+2).", N".$QNOR_pmos[$j]." ); \n";
		print OUT "pmos ( nrq".$qnnor."_".($l+1).", nrq".$qnnor."_".($l+2).", N".$QNOR_pmos[$j+1]." ); \n";
		print OUT "pmos ( nrq".$qnnor."_".($l+2).", VDD, N".$QNOR_pmos[$j+2]." ); \n";
		print OUT "pmos ( nrq".$qnnor."_".($l+2).", VDD, N".$QNOR_pmos[$j+3]." ); \n";	
		if ($d == 1) {
			print OUT "\n";
		}

		# printing the nmos transistors				
		$ind = 0;
		for ($k=0; $k < scalar @QNOR_nmos/4; $k++){
			print OUT "nmos ( N".$output.", nrq".$qnnor."_".($k+$l+3).", N".$QNOR_nmos[$k+$ind]." ); \n";
			print OUT "nmos ( N".$output.", nrq".$qnnor."_".($k+$l+3).", N".$QNOR_nmos[$k+$ind+1]." );  \n";
			print OUT "nmos ( nrq".$qnnor."_".($k+$l+3).", GND, N".$QNOR_nmos[$k+$ind+2]." ); \n";
			print OUT "nmos ( nrq".$qnnor."_".($k+$l+3).", GND, N".$QNOR_nmos[$k+$ind+3]." ); \n";
			$ind += 3;
			if ($d == 1) {
				print OUT "\n";
			}
		}	
		$qnnor++;		
	}        
	
	
	# Matching QOR gates		
	if (/\bQOR\b/i) {				
		my @gateList = ($_ =~ m/(\w+\d)/g);			#Read All the Gates
		my @gateName = ($_ =~ m/(\w+)\(/i);  		#Read the gate Name i.e. QNAND				
		my @allGates = ($_ =~ m/\((\w.*)\)/ig);  	#Read all Gates including 's' and 'p' keywords		
				
		push (@connectionPattern_QOR, [ split(m/,\s|,/, $allGates[0]) ]);					
		$i=0;
		$QOR[$i][0] = scalar @gateList - 1; #number of inputs.
		$QOR[$i][1] = $gateList[0]; #output is stored here		
			
		foreach $k (2..scalar @gateList)
		{	$QOR[$i][$k] = $gateList[$k-1];	}	
		
		#print "Gates = @gateList  GateName = $gateName[0] Conpat = @conpat  Inputs = $VNOR[$vnnor][0]\n";			
		
		my $conpat = shift(@connectionPattern_QOR);
		
		print OUT2 "N".$QOR[$i][1]."\n";
		if ($d == 1) {	
			print OUT "\n// N".$QOR[$i][1]." = QOR( ";
			for ($j=0; $j < $QOR[$i][0] ; $j++){
				if ($j == $QOR[$i][0]-1){
					print OUT "N".$QOR[$i][2+$j]." ) \n";
				} else {
					print OUT "N".$QOR[$i][2+$j].", ";
				}
			}
		}
		#-----------------------------------------------
		#Find out which input gates should be connected
		#in series and which in parallel.
		#-----------------------------------------------	
		$series = 0;
		$parallel = 0;
		
		@QOR_nmos = ();
		@QOR_pmos = ();
		
		foreach $kk (0..scalar @$conpat - 1)
		{				
			$QOR_pmos[$series]		=   @$conpat[$kk]; 
			$QOR_pmos[$series+1]	=  	@$conpat[$kk]; 
			$QOR_pmos[$series+2]	=	@$conpat[$kk]; 
			$QOR_pmos[$series+3]	=	@$conpat[$kk]; 		 				
				
			$QOR_nmos[$parallel]	=   @$conpat[$kk]; 
			$QOR_nmos[$parallel+1]	=  	@$conpat[$kk]; 
			$QOR_nmos[$parallel+2]	=	@$conpat[$kk]; 
			$QOR_nmos[$parallel+3]	=	@$conpat[$kk]; 		 				
			
			$series += 4;	
			$parallel += 4;	
		}	
		#--------------------------------------------
		#print "@$con";
		#print "Conpat = @$conpat ",scalar @$conpat,"\n";
		#print "QOR_nmos = @QOR_nmos  QOR_pmos = @QOR_pmos \n";	
		#exit;
		$i=0;
		$output = $QOR[$i][1];
		
		# printing the pmos transistors	
		$j=0;
		print OUT "pmos ( noq".$qnor."_out, noq".$qnor."_".($j+1).", N".$QOR_pmos[$j]." ); \n";
		print OUT "pmos ( noq".$qnor."_out, noq".$qnor."_".($j+1).", N".$QOR_pmos[$j+1]." ); \n";
		print OUT "pmos ( noq".$qnor."_".($j+1).", noq".$qnor."_".($j+2).", N".$QOR_pmos[$j+2]." ); \n";
		print OUT "pmos ( noq".$qnor."_".($j+1).", noq".$qnor."_".($j+2).", N".$QOR_pmos[$j+3]." ); \n";
		if ($d == 1) {
			print OUT "\n";
		}

		$l=1;	
		for ($j=4; $j < scalar @QOR_pmos - 4 - 1; $j+=4){
			print OUT "pmos ( noq".$qnor."_".($l+1).", noq".$qnor."_".($l+2)." , N".$QOR_pmos[$j]." ); \n";
			print OUT "pmos ( noq".$qnor."_".($l+1).", noq".$qnor."_".($l+2)." , N".$QOR_pmos[$j+1]." ); \n";
			print OUT "pmos ( noq".$qnor."_".($l+2).", noq".$qnor."_".($l+3)." , N".$QOR_pmos[$j+2]." ); \n";
			print OUT "pmos ( noq".$qnor."_".($l+2).", noq".$qnor."_".($l+3)." , N".$QOR_pmos[$j+3]." ); \n";
			$l=$l+2;
				if ($d == 1) {
					print OUT "\n";
				}
		}
		$j = scalar @QOR_pmos - 4;			
		#$l = $j<<1;					
		print OUT "pmos ( noq".$qnor."_".($l+1).", noq".$qnor."_".($l+2)." , N".$QOR_pmos[$j+1]." ); \n";
		print OUT "pmos ( noq".$qnor."_".($l+1).", noq".$qnor."_".($l+2)." , N".$QOR_pmos[$j+1]." ); \n";
		print OUT "pmos ( noq".$qnor."_".($l+2).", VDD, N".$QOR_pmos[$j+2]." ); \n";
		print OUT "pmos ( noq".$qnor."_".($l+2).", VDD, N".$QOR_pmos[$j+2]." ); \n";	
		if ($d == 1) {
			print OUT "\n";
		}

		# printing the nmos transistors		
		$ind = 0;
		for ($k=0; $k < scalar @QOR_nmos/4; $k++){
			print OUT "nmos ( noq".$qnor."_out , noq".$qnor."_".($k+$l+3).", N".$QOR_nmos[$k+$ind]." ); \n";
			print OUT "nmos ( noq".$qnor."_out , noq".$qnor."_".($k+$l+3).", N".$QOR_nmos[$k+$ind+1]." );  \n";
			print OUT "nmos ( noq".$qnor."_".($k+$l+3).", GND, N".$QOR_nmos[$k+$ind+2]." ); \n";
			print OUT "nmos ( noq".$qnor."_".($k+$l+3).", GND, N".$QOR_nmos[$k+$ind+3]." ); \n";
			$ind += 3;
			if ($d == 1) {
				print OUT "\n";
			}
		}	

		# Generating the inverter		
		#print OUT "// Generarting the inverter for QOR \n";
		print OUT "nmos  (  N".$output." , noq".$qnor."_t1 ,  noq".$qnor."_out ); \n";
		print OUT "nmos  (  N".$output." , noq".$qnor."_t1 ,  noq".$qnor."_out ); \n";
		print OUT "nmos  (   noq".$qnor."_t1 , GND ,  noq".$qnor."_out ); \n";
		print OUT "nmos  (   noq".$qnor."_t1 , GND ,  noq".$qnor."_out ); \n";
		if ($d == 1) {
			print OUT "\n";
		}

		print OUT "pmos  (  N".$output." , noq".$qnor."_t2 ,  noq".$qnor."_out ); \n";
		print OUT "pmos  (  N".$output." , noq".$qnor."_t2 ,  noq".$qnor."_out ); \n";
		print OUT "pmos  (   noq".$qnor."_t2 , VDD ,  noq".$qnor."_out ); \n";
		print OUT "pmos  (   noq".$qnor."_t2 , VDD ,  noq".$qnor."_out ); \n";
		if ($d == 1) {
			print OUT "\n";
		}	
		$qnor++; 		
	} 

	
	#Matching MAJORITY VOTER (MAJ) gates		
	if (/\bMAJ\b/i) {	
		my @gateList = ($_ =~ m/(\w+\d)/g);			#Read All the Gates		
		
		$i = 0;
		$MAJ[$i][0] = scalar @gateList - 1; #number of inputs.
		$MAJ[$i][1] = $gateList[0]; #output is stored here		
				
		foreach $k (2..scalar @gateList)
		{	$MAJ[$i][$k] = $gateList[$k-1];	}			                  				
				
		print OUT2 "N".$MAJ[$i][1]."\n";
		if ($d == 1) {	
		print OUT "\n// N".$MAJ[$i][1]." = MAJ( ";
			for ($j=0; $j < $MAJ[$i][0] ; $j++){
				if ($j == $MAJ[$i][0]-1){
					print OUT "N".$MAJ[$i][2+$j]." ) \n";
				} else {
					print OUT "N".$MAJ[$i][2+$j].", ";
				}
			}
		}

		# printing the nmos transistors
		$i=0;
		$j=0;
		print OUT "nmos (maj".$maj."_out, maj".$maj."_".($j+1).", N".$MAJ[$i][$j+2]."); \n";
		print OUT "nmos (maj".$maj."_".($j+1).", GND, N".$MAJ[$i][$j+3]."); \n";
		print OUT "nmos (maj".$maj."_".($j+1).", GND, N".$MAJ[$i][$j+4]."); \n";		
		print OUT "nmos (maj".$maj."_out, maj".$maj."_".($j+2).", N".$MAJ[$i][$j+3]."); \n";
		print OUT "nmos (maj".$maj."_".($j+2).", GND, N".$MAJ[$i][$j+4]."); \n\n";
	
		# printing the pmos transistors		
		print OUT "pmos (maj".$maj."_out, maj".$maj."_".($j+3).", N".$MAJ[$i][$j+3]."); \n";
		print OUT "pmos (maj".$maj."_out, maj".$maj."_".($j+3).", N".$MAJ[$i][$j+4]."); \n";		
		print OUT "pmos (maj".$maj."_".($j+3).", VDD, N".$MAJ[$i][$j+2]."); \n";		
		print OUT "pmos (maj".$maj."_".($j+4).", VDD, N".$MAJ[$i][$j+3]."); \n";
		print OUT "pmos (maj".$maj."_".($j+3).", maj".$maj."_".($j+4).", N".$MAJ[$i][$j+4]."); \n\n";
		
	
		# Generating the inverter
		print OUT "nmos  (N".$MAJ[$i][1].", GND, maj".$maj."_out); \n";
		print OUT "pmos  (N".$MAJ[$i][1].", VDD, maj".$maj."_out); \n";			
		$maj++;
	}                	
	
	
	#Matching QUADDED MAJORITY VOTER (QMAJ) gates		
	if (/\bQMAJ\b/i) {	
		my @gateList = ($_ =~ m/(\w+\d)/g);			#Read All the Gates					
		
		$i = 0;
		$QMAJ[$i][0] = scalar @gateList - 1; #number of inputs.
		$QMAJ[$i][1] = $gateList[0]; #output is stored here		
				
		foreach $k (2..scalar @gateList)
		{	$QMAJ[$i][$k] = $gateList[$k-1];	}			                  				
				
		print OUT2 "N".$QMAJ[$i][1]."\n";
		if ($d == 1) {	
		print OUT "\n// N".$QMAJ[$i][1]." = QMAJ(";
			for ($j=0; $j < $QMAJ[$i][0] ; $j++){
				if ($j == $QMAJ[$i][0]-1){
					print OUT "N".$QMAJ[$i][2+$j].") \n";
				} else {
					print OUT "N".$QMAJ[$i][2+$j].", ";
				}
			}
		}

		###########################################
		# printing the nmos transistors
		###########################################
		$i=0;
		$j=0;
		#QUADDING nf0_1
		print OUT "nmos (qmaj".$qmaj."_out, qmaj".$qmaj."_".($j+1).", N".$QMAJ[$i][$j+2]."); \n";
		print OUT "nmos (qmaj".$qmaj."_out, qmaj".$qmaj."_".($j+1).", N".$QMAJ[$i][$j+2]."); \n";
		print OUT "nmos (qmaj".$qmaj."_".($j+1).", qmaj".$qmaj."_".($j+2).", N".$QMAJ[$i][$j+2]."); \n";
		print OUT "nmos (qmaj".$qmaj."_".($j+1).", qmaj".$qmaj."_".($j+2).", N".$QMAJ[$i][$j+2]."); \n\n";
		
		#QUADDING nf0_2 (in parllel nf0_2 and nf0_3)
		print OUT "nmos (qmaj".$qmaj."_".($j+2).", qmaj".$qmaj."_".($j+3).", N".$QMAJ[$i][$j+3]."); \n";
		print OUT "nmos (qmaj".$qmaj."_".($j+2).", qmaj".$qmaj."_".($j+3).", N".$QMAJ[$i][$j+3]."); \n";
		print OUT "nmos (qmaj".$qmaj."_".($j+3).", GND, N".$QMAJ[$i][$j+3]."); \n";
		print OUT "nmos (qmaj".$qmaj."_".($j+3).", GND, N".$QMAJ[$i][$j+3]."); \n\n";
		
		#QUADDING nf0_3 (in parllel nf0_2 and nf0_3)
		print OUT "nmos (qmaj".$qmaj."_".($j+2).", qmaj".$qmaj."_".($j+4).", N".$QMAJ[$i][$j+4]."); \n";
		print OUT "nmos (qmaj".$qmaj."_".($j+2).", qmaj".$qmaj."_".($j+4).", N".$QMAJ[$i][$j+4]."); \n";
		print OUT "nmos (qmaj".$qmaj."_".($j+4).", GND, N".$QMAJ[$i][$j+4]."); \n";
		print OUT "nmos (qmaj".$qmaj."_".($j+4).", GND, N".$QMAJ[$i][$j+4]."); \n\n";		
			
		#QUADDING nf0_2 (in series nf0_2 and nf0_3)
		print OUT "nmos (qmaj".$qmaj."_out, qmaj".$qmaj."_".($j+5).", N".$QMAJ[$i][$j+3]."); \n";
		print OUT "nmos (qmaj".$qmaj."_out, qmaj".$qmaj."_".($j+5).", N".$QMAJ[$i][$j+3]."); \n";
		print OUT "nmos (qmaj".$qmaj."_".($j+5).", qmaj".$qmaj."_".($j+6).", N".$QMAJ[$i][$j+3]."); \n";
		print OUT "nmos (qmaj".$qmaj."_".($j+5).", qmaj".$qmaj."_".($j+6).", N".$QMAJ[$i][$j+3]."); \n\n";
		
		#QUADDING nf0_3 (in series nf0_2 and nf0_3)
		print OUT "nmos (qmaj".$qmaj."_".($j+6).", qmaj".$qmaj."_".($j+7).", N".$QMAJ[$i][$j+4]."); \n";
		print OUT "nmos (qmaj".$qmaj."_".($j+6).", qmaj".$qmaj."_".($j+7).", N".$QMAJ[$i][$j+4]."); \n";
		print OUT "nmos (qmaj".$qmaj."_".($j+7).", GND, N".$QMAJ[$i][$j+4]."); \n";
		print OUT "nmos (qmaj".$qmaj."_".($j+7).", GND, N".$QMAJ[$i][$j+4]."); \n\n";		
	
		
		###########################################
		# printing the pmos transistors
		###########################################
		print OUT "pmos (qmaj".$qmaj."_out, qmaj".$qmaj."_".($j+8).", N".$QMAJ[$i][$j+3]."); \n";
		print OUT "pmos (qmaj".$qmaj."_out, qmaj".$qmaj."_".($j+8).", N".$QMAJ[$i][$j+3]."); \n";
		print OUT "pmos (qmaj".$qmaj."_".($j+8).", qmaj".$qmaj."_".($j+9).", N".$QMAJ[$i][$j+3]."); \n";
		print OUT "pmos (qmaj".$qmaj."_".($j+8).", qmaj".$qmaj."_".($j+9).", N".$QMAJ[$i][$j+3]."); \n\n";
		
		print OUT "pmos (qmaj".$qmaj."_out, qmaj".$qmaj."_".($j+10).", N".$QMAJ[$i][$j+4]."); \n";
		print OUT "pmos (qmaj".$qmaj."_out, qmaj".$qmaj."_".($j+10).", N".$QMAJ[$i][$j+4]."); \n";
		print OUT "pmos (qmaj".$qmaj."_".($j+10).", qmaj".$qmaj."_".($j+9).", N".$QMAJ[$i][$j+4]."); \n";
		print OUT "pmos (qmaj".$qmaj."_".($j+10).", qmaj".$qmaj."_".($j+9).", N".$QMAJ[$i][$j+4]."); \n\n";
		
		
		print OUT "pmos (qmaj".$qmaj."_".($j+11).", VDD, N".$QMAJ[$i][$j+2]."); \n";		
		print OUT "pmos (qmaj".$qmaj."_".($j+11).", VDD, N".$QMAJ[$i][$j+2]."); \n";		
		print OUT "pmos (qmaj".$qmaj."_".($j+9).", qmaj".$qmaj."_".($j+11).", N".$QMAJ[$i][$j+2]."); \n";		
		print OUT "pmos (qmaj".$qmaj."_".($j+9).", qmaj".$qmaj."_".($j+11).", N".$QMAJ[$i][$j+2]."); \n\n";	
		
		print OUT "pmos (qmaj".$qmaj."_".($j+12).", VDD, N".$QMAJ[$i][$j+3]."); \n";
		print OUT "pmos (qmaj".$qmaj."_".($j+12).", VDD, N".$QMAJ[$i][$j+3]."); \n";
		print OUT "pmos (qmaj".$qmaj."_".($j+13).", qmaj".$qmaj."_".($j+12).", N".$QMAJ[$i][$j+3]."); \n";
		print OUT "pmos (qmaj".$qmaj."_".($j+13).", qmaj".$qmaj."_".($j+12).", N".$QMAJ[$i][$j+3]."); \n\n";		
		
		
		print OUT "pmos (qmaj".$qmaj."_".($j+14).", qmaj".$qmaj."_".($j+13).", N".$QMAJ[$i][$j+4]."); \n";
		print OUT "pmos (qmaj".$qmaj."_".($j+14).", qmaj".$qmaj."_".($j+13).", N".$QMAJ[$i][$j+4]."); \n";
		print OUT "pmos (qmaj".$qmaj."_".($j+9).", qmaj".$qmaj."_".($j+14).", N".$QMAJ[$i][$j+4]."); \n";
		print OUT "pmos (qmaj".$qmaj."_".($j+9).", qmaj".$qmaj."_".($j+14).", N".$QMAJ[$i][$j+4]."); \n\n";
		
	
		# Generating the QUADDED inverter		
		print OUT "nmos (N".$QMAJ[$i][1].", qmaj".$qmaj."_t1".", qmaj".$qmaj."_out); \n";
		print OUT "nmos (N".$QMAJ[$i][1].", qmaj".$qmaj."_t1".", qmaj".$qmaj."_out); \n";
		print OUT "nmos (qmaj".$qmaj."_t1".", GND, qmaj".$qmaj."_out); \n";
		print OUT "nmos (qmaj".$qmaj."_t1".", GND, qmaj".$qmaj."_out); \n";
				
		print OUT "pmos (N".$QMAJ[$i][1].", qmaj".$qmaj."_t2".", qmaj".$qmaj."_out); \n";
		print OUT "pmos (N".$QMAJ[$i][1].", qmaj".$qmaj."_t2".", qmaj".$qmaj."_out); \n";
		print OUT "pmos (qmaj".$qmaj."_t2".", VDD, qmaj".$qmaj."_out); \n";
		print OUT "pmos (qmaj".$qmaj."_t2".", VDD, qmaj".$qmaj."_out); \n\n";
				
		$qmaj++;
	}             

	
	#Matching MUX gates		
	if (/\bMUX\b/i) {	
		my @gateList = ($_ =~ m/(\w+\d)/g);			#Read All the Gates		
		
		$i = 0;
		$MUX[$i][0] = scalar @gateList - 1; #number of inputs.
		$MUX[$i][1] = $gateList[0]; #output is stored here		
				
		foreach $k (2..scalar @gateList)
		{	$MUX[$i][$k] = $gateList[$k-1];	}			                  				
				
		print OUT2 "N".$MUX[$i][1]."\n";
		if ($d == 1) {	
		print OUT "\n// N".$MUX[$i][1]." = MUX( ";
			for ($j=0; $j < $MUX[$i][0] ; $j++){
				if ($j == $MUX[$i][0]-1){
					print OUT "N".$MUX[$i][2+$j]." ) \n";
				} else {
					print OUT "N".$MUX[$i][2+$j].", ";
				}
			}
		}

		# printing the nmos transistors
		$i=0;
		$j=0;
		print OUT "nmos (sbar".$mux."_out, N".$MUX[$i][$j+2].", N".$MUX[$i][1]."); \n";
		print OUT "pmos (sbar".$mux."_out, N".$MUX[$i][$j+2].", sbar".$mux."_out); \n\n";
		
		print OUT "nmos (sbar".$mux."_out, N".$MUX[$i][$j+3].", sbar".$mux."_out); \n";
		print OUT "pmos (sbar".$mux."_out, N".$MUX[$i][$j+3].", N".$MUX[$i][1]."); \n\n";
	
		# Generating the inverter
		# print OUT "nmos  (N".$MUX[$i][1].", GND, sbar".$mux."_out); \n";
		# print OUT "pmos  (N".$MUX[$i][1].", VDD, sbar".$mux."_out); \n";		
		
		# Generating the QUADDED inverter		
		print OUT "nmos (N".$MUX[$i][1].", mux".$mux."_t1".", sbar".$mux."_out); \n";
		print OUT "nmos (N".$MUX[$i][1].", mux".$mux."_t1".", sbar".$mux."_out); \n";
		print OUT "nmos (mux".$mux."_t1".", GND, sbar".$mux."_out); \n";
		print OUT "nmos (mux".$mux."_t1".", GND, sbar".$mux."_out); \n";
				
		print OUT "pmos (N".$MUX[$i][1].", mux".$mux."_t2".", sbar".$mux."_out); \n";
		print OUT "pmos (N".$MUX[$i][1].", mux".$mux."_t2".", sbar".$mux."_out); \n";
		print OUT "pmos (mux".$mux."_t2".", VDD, sbar".$mux."_out); \n";
		print OUT "pmos (mux".$mux."_t2".", VDD, sbar".$mux."_out); \n";		
		$mux++;
	}

	
	#Matching QMUX gates		
	if (/\bQMUX\b/i) {	
		my @gateList = ($_ =~ m/(\w+\d)/g);			#Read All the Gates		
		
		$i = 0;
		$QMUX[$i][0] = scalar @gateList - 1; #number of inputs.
		$QMUX[$i][1] = $gateList[0]; #output is stored here		
				
		foreach $k (2..scalar @gateList)
		{	$QMUX[$i][$k] = $gateList[$k-1];	}			                  				
				
		print OUT2 "N".$QMUX[$i][1]."\n";
		if ($d == 1) {	
		print OUT "\n// N".$QMUX[$i][1]." = QMUX( ";
			for ($j=0; $j < $QMUX[$i][0] ; $j++){
				if ($j == $QMUX[$i][0]-1){
					print OUT "N".$QMUX[$i][2+$j]." ) \n";
				} else {
					print OUT "N".$QMUX[$i][2+$j].", ";
				}
			}
		}

		# printing the nmos transistors
		$i=0;
		$j=0;
		print OUT "nmos (sbar".$qmux."_out, qmux".$qmux."_".($i+1).", N".$QMUX[$i][1]."); \n";
		print OUT "nmos (sbar".$qmux."_out, qmux".$qmux."_".($i+1).", N".$QMUX[$i][1]."); \n";
		print OUT "nmos (qmux".$qmux."_".($i+1).", N".$QMUX[$i][$j+2].", N".$QMUX[$i][1]."); \n";
		print OUT "nmos (qmux".$qmux."_".($i+1).", N".$QMUX[$i][$j+2].", N".$QMUX[$i][1]."); \n\n";
		
		print OUT "pmos (sbar".$qmux."_out, qmux".$qmux."_".($i+2).", sbar".$qmux."_out); \n";
		print OUT "pmos (sbar".$qmux."_out, qmux".$qmux."_".($i+2).", sbar".$qmux."_out); \n";
		print OUT "pmos (qmux".$qmux."_".($i+2).", N".$QMUX[$i][$j+2].", sbar".$qmux."_out); \n";
		print OUT "pmos (qmux".$qmux."_".($i+2).", N".$QMUX[$i][$j+2].", sbar".$qmux."_out); \n\n";
		
		print OUT "nmos (sbar".$qmux."_out, qmux".$qmux."_".($i+3).", sbar".$qmux."_out); \n";
		print OUT "nmos (sbar".$qmux."_out, qmux".$qmux."_".($i+3).", sbar".$qmux."_out); \n"; 
		print OUT "nmos (qmux".$qmux."_".($i+3).", N".$QMUX[$i][$j+3].", sbar".$qmux."_out); \n";
		print OUT "nmos (qmux".$qmux."_".($i+3).", N".$QMUX[$i][$j+3].", sbar".$qmux."_out); \n\n"; 
		
		print OUT "pmos (sbar".$qmux."_out, qmux".$qmux."_".($i+4).", N".$QMUX[$i][1]."); \n";
		print OUT "pmos (sbar".$qmux."_out, qmux".$qmux."_".($i+4).", N".$QMUX[$i][1]."); \n";
		print OUT "pmos (qmux".$qmux."_".($i+4).", N".$QMUX[$i][$j+3].", N".$QMUX[$i][1]."); \n";
		print OUT "pmos (qmux".$qmux."_".($i+4).", N".$QMUX[$i][$j+3].", N".$QMUX[$i][1]."); \n\n";
	
		# Generating the QUADDED inverter		
		print OUT "nmos (N".$QMUX[$i][1].", qmux".$qmux."_t1".", sbar".$qmux."_out); \n";
		print OUT "nmos (N".$QMUX[$i][1].", qmux".$qmux."_t1".", sbar".$qmux."_out); \n";
		print OUT "nmos (qmux".$qmux."_t1".", GND, sbar".$qmux."_out); \n";
		print OUT "nmos (qmux".$qmux."_t1".", GND, sbar".$qmux."_out); \n";
				
		print OUT "pmos (N".$QMUX[$i][1].", qmux".$qmux."_t2".", sbar".$qmux."_out); \n";
		print OUT "pmos (N".$QMUX[$i][1].", qmux".$qmux."_t2".", sbar".$qmux."_out); \n";
		print OUT "pmos (qmux".$qmux."_t2".", VDD, sbar".$qmux."_out); \n";
		print OUT "pmos (qmux".$qmux."_t2".", VDD, sbar".$qmux."_out); \n";		
		$qmux++;
	}

	
	#Matching NORMAL MUX gates		
	if (/\bMUXNORM\b/i) {	
		my @gateList = ($_ =~ m/(\w+\d)/g);			#Read All the Gates		
		
		$i = 0;
		$MUX[$i][0] = scalar @gateList - 1; #number of inputs.
		$MUX[$i][1] = $gateList[0]; #output is stored here		
				
		foreach $k (2..scalar @gateList)
		{	$MUX[$i][$k] = $gateList[$k-1];	}			                  				
				
		print OUT2 "N".$MUX[$i][1]."\n";
		if ($d == 1) {	
		print OUT "\n// N".$MUX[$i][1]." = MUX( ";
			for ($j=0; $j < $MUX[$i][0] ; $j++){
				if ($j == $MUX[$i][0]-1){
					print OUT "N".$MUX[$i][2+$j]." ) \n";
				} else {
					print OUT "N".$MUX[$i][2+$j].", ";
				}
			}
		}

		# printing the nmos transistors
		$i=0;
		$j=0;
		
		#Generating the inverter
		print OUT "nmos  (NBARSEL1, GND, N".$MUX[$i][$j+4]."); \n";
		print OUT "pmos  (NBARSEL1, VDD, N".$MUX[$i][$j+4]."); \n\n";		
		
		print OUT "nmos (N".$MUX[$i][1].", N".$MUX[$i][$j+2].", NBARSEL1); \n";
		print OUT "pmos (N".$MUX[$i][1].", N".$MUX[$i][$j+2].", N".$MUX[$i][$j+4]."); \n\n";
		
		print OUT "nmos (N".$MUX[$i][1].", N".$MUX[$i][$j+3].", N".$MUX[$i][$j+4]."); \n";
		print OUT "pmos (N".$MUX[$i][1].", N".$MUX[$i][$j+3].", NBARSEL1); \n\n";		
		$mux++;
	}
	
	
	#Matching Guard Gates (GG) or C-Element.
	if (/\bGG\b/i) {	
		my @gateList = ($_ =~ m/(\w+\d)/g);			#Read All the Gates		
		
		$i = 0;
		$GG[$i][0] = scalar @gateList - 1; #number of inputs.
		$GG[$i][1] = $gateList[0]; #output is stored here		
				
		foreach $k (2..scalar @gateList)
		{	$GG[$i][$k] = $gateList[$k-1];	}			                  				
				
		print OUT2 "N".$GG[$i][1]."\n";
		if ($d == 1) {	
		print OUT "\n// N".$GG[$i][1]." = GG( ";
			for ($j=0; $j < $GG[$i][0] ; $j++){
				if ($j == $GG[$i][0]-1){
					print OUT "N".$GG[$i][2+$j]." ) \n";
				} else {
					print OUT "N".$GG[$i][2+$j].", ";
				}
			}
		}
		
		print OUT "GG gg".$gg."(N".$GG[$i][1].", ";
		for ($j=0; $j < $GG[$i][0] ; $j++){
			if ($j == $GG[$i][0]-1){
				print OUT "N".$GG[$i][2+$j]." ); \n\n";
			} else {
				print OUT "N".$GG[$i][2+$j].", ";
			}
		}
		$gg++;
		next;

		# printing the nmos transistors
		$i=0;
		$j=0;
		print OUT "nmos (c".$gg."_out, ngg".$gg."_".($j+1).", N".$GG[$i][$j+3]."); \n";
		print OUT "nmos (c".$gg."_out, ngg".$gg."_".($j+2).", N".$GG[$i][$j+2]."); \n";
		print OUT "nmos (ngg".$gg."_".($j+1).", ngg".$gg."_".($j+2).", N".$GG[$i][1]."); \n";		
		print OUT "nmos (ngg".$gg."_".($j+1).", GND, N".$GG[$i][$j+2]."); \n";
		print OUT "nmos (ngg".$gg."_".($j+2).", GND, N".$GG[$i][$j+3]."); \n\n";
		
		
		# printing the pmos transistors
		print OUT "pmos (c".$gg."_out, ngg".$gg."_".($j+3).", N".$GG[$i][$j+3]."); \n";
		print OUT "pmos (c".$gg."_out, ngg".$gg."_".($j+4).", N".$GG[$i][$j+2]."); \n";
		print OUT "pmos (ngg".$gg."_".($j+3).", ngg".$gg."_".($j+4).", N".$GG[$i][1]."); \n";		
		print OUT "pmos (ngg".$gg."_".($j+3).", VDD, N".$GG[$i][$j+2]."); \n";
		print OUT "pmos (ngg".$gg."_".($j+4).", VDD, N".$GG[$i][$j+3]."); \n\n";
				
		# Generating the inverter		
		print OUT "nmos (N".$GG[$i][1].", GND, c".$gg."_out); \n";
		print OUT "pmos (N".$GG[$i][1].", VDD, c".$gg."_out); \n";		
		$gg++;
	}
	

	#Matching Double Guard Gates (GG) or C-Element.
	if (/\bDGG\b/i) {	
		my @gateList = ($_ =~ m/(\w+\d)/g);			#Read All the Gates		
		
		$i = 0;
		$DGG[$i][0] = scalar @gateList - 1; #number of inputs.
		$DGG[$i][1] = $gateList[0]; #output is stored here		
				
		foreach $k (2..scalar @gateList)
		{	$DGG[$i][$k] = $gateList[$k-1];	}			                  				
				
		print OUT2 "N".$DGG[$i][1]."\n";
		if ($d == 1) {	
		print OUT "\n// N".$DGG[$i][1]." = DGG( ";
			for ($j=0; $j < $DGG[$i][0] ; $j++){
				if ($j == $DGG[$i][0]-1){
					print OUT "N".$DGG[$i][2+$j]." ) \n";
				} else {
					print OUT "N".$DGG[$i][2+$j].", ";
				}
			}
		}

		print OUT "N".$GG[$i][1]." = DGG( ";
		for ($j=0; $j < $GG[$i][0] ; $j++){
			if ($j == $GG[$i][0]-1){
				print OUT "N".$GG[$i][2+$j]." ) \n";
			} else {
				print OUT "N".$GG[$i][2+$j].", ";
			}
		}
		$dgg++;
		next;
		
		$i=0;
		$j=0;
		
		# printing the nmos transistors		
		print OUT "nmos (c".$dgg."_out, ndgg".$dgg."_".($j+1).", N".$DGG[$i][$j+3]."); \n";
		print OUT "nmos (c".$dgg."_out, ndgg".$dgg."_".($j+1).", N".$DGG[$i][$j+3]."); \n";
				
		print OUT "nmos (c".$dgg."_out, ndgg".$dgg."_".($j+2).", N".$DGG[$i][$j+2]."); \n";
		print OUT "nmos (c".$dgg."_out, ndgg".$dgg."_".($j+2).", N".$DGG[$i][$j+2]."); \n";		
		
		print OUT "nmos (ndgg".$dgg."_".($j+1).", ndgg".$dgg."_".($j+2).", N".$DGG[$i][1]."); \n";		
		print OUT "nmos (ndgg".$dgg."_".($j+1).", ndgg".$dgg."_".($j+2).", N".$DGG[$i][1]."); \n";				
		
		print OUT "nmos (ndgg".$dgg."_".($j+1).", GND, N".$DGG[$i][$j+2]."); \n";
		print OUT "nmos (ndgg".$dgg."_".($j+1).", GND, N".$DGG[$i][$j+2]."); \n";		
		
		print OUT "nmos (ndgg".$dgg."_".($j+2).", GND, N".$DGG[$i][$j+3]."); \n";
		print OUT "nmos (ndgg".$dgg."_".($j+2).", GND, N".$DGG[$i][$j+3]."); \n\n";		
		
		# printing the pmos transistors
		print OUT "pmos (c".$dgg."_out, ndgg".$dgg."_".($j+3).", N".$DGG[$i][$j+3]."); \n";
		print OUT "pmos (c".$dgg."_out, ndgg".$dgg."_".($j+3).", N".$DGG[$i][$j+3]."); \n";		
		
		print OUT "pmos (c".$dgg."_out, ndgg".$dgg."_".($j+4).", N".$DGG[$i][$j+2]."); \n";
		print OUT "pmos (c".$dgg."_out, ndgg".$dgg."_".($j+4).", N".$DGG[$i][$j+2]."); \n";
				
		print OUT "pmos (ndgg".$dgg."_".($j+3).", ndgg".$dgg."_".($j+4).", N".$DGG[$i][1]."); \n";		
		print OUT "pmos (ndgg".$dgg."_".($j+3).", ndgg".$dgg."_".($j+4).", N".$DGG[$i][1]."); \n";							
		
		print OUT "pmos (ndgg".$dgg."_".($j+3).", VDD, N".$DGG[$i][$j+2]."); \n";
		print OUT "pmos (ndgg".$dgg."_".($j+3).", VDD, N".$DGG[$i][$j+2]."); \n";		
		
		print OUT "pmos (ndgg".$dgg."_".($j+4).", VDD, N".$DGG[$i][$j+3]."); \n";
		print OUT "pmos (ndgg".$dgg."_".($j+4).", VDD, N".$DGG[$i][$j+3]."); \n\n";
				
		# Generating the QUADDED inverter		
		print OUT "nmos (N".$DGG[$i][1].", dgg".$dgg."_t1".", c".$dgg."_out); \n";
		print OUT "nmos (N".$DGG[$i][1].", dgg".$dgg."_t1".", c".$dgg."_out); \n";
		print OUT "nmos (dgg".$dgg."_t1".", GND, c".$dgg."_out); \n";
		print OUT "nmos (dgg".$dgg."_t1".", GND, c".$dgg."_out); \n";
				
		print OUT "pmos (N".$DGG[$i][1].", dgg".$dgg."_t2".", c".$dgg."_out); \n";
		print OUT "pmos (N".$DGG[$i][1].", dgg".$dgg."_t2".", c".$dgg."_out); \n";
		print OUT "pmos (dgg".$dgg."_t2".", VDD, c".$dgg."_out); \n";
		print OUT "pmos (dgg".$dgg."_t2".", VDD, c".$dgg."_out); \n";	
		
		$dgg++;
	}	
	
	
	#Matching Quadded Guard Gates (GG) or C-Element.
	if (/\bQGG\b/i) {	
		my @gateList = ($_ =~ m/(\w+\d)/g);			#Read All the Gates		
		
		$i = 0;
		$QGG[$i][0] = scalar @gateList - 1; #number of inputs.
		$QGG[$i][1] = $gateList[0]; #output is stored here		
				
		foreach $k (2..scalar @gateList)
		{	$QGG[$i][$k] = $gateList[$k-1];	}			                  				
				
		print OUT2 "N".$QGG[$i][1]."\n";
		if ($d == 1) {	
		print OUT "\n// N".$QGG[$i][1]." = QGG( ";
			for ($j=0; $j < $QGG[$i][0] ; $j++){
				if ($j == $QGG[$i][0]-1){
					print OUT "N".$QGG[$i][2+$j]." ) \n";
				} else {
					print OUT "N".$QGG[$i][2+$j].", ";
				}
			}
		}

		print OUT "N".$GG[$i][1]." = QGG( ";
		for ($j=0; $j < $GG[$i][0] ; $j++){
			if ($j == $GG[$i][0]-1){
				print OUT "N".$GG[$i][2+$j]." ) \n";
			} else {
				print OUT "N".$GG[$i][2+$j].", ";
			}
		}
		$qgg++;
		next;
		
		$i=0;
		$j=0;
		
		# printing the nmos transistors		
		print OUT "nmos (c".$qgg."_out, nqgg".$qgg."_".($j+1).", N".$QGG[$i][$j+3]."); \n";
		print OUT "nmos (c".$qgg."_out, nqgg".$qgg."_".($j+1).", N".$QGG[$i][$j+3]."); \n";
		print OUT "nmos (nqgg".$qgg."_".($j+1).", nqgg".$qgg."_".($j+3).", N".$QGG[$i][$j+3]."); \n";
		print OUT "nmos (nqgg".$qgg."_".($j+1).", nqgg".$qgg."_".($j+3).", N".$QGG[$i][$j+3]."); \n\n";
		
		print OUT "nmos (c".$qgg."_out, nqgg".$qgg."_".($j+2).", N".$QGG[$i][$j+2]."); \n";
		print OUT "nmos (c".$qgg."_out, nqgg".$qgg."_".($j+2).", N".$QGG[$i][$j+2]."); \n";
		print OUT "nmos (nqgg".$qgg."_".($j+2).", nqgg".$qgg."_".($j+4).", N".$QGG[$i][$j+2]."); \n";
		print OUT "nmos (nqgg".$qgg."_".($j+2).", nqgg".$qgg."_".($j+4).", N".$QGG[$i][$j+2]."); \n\n";
		
		print OUT "nmos (nqgg".$qgg."_".($j+3).", nqgg".$qgg."_".($j+5).", N".$QGG[$i][1]."); \n";		
		print OUT "nmos (nqgg".$qgg."_".($j+3).", nqgg".$qgg."_".($j+5).", N".$QGG[$i][1]."); \n";		
		print OUT "nmos (nqgg".$qgg."_".($j+5).", nqgg".$qgg."_".($j+4).", N".$QGG[$i][1]."); \n";		
		print OUT "nmos (nqgg".$qgg."_".($j+5).", nqgg".$qgg."_".($j+4).", N".$QGG[$i][1]."); \n\n";		
		
		
		print OUT "nmos (nqgg".$qgg."_".($j+3).", nqgg".$qgg."_".($j+6).", N".$QGG[$i][$j+2]."); \n";
		print OUT "nmos (nqgg".$qgg."_".($j+3).", nqgg".$qgg."_".($j+6).", N".$QGG[$i][$j+2]."); \n";
		print OUT "nmos (nqgg".$qgg."_".($j+6).", GND, N".$QGG[$i][$j+2]."); \n";
		print OUT "nmos (nqgg".$qgg."_".($j+6).", GND, N".$QGG[$i][$j+2]."); \n\n";
		
		print OUT "nmos (nqgg".$qgg."_".($j+4).", nqgg".$qgg."_".($j+7).", N".$QGG[$i][$j+3]."); \n";
		print OUT "nmos (nqgg".$qgg."_".($j+4).", nqgg".$qgg."_".($j+7).", N".$QGG[$i][$j+3]."); \n";
		print OUT "nmos (nqgg".$qgg."_".($j+7).", GND, N".$QGG[$i][$j+3]."); \n";
		print OUT "nmos (nqgg".$qgg."_".($j+7).", GND, N".$QGG[$i][$j+3]."); \n\n";
		
		
		# printing the pmos transistors
		print OUT "pmos (c".$qgg."_out, nqgg".$qgg."_".($j+8).", N".$QGG[$i][$j+3]."); \n";
		print OUT "pmos (c".$qgg."_out, nqgg".$qgg."_".($j+8).", N".$QGG[$i][$j+3]."); \n";
		print OUT "pmos (nqgg".$qgg."_".($j+8).", nqgg".$qgg."_".($j+10).", N".$QGG[$i][$j+3]."); \n";
		print OUT "pmos (nqgg".$qgg."_".($j+8).", nqgg".$qgg."_".($j+10).", N".$QGG[$i][$j+3]."); \n\n";
		
		print OUT "pmos (c".$qgg."_out, nqgg".$qgg."_".($j+9).", N".$QGG[$i][$j+2]."); \n";
		print OUT "pmos (c".$qgg."_out, nqgg".$qgg."_".($j+9).", N".$QGG[$i][$j+2]."); \n";
		print OUT "pmos (nqgg".$qgg."_".($j+9).", nqgg".$qgg."_".($j+11).", N".$QGG[$i][$j+2]."); \n";
		print OUT "pmos (nqgg".$qgg."_".($j+9).", nqgg".$qgg."_".($j+11).", N".$QGG[$i][$j+2]."); \n\n";
		
		print OUT "pmos (nqgg".$qgg."_".($j+10).", nqgg".$qgg."_".($j+12).", N".$QGG[$i][1]."); \n";		
		print OUT "pmos (nqgg".$qgg."_".($j+10).", nqgg".$qgg."_".($j+12).", N".$QGG[$i][1]."); \n";		
		print OUT "pmos (nqgg".$qgg."_".($j+12).", nqgg".$qgg."_".($j+11).", N".$QGG[$i][1]."); \n";		
		print OUT "pmos (nqgg".$qgg."_".($j+12).", nqgg".$qgg."_".($j+11).", N".$QGG[$i][1]."); \n\n";		
		
		
		print OUT "pmos (nqgg".$qgg."_".($j+10).", nqgg".$qgg."_".($j+13).", N".$QGG[$i][$j+2]."); \n";
		print OUT "pmos (nqgg".$qgg."_".($j+10).", nqgg".$qgg."_".($j+13).", N".$QGG[$i][$j+2]."); \n";
		print OUT "pmos (nqgg".$qgg."_".($j+13).", VDD, N".$QGG[$i][$j+2]."); \n";
		print OUT "pmos (nqgg".$qgg."_".($j+13).", VDD, N".$QGG[$i][$j+2]."); \n\n";
		
		print OUT "pmos (nqgg".$qgg."_".($j+11).", nqgg".$qgg."_".($j+14).", N".$QGG[$i][$j+3]."); \n";
		print OUT "pmos (nqgg".$qgg."_".($j+11).", nqgg".$qgg."_".($j+14).", N".$QGG[$i][$j+3]."); \n";
		print OUT "pmos (nqgg".$qgg."_".($j+14).", VDD, N".$QGG[$i][$j+3]."); \n";
		print OUT "pmos (nqgg".$qgg."_".($j+14).", VDD, N".$QGG[$i][$j+3]."); \n\n";
				
		# Generating the QUADDED inverter		
		print OUT "nmos (N".$QGG[$i][1].", qgg".$qgg."_t1".", c".$qgg."_out); \n";
		print OUT "nmos (N".$QGG[$i][1].", qgg".$qgg."_t1".", c".$qgg."_out); \n";
		print OUT "nmos (qgg".$qgg."_t1".", GND, c".$qgg."_out); \n";
		print OUT "nmos (qgg".$qgg."_t1".", GND, c".$qgg."_out); \n";
				
		print OUT "pmos (N".$QGG[$i][1].", qgg".$qgg."_t2".", c".$qgg."_out); \n";
		print OUT "pmos (N".$QGG[$i][1].", qgg".$qgg."_t2".", c".$qgg."_out); \n";
		print OUT "pmos (qgg".$qgg."_t2".", VDD, c".$qgg."_out); \n";
		print OUT "pmos (qgg".$qgg."_t2".", VDD, c".$qgg."_out); \n";	
		
		$qgg++;
	}
	
	#Matching Majority Voter (MV)
	if (/\bMV\b/i) {	
		my @gateList = ($_ =~ m/(\w+\d)/g);			#Read All the Gates		
		
		$i = 0;
		$MV[$i][0] = scalar @gateList - 1; #number of inputs.
		$MV[$i][1] = $gateList[0]; #output is stored here		
				
		foreach $k (2..scalar @gateList)
		{	$MV[$i][$k] = $gateList[$k-1];	}			                  				
				
		print OUT2 "N".$MV[$i][1]."\n";
		if ($d == 1) {	
		print OUT "\n// N".$MV[$i][1]." = MV( ";
			for ($j=0; $j < $MV[$i][0] ; $j++){
				if ($j == $MV[$i][0]-1){
					print OUT "N".$MV[$i][2+$j]." ) \n";
				} else {
					print OUT "N".$MV[$i][2+$j].", ";
				}
			}
		}
		
		print OUT "MV mv".$mv."(N".$MV[$i][1].", ";
		for ($j=0; $j < $MV[$i][0] ; $j++){
			if ($j == $MV[$i][0]-1){
				print OUT "N".$MV[$i][2+$j]." ); \n\n";
			} else {
				print OUT "N".$MV[$i][2+$j].", ";
			}
		}
		$mv++;
	}
	
} #End of File reading.

#computing proper output signals

for ($i=0; $i<$tout; $i++){
        $outn=$TOUT[$i];
	if ($flago{$outn}!=1){
	    	$flago{$outn}=1;
            	$OUTPUT[$out]=$outn;
		if ($flag{$outn}==1){
			$INOUT[$ino]=$outn;
			$ino++;
		}
	    	$out++;		           
	}	
}


# printing module statement

for ($i=0; $i < $in; $i++){
	print OUT_TEMP "N".$INPUT[$i].", ";
}


for ($i=0; $i < $out; $i++){
	if ($flag{$OUTPUT[$i]}==1){
		print OUT_TEMP "NN".$OUTPUT[$i];
	}
	else{
		print OUT_TEMP "N".$OUTPUT[$i];
	}
	if ($i != $out-1) {
           print OUT_TEMP ", ";
        } else {
	   print OUT_TEMP ");\n";
	}
}
print OUT "\n";        

#printint output signals

print OUT_TEMP "\noutput ";
for ($i=0; $i < $out; $i++){
	if ($flag{$OUTPUT[$i]}==1){
		print OUT_TEMP "NN".$OUTPUT[$i];
	}
	else{
		print OUT_TEMP "N".$OUTPUT[$i];
	}
	if ($i != $out-1) {
           print OUT_TEMP ", ";
        } else {
	   print OUT_TEMP ";\n";
	}
}


#printing input signals

print OUT_TEMP "input ";
for ($i=0; $i < $in; $i++){
	print OUT_TEMP "N".$INPUT[$i];
	if ($i != $in-1) {
           print OUT_TEMP ", ";
        } else {
	   print OUT_TEMP ";\n";
	}
}

print OUT_TEMP "\n";
print OUT_TEMP "supply1 VDD;\n";             
print OUT_TEMP "supply0 GND;\n\n";


 
print OUT "\n";
print OUT "endmodule";
        
close(IN);
close(OUT_TEMP);
close(OUT);

open(IN,"test".".v") || die " Cannot open input file $circuit".".v \n";
open(OUT,">>$circuit".".v") || die " Cannot open input file $circuit".".v \n";

while (<IN>) {
	print OUT $_;
}

close(IN);
close(OUT);
close(OUT);

#delete the temporary test file.
system ("del test.v");

$end=time;
$diff = $end - $start;

print "Number of inputs = $in \n";
print "Number of outputs= $out \n";
print "Number of inout pins =$ino \n";
print "Number of INV gates= $ninv \n";
print "Number of BUFF gates= $nbuff \n";
print "Number of NAND gates= $nnand \n";
print "Number of AND gates= $nand \n";
print "Number of NOR gates= $nnor \n";
print "Number of OR gates= $nor \n";
print "Number of MAJ gates= $maj \n";
print "Number of MUX gates= $mux \n";
print "Number of D Flip-Flops= $dff \n";
print "Number of Majority Voter = $mv\n";
print "Number of GG = $gg \n\n";

print "Number of DINV gates= $dninv \n";
print "Number of DBUFF gates= $dnbuff \n";
print "Number of DNAND gates= $dnnand \n";
print "Number of DAND gates= $dnand \n";
print "Number of DNOR gates= $dnnor \n";
print "Number of DOR gates= $dnor \n";
print "Number of DGG gates= $dgg \n\n";


print "Number of QINV gates= $qninv \n";
print "Number of QBUFF gates= $qnbuff \n";
print "Number of QNAND gates= $qnnand \n";
print "Number of QAND gates= $qnand \n";
print "Number of QNOR gates= $qnnor \n";
print "Number of QOR gates= $qnor \n";
print "Number of QMAJ gates= $qmaj \n";
print "Number of QMUX gates= $qmux \n";
print "Number of QGG = $qgg \n\n";
print "Execution time is $diff seconds \n";
