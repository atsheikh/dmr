#! /usr/bin/perl 

###############################################################
#                                                             #
# Description: A perl script to convert from bench format     #
#              to spice.							          #
#                                                             #
#                                                             #
# Updated by: Ahmad Tariq Sheikh (KFUPM)    				  # 	
#															  #		
#															  #		
# Date: September 7, 2014.	                                  #
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
open(OUT,">$circuit".".sp") || die " Cannot open input file $circuit".".v \n";
open(OUT_TEMP,">test".".sp") || die " Cannot open input file $circuit".".v \n";
open(OUT_AREA,">tranarea".".DAT") || die " Cannot open input file $circuit".".v \n";


$in = 0; #number of inouts
$out = 0; #number of outputs
$ino = 0;	#nuber of inout pins
$tout=0;
$tran = 0;
$tempArea=0;

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

$area = 0;

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

#############################################################
#	Scaling Variables										#
#############################################################
$scaling_all_pmos_nand = 2.5;
$scaling_not_2 = 2.8;
$scaling_nand_23 = 4.6;
$scaling_nand_34 = 6.2;
$scaling_nand_45 = 7.5;

$scaling_quad_not = 2.8;
$scaling_quad_nand2 = 4.5;
$scaling_quad_nand3 = 6;
$scaling_quad_nand4 = 7.05;

$scaling_all_nmos_nor = 2.8;
$scaling_nor_23 = 6;
$scaling_nor_34 = 8.5;
$scaling_nor_45 = 11.4;

$scaling_quad_nor2 = 6;
$scaling_quad_nor3 = 8.5;
$scaling_quad_nor4 = 11.2;

$scaling_DGG = 25;
$scaling_DGG2 = 26.5;
#############################################################

#########################################################
#	Basic Dimensions of a transistor					#
#########################################################
$ll = 0.045;
$vdd = 1.0;

$WN = 2*$ll;
$WP = 2*$WN;
#########################################################

$WN1 = $scaling_all_nmos_nor*$WN;
$WP1 = $scaling_all_pmos_nand*$WP;

$WN2 = $scaling_nand_23*$WN;
$WP2 = $scaling_nor_23*$WP;

$WN3 = $scaling_nand_34*$WN;
$WP3 = $scaling_nor_34*$WP;

$WN4 = $scaling_nand_45*$WN;
$WP4 = $scaling_nor_45*$WP;

$WN5 = $scaling_quad_nand2*$WN;
$WP5 = $scaling_quad_nor2*$WP;

$WN6 = $scaling_quad_nand3*$WN;
$WP6 = $scaling_quad_nor3*$WP;

$WN7 = $scaling_quad_nand4*$WN;
$WP7 = $scaling_quad_nor4*$WP;

$WN8 = $scaling_nor_24*$WN;
$WP8 = $scaling_DGG*$WP;
$WP9 = $scaling_DGG2*$WP;

$nmos = "GND NMOS W=WN L=ll"; # AD='2*ll*WN' AS='2*ll*WN' PD='2*(ll+WN)' PS='2*(ll+WN)'";
$pmos = "VDD PMOS W=WP L=ll"; # AD='2*ll*WP' AS='2*ll*WP' PD='2*(ll+WP)' PS='2*(ll+WP)'";

$nmos1 = "GND NMOS W=WN1 L=ll"; # AD='2*ll*WN' AS='2*ll*WN' PD='2*(ll+WN)' PS='2*(ll+WN)'";
$pmos1 = "VDD PMOS W=WP1 L=ll"; # AD='2*ll*WP' AS='2*ll*WP' PD='2*(ll+WP)' PS='2*(ll+WP)'";

$nmos2 = "GND NMOS W=WN2 L=ll"; # AD='2*ll*WN' AS='2*ll*WN' PD='2*(ll+WN)' PS='2*(ll+WN)'";
$pmos2 = "VDD PMOS W=WP2 L=ll"; # AD='2*ll*WP' AS='2*ll*WP' PD='2*(ll+WP)' PS='2*(ll+WP)'";

$nmos3 = "GND NMOS W=WN3 L=ll"; # AD='2*ll*WN' AS='2*ll*WN' PD='2*(ll+WN)' PS='2*(ll+WN)'";
$pmos3 = "VDD PMOS W=WP3 L=ll"; # AD='2*ll*WP' AS='2*ll*WP' PD='2*(ll+WP)' PS='2*(ll+WP)'";

$nmos4 = "GND NMOS W=WN4 L=ll"; # AD='2*ll*WN' AS='2*ll*WN' PD='2*(ll+WN)' PS='2*(ll+WN)'";
$pmos4 = "VDD PMOS W=WP4 L=ll"; # AD='2*ll*WP' AS='2*ll*WP' PD='2*(ll+WP)' PS='2*(ll+WP)'";

$nmos5 = "GND NMOS W=WN5 L=ll"; # AD='2*ll*WN' AS='2*ll*WN' PD='2*(ll+WN)' PS='2*(ll+WN)'";
$pmos5 = "VDD PMOS W=WP5 L=ll"; # AD='2*ll*WP' AS='2*ll*WP' PD='2*(ll+WP)' PS='2*(ll+WP)'";

$nmos6 = "GND NMOS W=WN6 L=ll"; # AD='2*ll*WN' AS='2*ll*WN' PD='2*(ll+WN)' PS='2*(ll+WN)'";
$pmos6 = "VDD PMOS W=WP6 L=ll"; # AD='2*ll*WN' AS='2*ll*WN' PD='2*(ll+WN)' PS='2*(ll+WN)'";

$nmos7 = "GND NMOS W=WN7 L=ll"; # AD='2*ll*WN' AS='2*ll*WN' PD='2*(ll+WN)' PS='2*(ll+WN)'";
$pmos7 = "VDD PMOS W=WP7 L=ll"; # AD='2*ll*WN' AS='2*ll*WN' PD='2*(ll+WN)' PS='2*(ll+WN)'";

$pmos8 = "VDD PMOS W=WP8 L=ll"; # AD='2*ll*WN' AS='2*ll*WN' PD='2*(ll+WN)' PS='2*(ll+WN)'";
$pmos9 = "VDD PMOS W=WP9 L=ll"; # AD='2*ll*WN' AS='2*ll*WN' PD='2*(ll+WN)' PS='2*(ll+WN)'";

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
		
		if ($d == 1) {
			print OUT "\n*N$_";
		}

		#  nmos transistor
		print OUT "M_not".$ninv."_1 N".$INV[$i][0]." N".$INV[$i][1]." GND $nmos\n";
		$tran++;
		$tempArea += $WN;
		print OUT_AREA "$tran $tempArea\n";
		
		#  pmos transistors
		print OUT "M_not".$ninv."_2 N".$INV[$i][0]." N".$INV[$i][1]." VDD $pmos\n\n";
				
		$ninv++;
		$area += $WN + $WP;		
		
		$tran++;
		$tempArea += $WP;
		print OUT_AREA "$tran $tempArea\n";
	}

		
	# Matching NOT gates	
    if (/\bNOT11\b/i) {
		
		my @gateList = ($_ =~ m/(\w+)/g);				
		$gateName[0] = $gateList[1];			
		@gateList = ($gateList[0], @gateList[2..$#gateList]);		
		
		$i=0;				
		$INV[$i][0] = $gateList[0]; #output is stored here
		$INV[$i][1] = $gateList[2];	#first input is stored here					
		
		if ($d == 1) {
			print OUT "\n*N".$_;
		}

		#  nmos transistor
		print OUT "M_not".$ninv."_1 N".$INV[$i][0]." N".$INV[$i][1]." GND $nmos\n\n";
		$tran++;
		$tempArea += $WN;
		print OUT_AREA "$tran $tempArea\n";
		
		#  pmos transistors
		print OUT "M_not".$ninv."_2 N".$INV[$i][0]." N".$INV[$i][1]." VDD $pmos1\n";
		print OUT "M_not".$ninv."_3 N".$INV[$i][0]." N".$INV[$i][1]." VDD $pmos1\n\n";
				
		$ninv++;
		$area += $WN + 2*$WP1;		
		
		$tran++;
		$tempArea += $WP1;
		print OUT_AREA "$tran $tempArea\n";
		
		$tran++;
		$tempArea += $WP1;
		print OUT_AREA "$tran $tempArea\n";
	}
	
	
	# Matching NOT2 gates	
    elsif (/\bNOT12\b/i) {
		
		my @gateList = ($_ =~ m/(\w+)/g);				
		$gateName[0] = $gateList[1];			
		@gateList = ($gateList[0], @gateList[2..$#gateList]);		
		
		$i=0;				
		$INV[$i][0] = $gateList[0]; #output is stored here
		$INV[$i][1] = $gateList[2];	#first input is stored here						
		
		if ($d == 1) {
			print OUT "\n*N".$_;
		}

		#  nmos transistor
		print OUT "M_not".$ninv."_1 N".$INV[$i][0]." N".$INV[$i][1]." GND $nmos1\n";
		print OUT "M_not".$ninv."_2 N".$INV[$i][0]." N".$INV[$i][1]." GND $nmos1\n\n";
		
		$tran++;
		$tempArea += $WN1;
		print OUT_AREA "$tran $tempArea\n";
		
		$tran++;
		$tempArea += $WN1;
		print OUT_AREA "$tran $tempArea\n";
		
		#  pmos transistors
		print OUT "M_not".$ninv."_3 N".$INV[$i][0]." N".$INV[$i][1]." VDD $pmos\n\n";		
				
		$ninv++;
		$area += 2*$WN1 + $WP;		
		
		$tran++;
		$tempArea += $WP;
		print OUT_AREA "$tran $tempArea\n";
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
		
		if ($d == 1) {		
			print OUT "\n*N".$NAND[$i][1]." = NAND( ";
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
		print OUT "M_nand".$nnand."_1 N".$NAND[$i][1]." N".$NAND[$i][$j+2]." nd".$nnand."_".($j+1)." $nmos\n";		
		
		$tran++;
		$tempArea += $WN;
		print OUT_AREA "$tran $tempArea\n";
					
		for ($j=1; $j < $NAND[$i][0]-1 ; $j++){			
			print OUT "M_nand".$nnand."_".($j+1)." nd".$nnand."_".($j)." N".$NAND[$i][$j+2]." nd".$nnand."_".($j+1)." $nmos\n";								
			$tran++;
			$tempArea += $WN;
			print OUT_AREA "$tran $tempArea\n";
		}

		$j = ($NAND[$i][0]-2);		
		print OUT "M_nand".$nnand."_".$NAND[$i][0]." nd".$nnand."_".($j+1)." N".$NAND[$i][$j+3]." GND $nmos\n";		
		$tran++;
		$tempArea += $WN;
		print OUT_AREA "$tran $tempArea\n";
		
		if ($d == 1) {
			print OUT "\n";
		}

		# printing the pmos transistors		
		for ($k=0; $k < $NAND[$i][0] ; $k++){			
			print OUT "M_nand".$nnand."_".($NAND[$i][0]+$k+1)." N".$NAND[$i][1]." N".$NAND[$i][$k+2]." VDD $pmos \n";
			$tran++;
			$tempArea += $WP;
			print OUT_AREA "$tran $tempArea\n";
		}	

		$nnand++;	
		$area += (scalar @gateList - 1)*$WN + (scalar @gateList - 1)*$WP;		
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
				
		if ($d == 1) {	
		print OUT "\n*N".$NOR[$i][1]." = NOR( ";
			for ($j=0; $j < $NOR[$i][0] ; $j++){
				if ($j == $NOR[$i][0]-1){
					print OUT "N".$NOR[$i][2+$j]." ) \n";
				} else {
					print OUT "N".$NOR[$i][2+$j].", ";
				}
			}
		}

		$i=0;
		$j=0;
		# printing the nmos transistors
		for ($k=0; $k < $NOR[$i][0] ; $k++) {
			print OUT "M_nnor".$nnor."_".($k+1)." N".$NOR[$i][1]." N".$NOR[$i][$k+2]." GND $nmos \n";	
			$count++;
			$tran++;
			$tempArea += $WN;
			print OUT_AREA "$tran $tempArea\n";					
		}
		
		if ($d == 1) {
			print OUT "\n";
		}

		# printing the pmos transistors
		print OUT "M_nnor".$nnor."_".($tran+1)." N".$NOR[$i][1]." N".$NOR[$i][$j+2]." nr".$nnor."_".($j+1)." $pmos\n";	
		$tran++;
		$tempArea += $WP;
		print OUT_AREA "$tran $tempArea\n";
			
		for ($j=1; $j < $NOR[$i][0]-1 ; $j++) {
			print OUT "M_nnor".$nnor."_".($tran+1)." nr".$nnor."_".($j)." N".$NOR[$i][$j+2]." nr".$nnor."_".($j+1)." $pmos\n";
			$tran++;
			$tempArea += $WP;
			print OUT_AREA "$tran $tempArea\n";		
        }
		
		$j = ($NOR[$i][0]-2);	
		print OUT "M_nnor".$nnor."_".($tran+1)." nr".$nnor."_".($j+1)." N".$NOR[$i][$j+3]." VDD $pmos\n";
		$tran++;
		$tempArea += $WP;
		print OUT_AREA "$tran $tempArea\n";				
		
		$nnor++;
		$area += (scalar @gateList - 1)*$WN + (scalar @gateList - 1)*$WP;
	}
	
		
	# Matching NAND21 gates	
	if (/\bNAND21|NAND31|NAND41\b/i) {		
		
		my @gateList = ($_ =~ m/(\w+)/g);				
		$gateName[0] = $gateList[1];			
		@gateList = ($gateList[0], @gateList[2..$#gateList]);		
				
		$i=0;		
		$DNAND[$i][0] = scalar @gateList - 2; #number of inputs.
		$DNAND[$i][1] = $gateList[0]; #output is stored here		
			
		foreach $k (2..scalar @gateList)
		{	$DNAND[$i][$k] = $gateList[$k];	}								
		
		if ($d == 1) {	
			print OUT "\n*N".$DNAND[$i][1]." = $gateList[1](";
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
		
		$j=0;
		$i=1;
		foreach $kk (1..scalar @gateList - 2) {					
			
			if ($kk == 1) { #insert first transistor.
				print OUT "M_dnand".$dnnand."_".$i." N".$output." N".$DNAND[0][$kk+1]." ndd".$dnnand."_".($j+1)." $nmos\n";		
				$j += 1;	
				$i += 1;
				
				$tran++;
				$tempArea += $WN;
				print OUT_AREA "$tran $tempArea\n";		
			}			
			else {
				if ($kk == scalar @gateList - 2) { #if last gate
					print OUT "M_dnand".$dnnand."_".($i)." ndd".$dnnand."_".($j)." N".$DNAND[0][$kk+1]." GND $nmos\n";								
					$j += 1;						
					$i += 1;
					
					$tran++;
					$tempArea += $WN;
					print OUT_AREA "$tran $tempArea\n";
				}
				else {
					print OUT "M_dnand".$dnnand."_".($i)." ndd".$dnnand."_".($j)." N".$DNAND[0][$kk+1]." ndd".$dnnand."_".($j+1)." $nmos\n";		
					$j += 1;
					$i += 1;
					
					$tran++;
					$tempArea += $WN;
					print OUT_AREA "$tran $tempArea\n";		
				}			
			}				
		}	
		
		if ($d == 1) {
			print OUT "\n";
		}
		
		# printing the pmos transistors		
		print OUT "M_dnand".$dnnand."_".($i)." N".$output." N".$DNAND[0][2]." VDD $pmos1\n";													
		print OUT "M_dnand".$dnnand."_".($i+1)." N".$output." N".$DNAND[0][2]." VDD $pmos1\n";	

		$tran++;
		$tempArea += $WP1;
		print OUT_AREA "$tran $tempArea\n";		
		
		$tran++;
		$tempArea += $WP1;
		print OUT_AREA "$tran $tempArea\n";		
				
		foreach $kk (2..scalar @gateList - 2) {											
			print OUT "M_dnand".$dnnand."_".($i+2)." N".$output." N".$DNAND[0][$kk+1]." VDD $pmos\n";													
			$i += 1;

			$tran++;
			$tempArea += $WP;
			print OUT_AREA "$tran $tempArea\n";			
		}							
		
		$dnnand++;	
		print OUT "\n";		
		$area += (scalar @gateList - 2)*$WN + 2*$WP1 + (scalar @gateList - 3)*$WP;
	}
	
		
	# Matching NAND32 and NAND42 gates	
	if (/\bNAND32|NAND42\b/i) {		
		
		my @gateList = ($_ =~ m/(\w+)/g);				
		$gateName[0] = $gateList[1];			
		@gateList = ($gateList[0], @gateList[2..$#gateList]);		
		
		# print "GateList = @gateList\n";
		$i=0;		
		$DNAND[$i][0] = scalar @gateList - 2; #number of inputs.
		$DNAND[$i][1] = $gateList[0]; #output is stored here		
			
		foreach $k (2..scalar @gateList)
		{	$DNAND[$i][$k] = $gateList[$k];	}								
		
		if ($d == 1) {	
			print OUT "\n*N".$DNAND[$i][1]." = $gateList[1](";
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
		
		$j=0;
		$i=1;
		foreach $kk (1..scalar @gateList - 2) {					
			
			if ($kk == 1) { #insert first transistor.
				print OUT "M_dnand".$dnnand."_".$i." N".$output." N".$DNAND[0][$kk+1]." ndd".$dnnand."_".($j+1)." $nmos\n";		
				$j += 1;	
				$i += 1;
				
				$tran++;
				$tempArea += $WN;
				print OUT_AREA "$tran $tempArea\n"
			}			
			else {
				if ($kk == scalar @gateList - 2) { #if last gate
					print OUT "M_dnand".$dnnand."_".($i)." ndd".$dnnand."_".($j)." N".$DNAND[0][$kk+1]." GND $nmos\n";								
					$j += 1;						
					$i += 1;
					
					$tran++;
					$tempArea += $WN;
					print OUT_AREA "$tran $tempArea\n"
					
				}
				else {
					print OUT "M_dnand".$dnnand."_".($i)." ndd".$dnnand."_".($j)." N".$DNAND[0][$kk+1]." ndd".$dnnand."_".($j+1)." $nmos\n";		
					$j += 1;
					$i += 1;
					
					$tran++;
					$tempArea += $WN;
					print OUT_AREA "$tran $tempArea\n"
				}			
			}				
		}	
		
		if ($d == 1) {
			print OUT "\n";
		}
		
		# printing the pmos transistors		
		print OUT "M_dnand".$dnnand."_".($i)." N".$output." N".$DNAND[0][2]." VDD $pmos1\n";	
		print OUT "M_dnand".$dnnand."_".($i+1)." N".$output." N".$DNAND[0][2]." VDD $pmos1\n";	

		$tran++;
		$tempArea += $WP1;
		print OUT_AREA "$tran $tempArea\n";			
		
		$tran++;
		$tempArea += $WP1;
		print OUT_AREA "$tran $tempArea\n";			
		
		print OUT "M_dnand".$dnnand."_".($i+2)." N".$output." N".$DNAND[0][3]." VDD $pmos1\n";
		print OUT "M_dnand".$dnnand."_".($i+3)." N".$output." N".$DNAND[0][3]." VDD $pmos1\n";
		
		$tran++;
		$tempArea += $WP1;
		print OUT_AREA "$tran $tempArea\n";	
		
		$tran++;
		$tempArea += $WP1;
		print OUT_AREA "$tran $tempArea\n";	
			
		foreach $kk (3..scalar @gateList - 2) {											
			print OUT "M_dnand".$dnnand."_".($i+4)." N".$output." N".$DNAND[0][$kk+1]." VDD $pmos\n";													
			$i += 1;				
				
			$tran++;
			$tempArea += $WP;
			print OUT_AREA "$tran $tempArea\n";	
		}							
		
		$dnnand++;	
		print OUT "\n";
		$area += (scalar @gateList - 2)*$WN + 4*$WP1 + (scalar @gateList - 4)*$WP;
	}
	
	
	# Matching NAND32 and NAND42 gates	
	if (/\bNAND43\b/i) {		
		
		my @gateList = ($_ =~ m/(\w+)/g);				
		$gateName[0] = $gateList[1];			
		@gateList = ($gateList[0], @gateList[2..$#gateList]);		
		
		# print "GateList = @gateList\n";
		$i=0;		
		$DNAND[$i][0] = scalar @gateList - 2; #number of inputs.
		$DNAND[$i][1] = $gateList[0]; #output is stored here		
			
		foreach $k (2..scalar @gateList)
		{	$DNAND[$i][$k] = $gateList[$k];	}								
		
		if ($d == 1) {	
			print OUT "\n*N".$DNAND[$i][1]." = $gateList[1](";
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
		
		$j=0;
		$i=1;
		foreach $kk (1..scalar @gateList - 2) {					
			
			if ($kk == 1) { #insert first transistor.
				print OUT "M_dnand".$dnnand."_".$i." N".$output." N".$DNAND[0][$kk+1]." ndd".$dnnand."_".($j+1)." $nmos\n";		
				$j += 1;	
				$i += 1;
				
				$tran++;
				$tempArea += $WN;
				print OUT_AREA "$tran $tempArea\n"
			}			
			else {
				if ($kk == scalar @gateList - 2) { #if last gate
					print OUT "M_dnand".$dnnand."_".($i)." ndd".$dnnand."_".($j)." N".$DNAND[0][$kk+1]." GND $nmos\n";								
					$j += 1;						
					$i += 1;
					
					$tran++;
					$tempArea += $WN;
					print OUT_AREA "$tran $tempArea\n"
					
				}
				else {
					print OUT "M_dnand".$dnnand."_".($i)." ndd".$dnnand."_".($j)." N".$DNAND[0][$kk+1]." ndd".$dnnand."_".($j+1)." $nmos\n";		
					$j += 1;
					$i += 1;
					
					$tran++;
					$tempArea += $WN;
					print OUT_AREA "$tran $tempArea\n"
				}			
			}				
		}	
		
		if ($d == 1) {
			print OUT "\n";
		}
		
		# printing the pmos transistors		
		print OUT "M_dnand".$dnnand."_".($i)." N".$output." N".$DNAND[0][2]." VDD $pmos1\n";
		print OUT "M_dnand".$dnnand."_".($i+1)." N".$output." N".$DNAND[0][2]." VDD $pmos1\n";	

		print OUT "M_dnand".$dnnand."_".($i+2)." N".$output." N".$DNAND[0][3]." VDD $pmos1\n";
		print OUT "M_dnand".$dnnand."_".($i+3)." N".$output." N".$DNAND[0][3]." VDD $pmos1\n";
		
		print OUT "M_dnand".$dnnand."_".($i+4)." N".$output." N".$DNAND[0][3]." VDD $pmos1\n";
		print OUT "M_dnand".$dnnand."_".($i+5)." N".$output." N".$DNAND[0][3]." VDD $pmos1\n";
		
		$tran++;
		$tempArea += $WP1;
		print OUT_AREA "$tran $tempArea\n";	

		$tran++;
		$tempArea += $WP1;
		print OUT_AREA "$tran $tempArea\n";	
		
		$tran++;
		$tempArea += $WP1;
		print OUT_AREA "$tran $tempArea\n";	
		
		$tran++;
		$tempArea += $WP1;
		print OUT_AREA "$tran $tempArea\n";	
		
		$tran++;
		$tempArea += $WP1;
		print OUT_AREA "$tran $tempArea\n";	
		
		$tran++;
		$tempArea += $WP1;
		print OUT_AREA "$tran $tempArea\n";	
						
		print OUT "M_dnand".$dnnand."_".($i+6)." N".$output." N".$DNAND[0][$kk+1]." VDD $pmos\n";													
						
		$tran++;
		$tempArea += $WP;
		print OUT_AREA "$tran $tempArea\n";	
									
		
		$dnnand++;	
		print OUT "\n";
		$area += (scalar @gateList - 2)*$WN + 6*$WP1 + (scalar @gateList - 5)*$WP;
	}
	
	
	# Matching NAND22, NAND33 or NAND44 gates	
	if (/\bNAND22|NAND33|NAND44\b/i) {		
		
		my @gateList = ($_ =~ m/(\w+\d)/g);			#Read All the Gates
		my @gateName = ($_ =~ m/(\w+)\(/i);  		#Read the gate Name i.e. DNAND				
				
		$i=0;		
		$DNAND[$i][0] = scalar @gateList - 2; #number of inputs.
		$DNAND[$i][1] = $gateList[0]; #output is stored here		
			
		foreach $k (2..scalar @gateList)
		{	$DNAND[$i][$k] = $gateList[$k];	}								
		
		if ($d == 1) {	
			print OUT "\n*N".$DNAND[$i][1]." = $gateList[1](";
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
		
		$j=0;
		$i=1;
		foreach $kk (1..scalar @gateList - 2) {					
			
			if ($kk == 1) { #insert first transistor.
				print OUT "M_dnand".$dnnand."_".$i." N".$output." N".$DNAND[0][$kk+1]." ndd".$dnnand."_".($j+1)." $nmos\n";		
				$j += 1;	
				$i += 1;
				
				$tran++;
				$tempArea += $WN;
				print OUT_AREA "$tran $tempArea\n";
			}			
			else {
				if ($kk == scalar @gateList - 2) { #if last gate
					print OUT "M_dnand".$dnnand."_".($i)." ndd".$dnnand."_".($j)." N".$DNAND[0][$kk+1]." GND $nmos\n";								
					$j += 1;						
					$i += 1;
					
					$tran++;
					$tempArea += $WN;
					print OUT_AREA "$tran $tempArea\n";
				}
				else {
					print OUT "M_dnand".$dnnand."_".($i)." ndd".$dnnand."_".($j)." N".$DNAND[0][$kk+1]." ndd".$dnnand."_".($j+1)." $nmos\n";		
					$j += 1;
					$i += 1;
					
					$tran++;
					$tempArea += $WN;
					print OUT_AREA "$tran $tempArea\n";
				}			
			}				
		}	
		
		if ($d == 1) {
			print OUT "\n";
		}
		
		# printing the pmos transistors							
		foreach $kk (1..scalar @gateList - 2) {											
			print OUT "M_dnand".$dnnand."_".($i)." N".$output." N".$DNAND[0][$kk+1]." VDD $pmos1\n";													
			print OUT "M_dnand".$dnnand."_".($i+1)." N".$output." N".$DNAND[0][$kk+1]." VDD $pmos1\n";	
			$i += 2;				
			
			$tran++;
			$tempArea += $WP1;
			print OUT_AREA "$tran $tempArea\n";
			
			$tran++;
			$tempArea += $WP1;
			print OUT_AREA "$tran $tempArea\n";
		}							
		
		$dnnand++;	
		print OUT "\n";
		
		$area += (scalar @gateList - 2)*$WN + 2*(scalar @gateList - 2)*$WP1;		
	}
	
		
	# Matching NAND24, NAND35, NAND46 gates	
	if (/\bNAND24|NAND35|NAND46\b/i) {		
					
		my @gateList = ($_ =~ m/(\w+)/g);				
		$gateName[0] = $gateList[1];			
		@gateList = ($gateList[0], @gateList[2..$#gateList]);		
				
		$i=0;		
		$DNAND[$i][0] = scalar @gateList - 2; #number of inputs.
		$DNAND[$i][1] = $gateList[0]; #output is stored here		
			
		foreach $k (2..scalar @gateList)
		{	$DNAND[$i][$k] = $gateList[$k];	}								
		
		if ($d == 1) {	
			print OUT "\n*N".$DNAND[$i][1]." = $gateList[1](";
			for ($j=0; $j < $DNAND[$i][0] ; $j++){
				if ($j == $DNAND[$i][0]-1){
					print OUT "N".$DNAND[$i][2+$j]." ) \n";
				} else {
					print OUT "N".$DNAND[$i][2+$j].", ";
				}
			}
		}	

		$currentNmos = ();
		$currentWN = ();
		if($DNAND[0][0] == 2) {
			$currentNmos = $nmos5;
			$currentWN = $WN5;
		}
		elsif($DNAND[0][0] == 3) {
			$currentNmos = $nmos3;
			$currentWN = $WN3;
		}
		elsif($DNAND[0][0] == 4) {
			$currentNmos = $nmos4;
			$currentWN = $WN4;
		}		
		
		$i=0;
		$output = $DNAND[$i][1];
		
		$j=0;
		$i=1;
		foreach $kk (1..scalar @gateList - 2) {					
			
			if ($kk == 1) { #insert first transistor.
				print OUT "M_dnand".$dnnand."_".($i)." N".$output." N".$DNAND[0][$kk+1]." ndd".$dnnand."_".($j+1)." $currentNmos\n";					
				print OUT "M_dnand".$dnnand."_".($i+1)." N".$output." N".$DNAND[0][$kk+1]." ndd".$dnnand."_".($j+1)." $currentNmos\n";	
				$j += 1;	
				$i += 2;
				
				$tran++;
				$tempArea += $currentWN;
				print OUT_AREA "$tran $tempArea\n";
				
				$tran++;
				$tempArea += $currentWN;
				print OUT_AREA "$tran $tempArea\n";
			}			
			else {
				if ($kk == scalar @gateList - 2) { #if last gate
					print OUT "M_dnand".$dnnand."_".($i)." ndd".$dnnand."_".($j)." N".$DNAND[0][$kk+1]." GND $currentNmos\n";								
					print OUT "M_dnand".$dnnand."_".($i+1)." ndd".$dnnand."_".($j)." N".$DNAND[0][$kk+1]." GND $currentNmos\n";
					$j += 1;												
					$i += 2;

					$tran++;
					$tempArea += $currentWN;
					print OUT_AREA "$tran $tempArea\n";
					
					$tran++;
					$tempArea += $currentWN;
					print OUT_AREA "$tran $tempArea\n";
				}
				else {
					print OUT "M_dnand".$dnnand."_".($i)." ndd".$dnnand."_".($j)." N".$DNAND[0][$kk+1]." ndd".$dnnand."_".($j+1)." $currentNmos\n";
					print OUT "M_dnand".$dnnand."_".($i+1)." ndd".$dnnand."_".($j)." N".$DNAND[0][$kk+1]." ndd".$dnnand."_".($j+1)." $currentNmos\n";
					$j += 1;															
					$i += 2;	
					
					$tran++;
					$tempArea += $currentWN;
					print OUT_AREA "$tran $tempArea\n";
					
					$tran++;
					$tempArea += $currentWN;
					print OUT_AREA "$tran $tempArea\n";
				}			
			}				
		}	
		
		if ($d == 1) {
			print OUT "\n";
		}
		
		# printing the pmos transistors	
		$ind = 0;
		print OUT "M_dnand".$dnnand."_".($i)." N".$output." N".$DNAND[0][2]." VDD $pmos1\n";					
		print OUT "M_dnand".$dnnand."_".($i+1)." N".$output." N".$DNAND[0][2]." VDD $pmos1\n";								
		
		$i +=2;
		$tran++;
		$tempArea += $WP1;
		print OUT_AREA "$tran $tempArea\n";
					
		$tran++;
		$tempArea += $WP1;
		print OUT_AREA "$tran $tempArea\n";	
		
		$max = scalar @gateList - 2;		
		foreach $kk (2..$max) {											
			print OUT "M_dnand".$dnnand."_".($i)." N".$output." N".$DNAND[0][$kk+1]." VDD $pmos\n";
			$i += 1;
			$tran++;
			$tempArea += $WP;
			print OUT_AREA "$tran $tempArea\n";
		}					
			
		$dnnand++;	
		print OUT "\n";
		
		$area += 2*$max*$currentWN + 2*$WP1 + ($max-1)*$WP;
	}
	
	
	# Matching NAND36, NAND47 gates	
	if (/\bNAND36|NAND47\b/i) {		
					
		my @gateList = ($_ =~ m/(\w+)/g);				
		$gateName[0] = $gateList[1];			
		@gateList = ($gateList[0], @gateList[2..$#gateList]);		
				
		$i=0;		
		$DNAND[$i][0] = scalar @gateList - 2; #number of inputs.
		$DNAND[$i][1] = $gateList[0]; #output is stored here		
			
		foreach $k (2..scalar @gateList)
		{	$DNAND[$i][$k] = $gateList[$k];	}								
		
		if ($d == 1) {	
			print OUT "\n*N".$DNAND[$i][1]." = $gateList[1](";
			for ($j=0; $j < $DNAND[$i][0] ; $j++){
				if ($j == $DNAND[$i][0]-1){
					print OUT "N".$DNAND[$i][2+$j]." ) \n";
				} else {
					print OUT "N".$DNAND[$i][2+$j].", ";
				}
			}
		}		

		$currentNmos = ();
		$currentWN = ();
		if($DNAND[0][0] == 2) {
			$currentNmos = $nmos5;
			$currentWN = $WN5;
		}
		elsif($DNAND[0][0] == 3) {
			$currentNmos = $nmos6;
			$currentWN = $WN6;
		}
		elsif($DNAND[0][0] == 4) {
			$currentNmos = $nmos4;
			$currentWN = $WN4;
		}				
		
		$i=0;
		$output = $DNAND[$i][1];
		
		$j=0;
		$i=1;
		foreach $kk (1..scalar @gateList - 2) {					
			
			if ($kk == 1) { #insert first transistor.
				print OUT "M_dnand".$dnnand."_".($i)." N".$output." N".$DNAND[0][$kk+1]." ndd".$dnnand."_".($j+1)." $currentNmos\n";					
				print OUT "M_dnand".$dnnand."_".($i+1)." N".$output." N".$DNAND[0][$kk+1]." ndd".$dnnand."_".($j+1)." $currentNmos\n";	
				$j += 1;	
				$i += 2;
				
				$tran++;
				$tempArea += $currentWN;
				print OUT_AREA "$tran $tempArea\n";
				
				$tran++;
				$tempArea += $currentWN;
				print OUT_AREA "$tran $tempArea\n";
			}			
			else {
				if ($kk == scalar @gateList - 2) { #if last gate
					print OUT "M_dnand".$dnnand."_".($i)." ndd".$dnnand."_".($j)." N".$DNAND[0][$kk+1]." GND $currentNmos\n";								
					print OUT "M_dnand".$dnnand."_".($i+1)." ndd".$dnnand."_".($j)." N".$DNAND[0][$kk+1]." GND $currentNmos\n";
					$j += 1;												
					$i += 2;

					$tran++;
					$tempArea += $currentWN;
					print OUT_AREA "$tran $tempArea\n";
					
					$tran++;
					$tempArea += $currentWN;
					print OUT_AREA "$tran $tempArea\n";
				}
				else {
					print OUT "M_dnand".$dnnand."_".($i)." ndd".$dnnand."_".($j)." N".$DNAND[0][$kk+1]." ndd".$dnnand."_".($j+1)." $currentNmos\n";
					print OUT "M_dnand".$dnnand."_".($i+1)." ndd".$dnnand."_".($j)." N".$DNAND[0][$kk+1]." ndd".$dnnand."_".($j+1)." $currentNmos\n";
					$j += 1;															
					$i += 2;	
					
					$tran++;
					$tempArea += $currentWN;
					print OUT_AREA "$tran $tempArea\n";
					
					$tran++;
					$tempArea += $currentWN;
					print OUT_AREA "$tran $tempArea\n";
				}			
			}				
		}	
		
		if ($d == 1) {
			print OUT "\n";
		}
		
		# printing the pmos transistors			
		print OUT "M_dnand".$dnnand."_".($i)." N".$output." N".$DNAND[0][2]." VDD $pmos1\n";					
		print OUT "M_dnand".$dnnand."_".($i+1)." N".$output." N".$DNAND[0][2]." VDD $pmos1\n";								
		
		$i +=2;
		$tran++;
		$tempArea += $WP1;
		print OUT_AREA "$tran $tempArea\n";
					
		$tran++;
		$tempArea += $WP1;
		print OUT_AREA "$tran $tempArea\n";	
		
		print OUT "M_dnand".$dnnand."_".($i)." N".$output." N".$DNAND[0][3]." VDD $pmos1\n";					
		print OUT "M_dnand".$dnnand."_".($i+1)." N".$output." N".$DNAND[0][3]." VDD $pmos1\n";								
		
		$i +=2;
		$tran++;
		$tempArea += $WP1;
		print OUT_AREA "$tran $tempArea\n";
					
		$tran++;
		$tempArea += $WP1;
		print OUT_AREA "$tran $tempArea\n";	
		
		$max = scalar @gateList - 2;		
		foreach $kk (3..$max) {											
			print OUT "M_dnand".$dnnand."_".($i)." N".$output." N".$DNAND[0][$kk+1]." VDD $pmos\n";
			$i += 1;
			$tran++;
			$tempArea += $WP;
			print OUT_AREA "$tran $tempArea\n";
		}					
			
		$dnnand++;	
		print OUT "\n";
		
		$area += 2*$max*$currentWN + 4*$WP1 + ($max-2)*$WP;
	}
	
	
	# Matching NAND48 gates	
	if (/\bNAND48\b/i) {		
					
		my @gateList = ($_ =~ m/(\w+)/g);				
		$gateName[0] = $gateList[1];			
		@gateList = ($gateList[0], @gateList[2..$#gateList]);		
				
		$i=0;		
		$DNAND[$i][0] = scalar @gateList - 2; #number of inputs.
		$DNAND[$i][1] = $gateList[0]; #output is stored here		
			
		foreach $k (2..scalar @gateList)
		{	$DNAND[$i][$k] = $gateList[$k];	}								
		
		if ($d == 1) {	
			print OUT "\n*N".$DNAND[$i][1]." = $gateList[1](";
			for ($j=0; $j < $DNAND[$i][0] ; $j++){
				if ($j == $DNAND[$i][0]-1){
					print OUT "N".$DNAND[$i][2+$j]." ) \n";
				} else {
					print OUT "N".$DNAND[$i][2+$j].", ";
				}
			}
		}		

		$currentNmos = ();
		$currentWN = ();
		if($DNAND[0][0] == 2) {
			$currentNmos = $nmos5;
			$currentWN = $WN5;
		}
		elsif($DNAND[0][0] == 3) {
			$currentNmos = $nmos6;
			$currentWN = $WN6;
		}
		elsif($DNAND[0][0] == 4) {
			$currentNmos = $nmos7;
			$currentWN = $WN7;
		}				
		
		$i=0;
		$output = $DNAND[$i][1];
		
		$j=0;
		$i=1;
		foreach $kk (1..scalar @gateList - 2) {					
			
			if ($kk == 1) { #insert first transistor.
				print OUT "M_dnand".$dnnand."_".($i)." N".$output." N".$DNAND[0][$kk+1]." ndd".$dnnand."_".($j+1)." $currentNmos\n";					
				print OUT "M_dnand".$dnnand."_".($i+1)." N".$output." N".$DNAND[0][$kk+1]." ndd".$dnnand."_".($j+1)." $currentNmos\n";	
				$j += 1;	
				$i += 2;
				
				$tran++;
				$tempArea += $currentWN;
				print OUT_AREA "$tran $tempArea\n";
				
				$tran++;
				$tempArea += $currentWN;
				print OUT_AREA "$tran $tempArea\n";
			}			
			else {
				if ($kk == scalar @gateList - 2) { #if last gate
					print OUT "M_dnand".$dnnand."_".($i)." ndd".$dnnand."_".($j)." N".$DNAND[0][$kk+1]." GND $currentNmos\n";								
					print OUT "M_dnand".$dnnand."_".($i+1)." ndd".$dnnand."_".($j)." N".$DNAND[0][$kk+1]." GND $currentNmos\n";
					$j += 1;												
					$i += 2;

					$tran++;
					$tempArea += $currentWN;
					print OUT_AREA "$tran $tempArea\n";
					
					$tran++;
					$tempArea += $currentWN;
					print OUT_AREA "$tran $tempArea\n";
				}
				else {
					print OUT "M_dnand".$dnnand."_".($i)." ndd".$dnnand."_".($j)." N".$DNAND[0][$kk+1]." ndd".$dnnand."_".($j+1)." $currentNmos\n";
					print OUT "M_dnand".$dnnand."_".($i+1)." ndd".$dnnand."_".($j)." N".$DNAND[0][$kk+1]." ndd".$dnnand."_".($j+1)." $currentNmos\n";
					$j += 1;															
					$i += 2;	
					
					$tran++;
					$tempArea += $currentWN;
					print OUT_AREA "$tran $tempArea\n";
					
					$tran++;
					$tempArea += $currentWN;
					print OUT_AREA "$tran $tempArea\n";
				}			
			}				
		}	
		
		if ($d == 1) {
			print OUT "\n";
		}
		
		# printing the pmos transistors			
		print OUT "M_dnand".$dnnand."_".($i)." N".$output." N".$DNAND[0][2]." VDD $pmos1\n";					
		print OUT "M_dnand".$dnnand."_".($i+1)." N".$output." N".$DNAND[0][2]." VDD $pmos1\n";								
		
		$i +=2;
		$tran++;
		$tempArea += $WP1;
		print OUT_AREA "$tran $tempArea\n";
					
		$tran++;
		$tempArea += $WP1;
		print OUT_AREA "$tran $tempArea\n";	
		
		print OUT "M_dnand".$dnnand."_".($i)." N".$output." N".$DNAND[0][3]." VDD $pmos1\n";					
		print OUT "M_dnand".$dnnand."_".($i+1)." N".$output." N".$DNAND[0][3]." VDD $pmos1\n";								
		
		$i +=2;
		$tran++;
		$tempArea += $WP1;
		print OUT_AREA "$tran $tempArea\n";
					
		$tran++;
		$tempArea += $WP1;
		print OUT_AREA "$tran $tempArea\n";	
		
		print OUT "M_dnand".$dnnand."_".($i)." N".$output." N".$DNAND[0][4]." VDD $pmos1\n";					
		print OUT "M_dnand".$dnnand."_".($i+1)." N".$output." N".$DNAND[0][4]." VDD $pmos1\n";								
		
		$i +=2;
		$tran++;
		$tempArea += $WP1;
		print OUT_AREA "$tran $tempArea\n";
					
		$tran++;
		$tempArea += $WP1;
		print OUT_AREA "$tran $tempArea\n";	
		
		$max = scalar @gateList - 2;		
		foreach $kk (4..$max) {											
			print OUT "M_dnand".$dnnand."_".($i)." N".$output." N".$DNAND[0][$kk+1]." VDD $pmos\n";
			$i += 1;
			$tran++;
			$tempArea += $WP;
			print OUT_AREA "$tran $tempArea\n";
		}					
			
		$dnnand++;	
		print OUT "\n";
		
		$area += 2*$max*$currentWN + 6*$WP1 + ($max-3)*$WP;
	}
	
	
	# Matching NAND23 gates	
	if (/\bNAND23\b/i) {		
		
		my @gateList = ($_ =~ m/(\w+)/g);				
		$gateName[0] = $gateList[1];			
		@gateList = ($gateList[0], @gateList[2..$#gateList]);		
				
		$i=0;		
		$DNAND[$i][0] = scalar @gateList - 2; #number of inputs.
		$DNAND[$i][1] = $gateList[0]; #output is stored here		
			
		foreach $k (2..scalar @gateList)
		{	$DNAND[$i][$k] = $gateList[$k];	}								
		
		if ($d == 1) {	
			print OUT "\n*N".$DNAND[$i][1]." = $gateList[1](";
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
		
		$j=0;
		$i=1;
		foreach $kk (1..scalar @gateList - 2) {					
			
			if ($kk == 1) { #insert first transistor.
				print OUT "M_dnand".$dnnand."_".($i)." N".$output." N".$DNAND[0][$kk+1]." ndd".$dnnand."_".($j+1)." $nmos2\n";					
				print OUT "M_dnand".$dnnand."_".($i+1)." N".$output." N".$DNAND[0][$kk+1]." ndd".$dnnand."_".($j+1)." $nmos2\n";	
				$j += 1;	
				$i += 2;
				
				$tran++;
				$tempArea += $WN2;
				print OUT_AREA "$tran $tempArea\n";
				
				$tran++;
				$tempArea += $WN2;
				print OUT_AREA "$tran $tempArea\n";
			}			
			else {
				if ($kk == scalar @gateList - 2) { #if last gate
					print OUT "M_dnand".$dnnand."_".($i)." ndd".$dnnand."_".($j)." N".$DNAND[0][$kk+1]." GND $nmos2\n";								
					print OUT "M_dnand".$dnnand."_".($i+1)." ndd".$dnnand."_".($j)." N".$DNAND[0][$kk+1]." GND $nmos2\n";
					$j += 1;												
					$i += 2;

					$tran++;
					$tempArea += $WN2;
					print OUT_AREA "$tran $tempArea\n";
					
					$tran++;
					$tempArea += $WN2;
					print OUT_AREA "$tran $tempArea\n";
				}
				else {
					print OUT "M_dnand".$dnnand."_".($i)." ndd".$dnnand."_".($j)." N".$DNAND[0][$kk+1]." ndd".$dnnand."_".($j+1)." $nmos2\n";
					print OUT "M_dnand".$dnnand."_".($i+1)." ndd".$dnnand."_".($j)." N".$DNAND[0][$kk+1]." ndd".$dnnand."_".($j+1)." $nmos2\n";
					$j += 1;															
					$i += 2;	
					
					$tran++;
					$tempArea += $WN2;
					print OUT_AREA "$tran $tempArea\n";
					
					$tran++;
					$tempArea += $WN2;
					print OUT_AREA "$tran $tempArea\n";
				}			
			}				
		}	
		
		if ($d == 1) {
			print OUT "\n";
		}
		
		# printing the pmos transistors							
		foreach $kk (1..scalar @gateList - 2) {											
			print OUT "M_dnand".$dnnand."_".($i)." N".$output." N".$DNAND[0][$kk+1]." VDD $pmos\n";																
			$i += 1;	
			
			$tran++;
			$tempArea += $WP;
			print OUT_AREA "$tran $tempArea\n";
		}							
		
		$dnnand++;	
		print OUT "\n";
		$area += 2*(scalar @gateList - 2)*$WN2 + (scalar @gateList - 2)*$WP;		
	}
		
	
	# Matching NAND34 gates	
	if (/\bNAND34\b/i) {		
		
		my @gateList = ($_ =~ m/(\w+)/g);				
		$gateName[0] = $gateList[1];			
		@gateList = ($gateList[0], @gateList[2..$#gateList]);		
				
		$i=0;		
		$DNAND[$i][0] = scalar @gateList - 2; #number of inputs.
		$DNAND[$i][1] = $gateList[0]; #output is stored here		
			
		foreach $k (2..scalar @gateList)
		{	$DNAND[$i][$k] = $gateList[$k];	}								
		
		if ($d == 1) {	
			print OUT "\n*N".$DNAND[$i][1]." = $gateList[1](";
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
		
		$j=0;
		$i=1;
		foreach $kk (1..scalar @gateList - 2) {					
			
			if ($kk == 1) { #insert first transistor.
				print OUT "M_dnand".$dnnand."_".($i)." N".$output." N".$DNAND[0][$kk+1]." ndd".$dnnand."_".($j+1)." $nmos3\n";					
				print OUT "M_dnand".$dnnand."_".($i+1)." N".$output." N".$DNAND[0][$kk+1]." ndd".$dnnand."_".($j+1)." $nmos3\n";	
				$j += 1;	
				$i += 2;
				
				$tran++;
				$tempArea += $WN3;
				print OUT_AREA "$tran $tempArea\n";
				
				$tran++;
				$tempArea += $WN3;
				print OUT_AREA "$tran $tempArea\n";
			}			
			else {
				if ($kk == scalar @gateList - 2) { #if last gate
					print OUT "M_dnand".$dnnand."_".($i)." ndd".$dnnand."_".($j)." N".$DNAND[0][$kk+1]." GND $nmos3\n";								
					print OUT "M_dnand".$dnnand."_".($i+1)." ndd".$dnnand."_".($j)." N".$DNAND[0][$kk+1]." GND $nmos3\n";
					$j += 1;												
					$i += 2;

					$tran++;
					$tempArea += $WN3;
					print OUT_AREA "$tran $tempArea\n";
					
					$tran++;
					$tempArea += $WN3;
					print OUT_AREA "$tran $tempArea\n";
				}
				else {
					print OUT "M_dnand".$dnnand."_".($i)." ndd".$dnnand."_".($j)." N".$DNAND[0][$kk+1]." ndd".$dnnand."_".($j+1)." $nmos3\n";
					print OUT "M_dnand".$dnnand."_".($i+1)." ndd".$dnnand."_".($j)." N".$DNAND[0][$kk+1]." ndd".$dnnand."_".($j+1)." $nmos3\n";
					$j += 1;															
					$i += 2;	
					
					$tran++;
					$tempArea += $WN3;
					print OUT_AREA "$tran $tempArea\n";
					
					$tran++;
					$tempArea += $WN3;
					print OUT_AREA "$tran $tempArea\n";
				}			
			}				
		}	
		
		if ($d == 1) {
			print OUT "\n";
		}
		
		# printing the pmos transistors							
		foreach $kk (1..scalar @gateList - 2) {											
			print OUT "M_dnand".$dnnand."_".($i)." N".$output." N".$DNAND[0][$kk+1]." VDD $pmos\n";																
			$i += 1;	
			
			$tran++;
			$tempArea += $WP;
			print OUT_AREA "$tran $tempArea\n";
		}							
		
		$dnnand++;	
		print OUT "\n";
		$area += 2*(scalar @gateList - 2)*$WN3 + (scalar @gateList - 2)*$WP;		
	}
	
	
	# Matching NAND45 gates	
	if (/\bNAND45\b/i) {		
		
		my @gateList = ($_ =~ m/(\w+)/g);				
		$gateName[0] = $gateList[1];			
		@gateList = ($gateList[0], @gateList[2..$#gateList]);		
		
		$i=0;		
		$DNAND[$i][0] = scalar @gateList - 2; #number of inputs.
		$DNAND[$i][1] = $gateList[0]; #output is stored here		
			
		foreach $k (2..scalar @gateList)
		{	$DNAND[$i][$k] = $gateList[$k];	}								
		
		if ($d == 1) {	
			print OUT "\n*N".$DNAND[$i][1]." = $gateList[1](";
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
		
		$j=0;
		$i=1;
		foreach $kk (1..scalar @gateList - 2) {					
			
			if ($kk == 1) { #insert first transistor.
				print OUT "M_dnand".$dnnand."_".($i)." N".$output." N".$DNAND[0][$kk+1]." ndd".$dnnand."_".($j+1)." $nmos4\n";					
				print OUT "M_dnand".$dnnand."_".($i+1)." N".$output." N".$DNAND[0][$kk+1]." ndd".$dnnand."_".($j+1)." $nmos4\n";	
				$j += 1;	
				$i += 2;
				
				$tran++;
				$tempArea += $WN4;
				print OUT_AREA "$tran $tempArea\n";
				
				$tran++;
				$tempArea += $WN4;
				print OUT_AREA "$tran $tempArea\n";
			}			
			else {
				if ($kk == scalar @gateList - 2) { #if last gate
					print OUT "M_dnand".$dnnand."_".($i)." ndd".$dnnand."_".($j)." N".$DNAND[0][$kk+1]." GND $nmos4\n";								
					print OUT "M_dnand".$dnnand."_".($i+1)." ndd".$dnnand."_".($j)." N".$DNAND[0][$kk+1]." GND $nmos4\n";
					$j += 1;												
					$i += 2;

					$tran++;
					$tempArea += $WN4;
					print OUT_AREA "$tran $tempArea\n";
					
					$tran++;
					$tempArea += $WN4;
					print OUT_AREA "$tran $tempArea\n";
				}
				else {
					print OUT "M_dnand".$dnnand."_".($i)." ndd".$dnnand."_".($j)." N".$DNAND[0][$kk+1]." ndd".$dnnand."_".($j+1)." $nmos4\n";
					print OUT "M_dnand".$dnnand."_".($i+1)." ndd".$dnnand."_".($j)." N".$DNAND[0][$kk+1]." ndd".$dnnand."_".($j+1)." $nmos4\n";
					$j += 1;															
					$i += 2;	
					
					$tran++;
					$tempArea += $WN4;
					print OUT_AREA "$tran $tempArea\n";
					
					$tran++;
					$tempArea += $WN4;
					print OUT_AREA "$tran $tempArea\n";
				}			
			}				
		}	
		
		if ($d == 1) {
			print OUT "\n";
		}
		
		# printing the pmos transistors							
		foreach $kk (1..scalar @gateList - 2) {											
			print OUT "M_dnand".$dnnand."_".($i)." N".$output." N".$DNAND[0][$kk+1]." VDD $pmos\n";																
			$i += 1;	
			
			$tran++;
			$tempArea += $WP;
			print OUT_AREA "$tran $tempArea\n";
		}							
		
		$dnnand++;	
		print OUT "\n";
		$area += 2*(scalar @gateList - 2)*$WN4 + (scalar @gateList - 2)*$WP;		
	}
	
		
	# Matching NOR21, NOR31 or NOR41 gates	
	if (/\bNOR21|NOR31|NOR41\b/i) {		
		
		my @gateList = ($_ =~ m/(\w+)/g);				
		$gateName[0] = $gateList[1];			
		@gateList = ($gateList[0], @gateList[2..$#gateList]);		
			
		$i=0;		
		$DNOR[$i][0] = scalar @gateList - 2; #number of inputs.
		$DNOR[$i][1] = $gateList[0]; #output is stored here		
			
		foreach $k (2..scalar @gateList)
		{	$DNOR[$i][$k] = $gateList[$k];	}								
		
		if ($d == 1) {	
			print OUT "\n*N".$DNOR[$i][1]." = $gateList[1](";
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
		$i=1;
		
		# printing the nmos transistors		
		print OUT "M_dnor".$dnnor."_".($i)." N".$output." N".$DNOR[0][2]." GND $nmos1\n";
		print OUT "M_dnor".$dnnor."_".($i+1)." N".$output." N".$DNOR[0][2]." GND $nmos1\n";
		$i += 2;	

		$tran++;
		$tempArea += $WN1;
		print OUT_AREA "$tran $tempArea\n";		
		
		$tran++;
		$tempArea += $WN1;
		print OUT_AREA "$tran $tempArea\n";		
		
		foreach $kk (2..scalar @gateList - 2) {											
			print OUT "M_dnor".$dnnor."_".($i)." N".$output." N".$DNOR[0][$kk+1]." GND $nmos\n";													
			$i += 1;	

			$tran++;
			$tempArea += $WN;
			print OUT_AREA "$tran $tempArea\n";		
		}	

		if ($d == 1) {
			print OUT "\n";
		}		
		
		# printing the pmos transistors		
		foreach $kk (1..scalar @gateList - 2) {	
		
			if ($kk == 1) { #insert first transistor.
				print OUT "M_dnor".$dnnor."_".($i)." N".$output." N".$DNOR[0][$kk+1]." nrd".$dnnor."_".($j+1)." $pmos\n";									
				$j += 1;	
				$i += 1;
				
				$tran++;
				$tempArea += $WP;
				print OUT_AREA "$tran $tempArea\n";
			}			
			else {
				if ($kk == scalar @gateList - 2) { #if last gate
					print OUT "M_dnor".$dnnor."_".($i)." nrd".$dnnor."_".($j)." N".$DNOR[0][$kk+1]." VDD $pmos\n";													
					$j += 1;										
					$i += 1;

					$tran++;
					$tempArea += $WP;
					print OUT_AREA "$tran $tempArea\n";							
				}
				else {
					print OUT "M_dnor".$dnnor."_".($i)." nrd".$dnnor."_".($j)." N".$DNOR[0][$kk+1]." nrd".$dnnor."_".($j+1)." $pmos\n";					
					$j += 1;															
					$i += 1;

					$tran++;
					$tempArea += $WP;
					print OUT_AREA "$tran $tempArea\n";							
				}			
			}				
		}						
		
		$dnnor++;	
		print OUT "\n";
		$area += 2*$WN1 + (scalar @gateList - 3)*$WN + (scalar @gateList - 2)*$WP;	
	}
	
	
	# Matching NOR32 or NOR42 gates	
	if (/\bNOR32|NOR42\b/i) {		
		
		my @gateList = ($_ =~ m/(\w+)/g);				
		$gateName[0] = $gateList[1];			
		@gateList = ($gateList[0], @gateList[2..$#gateList]);		
				
		$i=0;		
		$DNOR[$i][0] = scalar @gateList - 2; #number of inputs.
		$DNOR[$i][1] = $gateList[0]; #output is stored here		
			
		foreach $k (2..scalar @gateList)
		{	$DNOR[$i][$k] = $gateList[$k];	}								
		
		if ($d == 1) {	
			print OUT "\n*N".$DNOR[$i][1]." = $gateList[1](";
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
		$i=1;
		
		# printing the nmos transistors		
		print OUT "M_dnor".$dnnor."_".($i)." N".$output." N".$DNOR[0][2]." GND $nmos1\n";
		print OUT "M_dnor".$dnnor."_".($i+1)." N".$output." N".$DNOR[0][2]." GND $nmos1\n";		
		
		print OUT "M_dnor".$dnnor."_".($i+2)." N".$output." N".$DNOR[0][3]." GND $nmos1\n";
		print OUT "M_dnor".$dnnor."_".($i+3)." N".$output." N".$DNOR[0][3]." GND $nmos1\n";
		$i+=4;
		
		$tran++;
		$tempArea += $WN1;
		print OUT_AREA "$tran $tempArea\n";			
		
		$tran++;
		$tempArea += $WN1;
		print OUT_AREA "$tran $tempArea\n";			
		
		$tran++;
		$tempArea += $WN1;
		print OUT_AREA "$tran $tempArea\n";			
		
		$tran++;
		$tempArea += $WN1;
		print OUT_AREA "$tran $tempArea\n";			
				
		foreach $kk (3..scalar @gateList - 2) {											
			print OUT "M_dnor".$dnnor."_".($i)." N".$output." N".$DNOR[0][$kk+1]." GND $nmos\n";	
			$i += 1;	

			$tran++;
			$tempArea += $WN;
			print OUT_AREA "$tran $tempArea\n";					
		}	

		if ($d == 1) {
			print OUT "\n";
		}		
		
		# printing the pmos transistors		
		foreach $kk (1..scalar @gateList - 2) {	
		
			if ($kk == 1) { #insert first transistor.
				print OUT "M_dnor".$dnnor."_".($i)." N".$output." N".$DNOR[0][$kk+1]." nrd".$dnnor."_".($j+1)." $pmos\n";									
				$j += 1;	
				$i += 1;
				
				$tran++;
				$tempArea += $WP;
				print OUT_AREA "$tran $tempArea\n";		
			}			
			else {
				if ($kk == scalar @gateList - 2) { #if last gate
					print OUT "M_dnor".$dnnor."_".($i)." nrd".$dnnor."_".($j)." N".$DNOR[0][$kk+1]." VDD $pmos\n";													
					$j += 1;												
					$i += 1;

					$tran++;
					$tempArea += $WP;
					print OUT_AREA "$tran $tempArea\n";							
				}
				else {
					print OUT "M_dnor".$dnnor."_".($i)." nrd".$dnnor."_".($j)." N".$DNOR[0][$kk+1]." nrd".$dnnor."_".($j+1)." $pmos\n";					
					$j += 1;															
					$i += 1;

					$tran++;
					$tempArea += $WP;
					print OUT_AREA "$tran $tempArea\n";		
				}			
			}				
		}						
		
		$dnnor++;	
		print OUT "\n";
		$area += 4*$WN1 + (scalar @gateList - 4)*$WN + (scalar @gateList - 2)*$WP;
	}
	
	
	# Matching NOR43 gates	
	if (/\bNOR43\b/i) {		
		
		my @gateList = ($_ =~ m/(\w+)/g);				
		$gateName[0] = $gateList[1];			
		@gateList = ($gateList[0], @gateList[2..$#gateList]);		
				
		$i=0;		
		$DNOR[$i][0] = scalar @gateList - 2; #number of inputs.
		$DNOR[$i][1] = $gateList[0]; #output is stored here		
			
		foreach $k (2..scalar @gateList)
		{	$DNOR[$i][$k] = $gateList[$k];	}								
		
		if ($d == 1) {	
			print OUT "\n*N".$DNOR[$i][1]." = $gateList[1](";
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
		$i=1;
		
		# printing the nmos transistors		
		print OUT "M_dnor".$dnnor."_".($i)." N".$output." N".$DNOR[0][2]." GND $nmos1\n";
		print OUT "M_dnor".$dnnor."_".($i+1)." N".$output." N".$DNOR[0][2]." GND $nmos1\n";		
		
		print OUT "M_dnor".$dnnor."_".($i+2)." N".$output." N".$DNOR[0][3]." GND $nmos1\n";
		print OUT "M_dnor".$dnnor."_".($i+3)." N".$output." N".$DNOR[0][3]." GND $nmos1\n";
		
		print OUT "M_dnor".$dnnor."_".($i+4)." N".$output." N".$DNOR[0][3]." GND $nmos1\n";
		print OUT "M_dnor".$dnnor."_".($i+5)." N".$output." N".$DNOR[0][3]." GND $nmos1\n";
		
		$i+=6;
		
		$tran++;
		$tempArea += $WN1;
		print OUT_AREA "$tran $tempArea\n";			
		
		$tran++;
		$tempArea += $WN1;
		print OUT_AREA "$tran $tempArea\n";			
		
		$tran++;
		$tempArea += $WN1;
		print OUT_AREA "$tran $tempArea\n";			
		
		$tran++;
		$tempArea += $WN1;
		print OUT_AREA "$tran $tempArea\n";			
		
		$tran++;
		$tempArea += $WN1;
		print OUT_AREA "$tran $tempArea\n";			
		
		$tran++;
		$tempArea += $WN1;
		print OUT_AREA "$tran $tempArea\n";			
				
		print OUT "M_dnor".$dnnor."_".($i)." N".$output." N".$DNOR[0][$kk+1]." GND $nmos\n";	
		$i += 1;	

		$tran++;
		$tempArea += $WN;
		print OUT_AREA "$tran $tempArea\n";					
		
		if ($d == 1) {
			print OUT "\n";
		}		
		
		# printing the pmos transistors		
		foreach $kk (1..scalar @gateList - 2) {	
		
			if ($kk == 1) { #insert first transistor.
				print OUT "M_dnor".$dnnor."_".($i)." N".$output." N".$DNOR[0][$kk+1]." nrd".$dnnor."_".($j+1)." $pmos\n";									
				$j += 1;	
				$i += 1;
				
				$tran++;
				$tempArea += $WP;
				print OUT_AREA "$tran $tempArea\n";		
			}			
			else {
				if ($kk == scalar @gateList - 2) { #if last gate
					print OUT "M_dnor".$dnnor."_".($i)." nrd".$dnnor."_".($j)." N".$DNOR[0][$kk+1]." VDD $pmos\n";													
					$j += 1;												
					$i += 1;

					$tran++;
					$tempArea += $WP;
					print OUT_AREA "$tran $tempArea\n";							
				}
				else {
					print OUT "M_dnor".$dnnor."_".($i)." nrd".$dnnor."_".($j)." N".$DNOR[0][$kk+1]." nrd".$dnnor."_".($j+1)." $pmos\n";					
					$j += 1;															
					$i += 1;

					$tran++;
					$tempArea += $WP;
					print OUT_AREA "$tran $tempArea\n";		
				}			
			}				
		}						
		
		$dnnor++;	
		print OUT "\n";
		$area += 6*$WN1 + $WN + (scalar @gateList - 2)*$WP;
	}

	
	# Matching NOR22, NOR33 or NOR44 gates	
	if (/\bNOR22|NOR33|NOR44\b/i) {		
		
		my @gateList = ($_ =~ m/(\w+)/g);				
		$gateName[0] = $gateList[1];			
		@gateList = ($gateList[0], @gateList[2..$#gateList]);		
				
		$i=0;		
		$DNOR[$i][0] = scalar @gateList - 2; #number of inputs.
		$DNOR[$i][1] = $gateList[0]; #output is stored here		
			
		foreach $k (2..scalar @gateList)
		{	$DNOR[$i][$k] = $gateList[$k];	}								
		
		if ($d == 1) {	
			print OUT "\n*N".$DNOR[$i][1]." = $gateList[1](";
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
		$i=1;
		
		# printing the nmos transistors		
		foreach $kk (1..scalar @gateList - 2) {											
			print OUT "M_dnor".$dnnor."_".($i)." N".$output." N".$DNOR[0][$kk+1]." GND $nmos1\n";			
			print OUT "M_dnor".$dnnor."_".($i+1)." N".$output." N".$DNOR[0][$kk+1]." GND $nmos1\n";	
			$i += 2;
				
			$tran++;
			$tempArea += $WN1;
			print OUT_AREA "$tran $tempArea\n";	
			
			$tran++;
			$tempArea += $WN1;
			print OUT_AREA "$tran $tempArea\n";	
		}	

		if ($d == 1) {
			print OUT "\n";
		}		
		
		# printing the pmos transistors		
		foreach $kk (1..scalar @gateList - 2) {	
		
			if ($kk == 1) { #insert first transistor.
				print OUT "M_dnor".$dnnor."_".($i)." N".$output." N".$DNOR[0][$kk+1]." nrd".$dnnor."_".($j+1)." $pmos\n";									
				$j += 1;	
				$i += 1;
				
				$tran++;
				$tempArea += $WP;
				print OUT_AREA "$tran $tempArea\n";
			}			
			else {
				if ($kk == scalar @gateList - 2) { #if last gate
					print OUT "M_dnor".$dnnor."_".($i)." nrd".$dnnor."_".($j)." N".$DNOR[0][$kk+1]." VDD $pmos\n";													
					$j += 1;												
					$i += 1;

					$tran++;
					$tempArea += $WP;
					print OUT_AREA "$tran $tempArea\n";
				}
				else {
					print OUT "M_dnor".$dnnor."_".($i)." nrd".$dnnor."_".($j)." N".$DNOR[0][$kk+1]." nrd".$dnnor."_".($j+1)." $pmos\n";					
					$j += 1;															
					$i += 1;	
					
					$tran++;
					$tempArea += $WP;
					print OUT_AREA "$tran $tempArea\n";
				}			
			}				
		}						
		
		$dnnor++;	
		print OUT "\n";
		$area += 2*(scalar @gateList - 2)*$WN1 + (scalar @gateList - 2)*$WP;
	}
	
	
	# Matching NOR24, NOR35, NOR46  gates	
	if (/\bNOR24|NOR35|NOR46\b/i) {		
		
		my @gateList = ($_ =~ m/(\w+)/g);				
		$gateName[0] = $gateList[1];			
		@gateList = ($gateList[0], @gateList[2..$#gateList]);		
		
		$i=0;		
		$DNOR[$i][0] = scalar @gateList - 2; #number of inputs.
		$DNOR[$i][1] = $gateList[0]; #output is stored here		
			
		foreach $k (2..scalar @gateList)
		{	$DNOR[$i][$k] = $gateList[$k];	}								
		
		if ($d == 1) {	
			print OUT "\n*N".$DNOR[$i][1]." = $gateList[1](";
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
		
		$currentPmos = ();
		$currentWP = ();
		if($DNOR[0][0] == 2) {
			$currentPmos = $pmos2;
			$currentWP = $WP2;
		}
		elsif($DNOR[0][0] == 3) {
			$currentPmos = $pmos6;
			$currentWP = $WP6;
		}
		elsif($DNOR[0][0] == 4) {
			$currentPmos = $pmos4;
			$currentWP = $WP4;
		}
		
		$j=0;
		$i=1;
		
		# printing the nmos transistors	
		print OUT "M_dnor".$dnnor."_".($i)." N".$output." N".$DNOR[0][2]." GND $nmos1\n";			
		print OUT "M_dnor".$dnnor."_".($i+1)." N".$output." N".$DNOR[0][2]." GND $nmos1\n";	
		$i += 2;
				
		$tran++;
		$tempArea += $WN1;
		print OUT_AREA "$tran $tempArea\n";	
			
		$tran++;
		$tempArea += $WN1;
		print OUT_AREA "$tran $tempArea\n";	
		
		$max = scalar @gateList - 2;		
		foreach $kk (2..$max) {											
			print OUT "M_dnor".$dnnor."_".($i)." N".$output." N".$DNOR[0][$kk+1]." GND $nmos\n";			
			$i += 1;	
			$tran++;
			$tempArea += $WN;
			print OUT_AREA "$tran $tempArea\n";				
		}	

		if ($d == 1) {
			print OUT "\n";
		}		
		
		# printing the pmos transistors		
		foreach $kk (1..scalar @gateList - 2) {	
		
			if ($kk == 1) { #insert first transistor.
				print OUT "M_dnor".$dnnor."_".($i)." N".$output." N".$DNOR[0][$kk+1]." nrd".$dnnor."_".($j+1)." $currentPmos\n";
				print OUT "M_dnor".$dnnor."_".($i+1)." N".$output." N".$DNOR[0][$kk+1]." nrd".$dnnor."_".($j+1)." $currentPmos\n";
				$j += 1;				
				$i += 2;
				
				$tran++;
				$tempArea += $currentWP;
				print OUT_AREA "$tran $tempArea\n";
			
				$tran++;
				$tempArea += $currentWP;
				print OUT_AREA "$tran $tempArea\n";
			}			
			else {
				if ($kk == scalar @gateList - 2) { #if last gate
					print OUT "M_dnor".$dnnor."_".($i)." nrd".$dnnor."_".($j)." N".$DNOR[0][$kk+1]." VDD $currentPmos\n";
					print OUT "M_dnor".$dnnor."_".($i+1)." nrd".$dnnor."_".($j)." N".$DNOR[0][$kk+1]." VDD $currentPmos\n";
					$j += 1;						
					$i += 2;
					
					$tran++;
					$tempArea += $currentWP;
					print OUT_AREA "$tran $tempArea\n";
			
					$tran++;
					$tempArea += $currentWP;
					print OUT_AREA "$tran $tempArea\n";
				}
				else {
					print OUT "M_dnor".$dnnor."_".($i)." nrd".$dnnor."_".($j)." N".$DNOR[0][$kk+1]." nrd".$dnnor."_".($j+1)." $currentPmos\n";
					print OUT "M_dnor".$dnnor."_".($i+1)." nrd".$dnnor."_".($j)." N".$DNOR[0][$kk+1]." nrd".$dnnor."_".($j+1)." $currentPmos\n";
					$j += 1;						
					$i += 2;
					
					$tran++;
					$tempArea += $currentWP;
					print OUT_AREA "$tran $tempArea\n";
					
					$tran++;
					$tempArea += $currentWP;
					print OUT_AREA "$tran $tempArea\n";		
				}			
			}				
		}						
		
		$dnnor++;	
		print OUT "\n";
		$area += 2*$WN1 + ($max-1)*$WN + 2*$max*$currentWP;			
	}
	
	
	# Matching NOR36, NOR47  gates	
	if (/\bNOR36|NOR47\b/i) {		
		
		my @gateList = ($_ =~ m/(\w+)/g);				
		$gateName[0] = $gateList[1];			
		@gateList = ($gateList[0], @gateList[2..$#gateList]);		
		
		$i=0;		
		$DNOR[$i][0] = scalar @gateList - 2; #number of inputs.
		$DNOR[$i][1] = $gateList[0]; #output is stored here		
			
		foreach $k (2..scalar @gateList)
		{	$DNOR[$i][$k] = $gateList[$k];	}								
		
		if ($d == 1) {	
			print OUT "\n*N".$DNOR[$i][1]." = $gateList[1](";
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
		
		$currentPmos = ();
		$currentWP = ();
		
		if($DNOR[0][0] == 3) {
			$currentPmos = $pmos6;
			$currentWP = $WP6;
		}
		elsif($DNOR[0][0] == 4) {
			$currentPmos = $pmos4;
			$currentWP = $WP4;
		}
		
		$j=0;
		$i=1;
		
		# printing the nmos transistors	
		print OUT "M_dnor".$dnnor."_".($i)." N".$output." N".$DNOR[0][2]." GND $nmos1\n";			
		print OUT "M_dnor".$dnnor."_".($i+1)." N".$output." N".$DNOR[0][2]." GND $nmos1\n";	
		$i += 2;
				
		$tran++;
		$tempArea += $WN1;
		print OUT_AREA "$tran $tempArea\n";	
			
		$tran++;
		$tempArea += $WN1;
		print OUT_AREA "$tran $tempArea\n";	
		
		print OUT "M_dnor".$dnnor."_".($i)." N".$output." N".$DNOR[0][3]." GND $nmos1\n";			
		print OUT "M_dnor".$dnnor."_".($i+1)." N".$output." N".$DNOR[0][3]." GND $nmos1\n";	
		$i += 2;
				
		$tran++;
		$tempArea += $WN1;
		print OUT_AREA "$tran $tempArea\n";	
			
		$tran++;
		$tempArea += $WN1;
		print OUT_AREA "$tran $tempArea\n";	
		
		$max = scalar @gateList - 2;		
		foreach $kk (3..$max) {											
			print OUT "M_dnor".$dnnor."_".($i)." N".$output." N".$DNOR[0][$kk+1]." GND $nmos\n";			
			$i += 1;	
			$tran++;
			$tempArea += $WN;
			print OUT_AREA "$tran $tempArea\n";				
		}	

		if ($d == 1) {
			print OUT "\n";
		}		
		
		# printing the pmos transistors		
		foreach $kk (1..scalar @gateList - 2) {	
		
			if ($kk == 1) { #insert first transistor.
				print OUT "M_dnor".$dnnor."_".($i)." N".$output." N".$DNOR[0][$kk+1]." nrd".$dnnor."_".($j+1)." $currentPmos\n";
				print OUT "M_dnor".$dnnor."_".($i+1)." N".$output." N".$DNOR[0][$kk+1]." nrd".$dnnor."_".($j+1)." $currentPmos\n";
				$j += 1;				
				$i += 2;
				
				$tran++;
				$tempArea += $currentWP;
				print OUT_AREA "$tran $tempArea\n";
			
				$tran++;
				$tempArea += $currentWP;
				print OUT_AREA "$tran $tempArea\n";
			}			
			else {
				if ($kk == scalar @gateList - 2) { #if last gate
					print OUT "M_dnor".$dnnor."_".($i)." nrd".$dnnor."_".($j)." N".$DNOR[0][$kk+1]." VDD $currentPmos\n";
					print OUT "M_dnor".$dnnor."_".($i+1)." nrd".$dnnor."_".($j)." N".$DNOR[0][$kk+1]." VDD $currentPmos\n";
					$j += 1;						
					$i += 2;
					
					$tran++;
					$tempArea += $currentWP;
					print OUT_AREA "$tran $tempArea\n";
			
					$tran++;
					$tempArea += $currentWP;
					print OUT_AREA "$tran $tempArea\n";
				}
				else {
					print OUT "M_dnor".$dnnor."_".($i)." nrd".$dnnor."_".($j)." N".$DNOR[0][$kk+1]." nrd".$dnnor."_".($j+1)." $currentPmos\n";
					print OUT "M_dnor".$dnnor."_".($i+1)." nrd".$dnnor."_".($j)." N".$DNOR[0][$kk+1]." nrd".$dnnor."_".($j+1)." $currentPmos\n";
					$j += 1;						
					$i += 2;
					
					$tran++;
					$tempArea += $currentWP;
					print OUT_AREA "$tran $tempArea\n";
					
					$tran++;
					$tempArea += $currentWP;
					print OUT_AREA "$tran $tempArea\n";		
				}			
			}				
		}						
		
		$dnnor++;	
		print OUT "\n";
		$area += 4*$WN1 + ($max-2)*$WN + 2*$max*$currentWP;			
	}
	
	
	# Matching NOR48  gates	
	if (/\bNOR48\b/i) {		
		
		my @gateList = ($_ =~ m/(\w+)/g);				
		$gateName[0] = $gateList[1];			
		@gateList = ($gateList[0], @gateList[2..$#gateList]);		
		
		$i=0;		
		$DNOR[$i][0] = scalar @gateList - 2; #number of inputs.
		$DNOR[$i][1] = $gateList[0]; #output is stored here		
			
		foreach $k (2..scalar @gateList)
		{	$DNOR[$i][$k] = $gateList[$k];	}								
		
		if ($d == 1) {	
			print OUT "\n*N".$DNOR[$i][1]." = $gateList[1](";
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
		
		$currentPmos = ();
		$currentWP = ();
		if($DNOR[0][0] == 2) {
			$currentPmos = $pmos5;
			$currentWP = $WP5;
		}
		elsif($DNOR[0][0] == 3) {
			$currentPmos = $pmos6;
			$currentWP = $WP6;
		}
		elsif($DNOR[0][0] == 4) {
			$currentPmos = $pmos4;
			$currentWP = $WP4;
		}
		
		$j=0;
		$i=1;
		
		# printing the nmos transistors	
		print OUT "M_dnor".$dnnor."_".($i)." N".$output." N".$DNOR[0][2]." GND $nmos1\n";			
		print OUT "M_dnor".$dnnor."_".($i+1)." N".$output." N".$DNOR[0][2]." GND $nmos1\n";	
		$i += 2;
				
		$tran++;
		$tempArea += $WN1;
		print OUT_AREA "$tran $tempArea\n";	
			
		$tran++;
		$tempArea += $WN1;
		print OUT_AREA "$tran $tempArea\n";	
		
		print OUT "M_dnor".$dnnor."_".($i)." N".$output." N".$DNOR[0][3]." GND $nmos1\n";			
		print OUT "M_dnor".$dnnor."_".($i+1)." N".$output." N".$DNOR[0][3]." GND $nmos1\n";	
		$i += 2;
				
		$tran++;
		$tempArea += $WN1;
		print OUT_AREA "$tran $tempArea\n";	
			
		$tran++;
		$tempArea += $WN1;
		print OUT_AREA "$tran $tempArea\n";

		print OUT "M_dnor".$dnnor."_".($i)." N".$output." N".$DNOR[0][4]." GND $nmos1\n";			
		print OUT "M_dnor".$dnnor."_".($i+1)." N".$output." N".$DNOR[0][4]." GND $nmos1\n";	
		$i += 2;
				
		$tran++;
		$tempArea += $WN1;
		print OUT_AREA "$tran $tempArea\n";	
			
		$tran++;
		$tempArea += $WN1;
		print OUT_AREA "$tran $tempArea\n";		
		
		$max = scalar @gateList - 2;		
		foreach $kk (4..$max) {											
			print OUT "M_dnor".$dnnor."_".($i)." N".$output." N".$DNOR[0][$kk+1]." GND $nmos\n";			
			$i += 1;	
			$tran++;
			$tempArea += $WN;
			print OUT_AREA "$tran $tempArea\n";				
		}	

		if ($d == 1) {
			print OUT "\n";
		}		
		
		# printing the pmos transistors		
		foreach $kk (1..scalar @gateList - 2) {	
		
			if ($kk == 1) { #insert first transistor.
				print OUT "M_dnor".$dnnor."_".($i)." N".$output." N".$DNOR[0][$kk+1]." nrd".$dnnor."_".($j+1)." $currentPmos\n";
				print OUT "M_dnor".$dnnor."_".($i+1)." N".$output." N".$DNOR[0][$kk+1]." nrd".$dnnor."_".($j+1)." $currentPmos\n";
				$j += 1;				
				$i += 2;
				
				$tran++;
				$tempArea += $currentWP;
				print OUT_AREA "$tran $tempArea\n";
			
				$tran++;
				$tempArea += $currentWP;
				print OUT_AREA "$tran $tempArea\n";
			}			
			else {
				if ($kk == scalar @gateList - 2) { #if last gate
					print OUT "M_dnor".$dnnor."_".($i)." nrd".$dnnor."_".($j)." N".$DNOR[0][$kk+1]." VDD $currentPmos\n";
					print OUT "M_dnor".$dnnor."_".($i+1)." nrd".$dnnor."_".($j)." N".$DNOR[0][$kk+1]." VDD $currentPmos\n";
					$j += 1;						
					$i += 2;
					
					$tran++;
					$tempArea += $currentWP;
					print OUT_AREA "$tran $tempArea\n";
			
					$tran++;
					$tempArea += $currentWP;
					print OUT_AREA "$tran $tempArea\n";
				}
				else {
					print OUT "M_dnor".$dnnor."_".($i)." nrd".$dnnor."_".($j)." N".$DNOR[0][$kk+1]." nrd".$dnnor."_".($j+1)." $currentPmos\n";
					print OUT "M_dnor".$dnnor."_".($i+1)." nrd".$dnnor."_".($j)." N".$DNOR[0][$kk+1]." nrd".$dnnor."_".($j+1)." $currentPmos\n";
					$j += 1;						
					$i += 2;
					
					$tran++;
					$tempArea += $currentWP;
					print OUT_AREA "$tran $tempArea\n";
					
					$tran++;
					$tempArea += $currentWP;
					print OUT_AREA "$tran $tempArea\n";		
				}			
			}				
		}						
		
		$dnnor++;	
		print OUT "\n";
		$area += 6*$WN1 + ($max-3)*$WN + 2*$max*$currentWP;			
	}
	
	
	# Matching NOR23 gates	
	if (/\bNOR23\b/i) {		
		
		my @gateList = ($_ =~ m/(\w+)/g);				
		$gateName[0] = $gateList[1];			
		@gateList = ($gateList[0], @gateList[2..$#gateList]);		
				
		$i=0;		
		$DNOR[$i][0] = scalar @gateList - 2; #number of inputs.
		$DNOR[$i][1] = $gateList[0]; #output is stored here		
			
		foreach $k (2..scalar @gateList)
		{	$DNOR[$i][$k] = $gateList[$k];	}								
		
		if ($d == 1) {	
			print OUT "\n*N".$DNOR[$i][1]." = $gateList[1](";
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
		$i=1;
		
		# printing the nmos transistors		
		foreach $kk (1..scalar @gateList - 2) {											
			print OUT "M_dnor".$dnnor."_".($i)." N".$output." N".$DNOR[0][$kk+1]." GND $nmos\n";				
			$i += 1;	

			$tran++;
			$tempArea += $WN;
			print OUT_AREA "$tran $tempArea\n";					
		}	

		if ($d == 1) {
			print OUT "\n";
		}		
		
		# printing the pmos transistors		
		foreach $kk (1..scalar @gateList - 2) {	
		
			if ($kk == 1) { #insert first transistor.
				print OUT "M_dnor".$dnnor."_".($i)." N".$output." N".$DNOR[0][$kk+1]." nrd".$dnnor."_".($j+1)." $pmos2\n";
				print OUT "M_dnor".$dnnor."_".($i+1)." N".$output." N".$DNOR[0][$kk+1]." nrd".$dnnor."_".($j+1)." $pmos2\n";
				$j += 1;				
				$i += 2;
				
				$tran++;
				$tempArea += $WP2;
				print OUT_AREA "$tran $tempArea\n";
			
				$tran++;
				$tempArea += $WP2;
				print OUT_AREA "$tran $tempArea\n";
			}			
			else {
				if ($kk == scalar @gateList - 2) { #if last gate
					print OUT "M_dnor".$dnnor."_".($i)." nrd".$dnnor."_".($j)." N".$DNOR[0][$kk+1]." VDD $pmos2\n";
					print OUT "M_dnor".$dnnor."_".($i+1)." nrd".$dnnor."_".($j)." N".$DNOR[0][$kk+1]." VDD $pmos2\n";
					$j += 1;						
					$i += 2;
					
					$tran++;
					$tempArea += $WP2;
					print OUT_AREA "$tran $tempArea\n";
			
					$tran++;
					$tempArea += $WP2;
					print OUT_AREA "$tran $tempArea\n";
				}
				else {
					print OUT "M_dnor".$dnnor."_".($i)." nrd".$dnnor."_".($j)." N".$DNOR[0][$kk+1]." nrd".$dnnor."_".($j+1)." $pmos2\n";
					print OUT "M_dnor".$dnnor."_".($i+1)." nrd".$dnnor."_".($j)." N".$DNOR[0][$kk+1]." nrd".$dnnor."_".($j+1)." $pmos2\n";
					$j += 1;						
					$i += 2;
					
					$tran++;
					$tempArea += $WP2;
					print OUT_AREA "$tran $tempArea\n";
					
					$tran++;
					$tempArea += $WP2;
					print OUT_AREA "$tran $tempArea\n";		
				}			
			}				
		}						
		
		$dnnor++;	
		print OUT "\n";
		$area += (scalar @gateList - 2)*$WN + 2*(scalar @gateList - 2)*$WP2;
	}
	
	
	# Matching NOR34 gates	
	if (/\bNOR34\b/i) {		
		
		my @gateList = ($_ =~ m/(\w+)/g);				
		$gateName[0] = $gateList[1];			
		@gateList = ($gateList[0], @gateList[2..$#gateList]);		
				
		$i=0;		
		$DNOR[$i][0] = scalar @gateList - 2; #number of inputs.
		$DNOR[$i][1] = $gateList[0]; #output is stored here		
			
		foreach $k (2..scalar @gateList)
		{	$DNOR[$i][$k] = $gateList[$k];	}								
		
		if ($d == 1) {	
			print OUT "\n*N".$DNOR[$i][1]." = $gateList[1](";
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
		$i=1;
		
		# printing the nmos transistors		
		foreach $kk (1..scalar @gateList - 2) {											
			print OUT "M_dnor".$dnnor."_".($i)." N".$output." N".$DNOR[0][$kk+1]." GND $nmos\n";				
			$i += 1;	

			$tran++;
			$tempArea += $WN;
			print OUT_AREA "$tran $tempArea\n";					
		}	

		if ($d == 1) {
			print OUT "\n";
		}		
		
		# printing the pmos transistors		
		foreach $kk (1..scalar @gateList - 2) {	
		
			if ($kk == 1) { #insert first transistor.
				print OUT "M_dnor".$dnnor."_".($i)." N".$output." N".$DNOR[0][$kk+1]." nrd".$dnnor."_".($j+1)." $pmos3\n";
				print OUT "M_dnor".$dnnor."_".($i+1)." N".$output." N".$DNOR[0][$kk+1]." nrd".$dnnor."_".($j+1)." $pmos3\n";
				$j += 1;				
				$i += 2;
				
				$tran++;
				$tempArea += $WP3;
				print OUT_AREA "$tran $tempArea\n";
			
				$tran++;
				$tempArea += $WP3;
				print OUT_AREA "$tran $tempArea\n";
			}			
			else {
				if ($kk == scalar @gateList - 2) { #if last gate
					print OUT "M_dnor".$dnnor."_".($i)." nrd".$dnnor."_".($j)." N".$DNOR[0][$kk+1]." VDD $pmos3\n";
					print OUT "M_dnor".$dnnor."_".($i+1)." nrd".$dnnor."_".($j)." N".$DNOR[0][$kk+1]." VDD $pmos3\n";
					$j += 1;						
					$i += 2;
					
					$tran++;
					$tempArea += $WP3;
					print OUT_AREA "$tran $tempArea\n";
			
					$tran++;
					$tempArea += $WP3;
					print OUT_AREA "$tran $tempArea\n";
				}
				else {
					print OUT "M_dnor".$dnnor."_".($i)." nrd".$dnnor."_".($j)." N".$DNOR[0][$kk+1]." nrd".$dnnor."_".($j+1)." $pmos3\n";
					print OUT "M_dnor".$dnnor."_".($i+1)." nrd".$dnnor."_".($j)." N".$DNOR[0][$kk+1]." nrd".$dnnor."_".($j+1)." $pmos3\n";
					$j += 1;						
					$i += 2;
					
					$tran++;
					$tempArea += $WP3;
					print OUT_AREA "$tran $tempArea\n";
					
					$tran++;
					$tempArea += $WP3;
					print OUT_AREA "$tran $tempArea\n";		
				}			
			}				
		}						
		
		$dnnor++;	
		print OUT "\n";
		$area += (scalar @gateList - 2)*$WN + 2*(scalar @gateList - 2)*$WP3;
	}
	
		
	# Matching NOR45 gates	
	if (/\bNOR45\b/i) {		
		
		my @gateList = ($_ =~ m/(\w+)/g);				
		$gateName[0] = $gateList[1];			
		@gateList = ($gateList[0], @gateList[2..$#gateList]);		
				
		$i=0;		
		$DNOR[$i][0] = scalar @gateList - 2; #number of inputs.
		$DNOR[$i][1] = $gateList[0]; #output is stored here		
			
		foreach $k (2..scalar @gateList)
		{	$DNOR[$i][$k] = $gateList[$k];	}								
		
		if ($d == 1) {	
			print OUT "\n*N".$DNOR[$i][1]." = $gateList[1](";
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
		$i=1;
		
		# printing the nmos transistors		
		foreach $kk (1..scalar @gateList - 2) {											
			print OUT "M_dnor".$dnnor."_".($i)." N".$output." N".$DNOR[0][$kk+1]." GND $nmos\n";				
			$i += 1;	

			$tran++;
			$tempArea += $WN;
			print OUT_AREA "$tran $tempArea\n";					
		}	

		if ($d == 1) {
			print OUT "\n";
		}		
		
		# printing the pmos transistors		
		foreach $kk (1..scalar @gateList - 2) {	
		
			if ($kk == 1) { #insert first transistor.
				print OUT "M_dnor".$dnnor."_".($i)." N".$output." N".$DNOR[0][$kk+1]." nrd".$dnnor."_".($j+1)." $pmos4\n";
				print OUT "M_dnor".$dnnor."_".($i+1)." N".$output." N".$DNOR[0][$kk+1]." nrd".$dnnor."_".($j+1)." $pmos4\n";
				$j += 1;				
				$i += 2;
				
				$tran++;
				$tempArea += $WP4;
				print OUT_AREA "$tran $tempArea\n";
			
				$tran++;
				$tempArea += $WP4;
				print OUT_AREA "$tran $tempArea\n";
			}			
			else {
				if ($kk == scalar @gateList - 2) { #if last gate
					print OUT "M_dnor".$dnnor."_".($i)." nrd".$dnnor."_".($j)." N".$DNOR[0][$kk+1]." VDD $pmos4\n";
					print OUT "M_dnor".$dnnor."_".($i+1)." nrd".$dnnor."_".($j)." N".$DNOR[0][$kk+1]." VDD $pmos4\n";
					$j += 1;						
					$i += 2;
					
					$tran++;
					$tempArea += $WP4;
					print OUT_AREA "$tran $tempArea\n";
			
					$tran++;
					$tempArea += $WP4;
					print OUT_AREA "$tran $tempArea\n";
				}
				else {
					print OUT "M_dnor".$dnnor."_".($i)." nrd".$dnnor."_".($j)." N".$DNOR[0][$kk+1]." nrd".$dnnor."_".($j+1)." $pmos4\n";
					print OUT "M_dnor".$dnnor."_".($i+1)." nrd".$dnnor."_".($j)." N".$DNOR[0][$kk+1]." nrd".$dnnor."_".($j+1)." $pmos4\n";
					$j += 1;						
					$i += 2;
					
					$tran++;
					$tempArea += $WP4;
					print OUT_AREA "$tran $tempArea\n";
					
					$tran++;
					$tempArea += $WP4;
					print OUT_AREA "$tran $tempArea\n";		
				}			
			}				
		}						
		
		$dnnor++;	
		print OUT "\n";
		$area += (scalar @gateList - 2)*$WN + 2*(scalar @gateList - 2)*$WP4;
	}
	
			
	# Matching DNOT gates	
    if (/(.*) = DNOT\((.*)\)/) {
	
		my @gateList = ($_ =~ m/(\w+)/g);				
		$gateName[0] = $gateList[1];			
		@gateList = ($gateList[0], @gateList[2..$#gateList]);		
		
		# my @allGates = ($_ =~ m/\((\w.*)\)/ig);  	#Read all Gates including 's' and 'p' keywords							
		# print "Gate List = @gateList  size = ",scalar @gateList,"\n All Gates = @allGates \n Gate Name = $gateName[0]\n";				
		# push (@connectionPattern_QNOT, [ split(m/,\s|,/, $allGates[0]) ]);					
				
		$i=0;
		$QINV[$i][0] = $gateList[0]; #output is stored here						
		$QINV[$i][1] = $gateList[1]; #input is stored here						
				
		# my $conpat = shift(@connectionPattern_QNOT);		
		if ($d == 1) {	
			print OUT "\n*N".$QINV[$i][0]." = DNOT( N".$QINV[$i][1]." ) \n";
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
		print OUT "M_qnot".$qninv."_1 N".$output." N".$QNOT_nmos[$j+2]." GND $nmos1\n";
		print OUT "M_qnot".$qninv."_2 N".$output." N".$QNOT_nmos[$j+3]." GND $nmos1\n";
		
		$tran++;
		$tempArea += $WN1;
		print OUT_AREA "$tran $tempArea\n";
					
		$tran++;
		$tempArea += $WN1;
		print OUT_AREA "$tran $tempArea\n";		
		
		if ($d == 1) {
			print OUT "\n";
		}

		#pmos transistors		
		print OUT "M_qnot".$qninv."_3 N".$output." N".$QNOT_pmos[$j+3]." VDD $pmos1\n";
		print OUT "M_qnot".$qninv."_4 N".$output." N".$QNOT_pmos[$j+3]." VDD $pmos1\n";		
		
		$tran++;
		$tempArea += $WP1;
		print OUT_AREA "$tran $tempArea\n";
					
		$tran++;
		$tempArea += $WP1;
		print OUT_AREA "$tran $tempArea\n";		
		
		if ($d == 1) {
			print OUT "\n";
		}
		$qninv++;
		$area += 2*$WN1 + 2*$WP1;		
	}

	
	# Matching DNAND gates	
	if (/\bDNAND\b/i) {		
		
		my @gateList = ($_ =~ m/(\w+)/g);				
		$gateName[0] = $gateList[1];			
		@gateList = ($gateList[0], @gateList[2..$#gateList]);		
		
		# my @allGates = ($_ =~ m/\((\w.*)\)/ig);  	#Read all Gates including 's' and 'p' keywords							
		# push (@connectionPattern_QNAND, [ split(m/,\s|,/, $allGates[0]) ]);					
		
		$i=0;
		$QNAND[$i][0] = scalar @gateList - 1; #number of inputs.
		$QNAND[$qi][1] = $gateList[0]; #output is stored here		
			
		foreach $k (2..scalar @gateList)
		{	$QNAND[$i][$k] = $gateList[$k-1];	}	
		
		my $conpat = shift(@connectionPattern_QNAND);
		
		if ($d == 1) {	
			print OUT "\n*N".$QNAND[$i][1]." = DNAND( ";
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
			
			$QNAND_pmos[$parallel]		=   @$conpat[$kk]; 
			$QNAND_pmos[$parallel+1]	=  	@$conpat[$kk]; 			
			
			$series += 2;	
			$parallel += 2;				
		}	
		#--------------------------------------------
		$i=0;
		$output = $QNAND[$i][1];
		
		$currentNmos = ();
		$currentWN = ();
		if($QNAND[0][0] == 2) {
			$currentNmos = $nmos5;
			$currentWN = $WN5;
		}
		elsif($QNAND[0][0] == 3) {
			$currentNmos = $nmos6;
			$currentWN = $WN6;
		}
		elsif($QNAND[0][0] == 4) {
			$currentNmos = $nmos7;
			$currentWN = $WN7;
		}
		
		# printing the nmos transistors		
		$j=0;
		$i=1;
		print OUT "M_qnand".$qnnand."_".($i)." N".$output." N".$QNAND_nmos[$j]." ndq".$qnnand."_".($j+1)." $currentNmos\n";					
		print OUT "M_qnand".$qnnand."_".($i+1)." N".$output." N".$QNAND_nmos[$j]." ndq".$qnnand."_".($j+1)." $currentNmos\n";					
		$i += 2;
		
		$tran++;
		$tempArea += $currentWN;
		print OUT_AREA "$tran $tempArea\n";
					
		$tran++;
		$tempArea += $currentWN;
		print OUT_AREA "$tran $tempArea\n";		

		$l=1;	
		for ($j=2; $j < scalar @QNAND_nmos - 2 - 1; $j+=2){
			print OUT "M_qnand".$qnnand."_".($i)." ndq".$qnnand."_".($l)." N".$QNAND_nmos[$j]." ndq".$qnnand."_".($l+1)." $currentNmos\n";					
			print OUT "M_qnand".$qnnand."_".($i+1)." ndq".$qnnand."_".($l)." N".$QNAND_nmos[$j+1]." ndq".$qnnand."_".($l+1)." $currentNmos\n";							
			$l += 1;
			$i += 2;
			
			$tran++;
			$tempArea += $currentWN;
			print OUT_AREA "$tran $tempArea\n";
					
			$tran++;
			$tempArea += $currentWN;
			print OUT_AREA "$tran $tempArea\n";		
		}
		
		$j = scalar @QNAND_nmos - 2;				
		#$l = $j<<1;		
		print OUT "M_qnand".$qnnand."_".($i)." ndq".$qnnand."_".($l)." N".$QNAND_nmos[$j]." GND $currentNmos\n";					
		print OUT "M_qnand".$qnnand."_".($i+1)." ndq".$qnnand."_".($l)." N".$QNAND_nmos[$j]." GND $currentNmos\n";					
		$i += 2;
		
		$tran++;
		$tempArea += $currentWN;
		print OUT_AREA "$tran $tempArea\n";
					
		$tran++;
		$tempArea += $currentWN;
		print OUT_AREA "$tran $tempArea\n";		
		
		if ($d == 1) {
			print OUT "\n";
		}

		# printing the pmos transistors
		$ind = 0;
		for ($k=0; $k < scalar @QNAND_pmos/2; $k++){
			print OUT "M_qnand".$qnnand."_".($i)." N".$output." N".$QNAND_pmos[$k+$ind]." VDD $pmos1\n";					
			print OUT "M_qnand".$qnnand."_".($i+1)." N".$output." N".$QNAND_pmos[$k+$ind+1]." VDD $pmos1\n";								
			$ind += 1; 
			$i += 2;

			$tran++;
			$tempArea += $WP1;
			print OUT_AREA "$tran $tempArea\n";
					
			$tran++;
			$tempArea += $WP1;
			print OUT_AREA "$tran $tempArea\n";		
		}	
		
		$qnnand++;
		if ($d == 1) {
				print OUT "\n";
		}
		$area += 2*(scalar @gateList - 1)*$currentWN + 2*(scalar @gateList - 1)*$WP1;
	}
		
		
	# Matching DNOR gates		
	if (/\bDNOR\b/i) {				
		
		my @gateList = ($_ =~ m/(\w+)/g);				
		$gateName[0] = $gateList[1];			
		@gateList = ($gateList[0], @gateList[2..$#gateList]);		
		
		# my @allGates = ($_ =~ m/\((\w.*)\)/ig);  	#Read all Gates including 's' and 'p' keywords				
		# print "GL = @gateList\n";				
		# push (@connectionPattern_QNOR, [ split(m/,\s|,/, $allGates[0]) ]);				
		
		$i=0;
		$QNOR[$i][0] = scalar @gateList - 1; #number of inputs.
		$QNOR[$i][1] = $gateList[0]; #output is stored here		
			
		foreach $k (2..scalar @gateList)
		{	$QNOR[$i][$k] = $gateList[$k-1];	}	
		
		my $conpat = shift(@connectionPattern_QNOR);
		
		if ($d == 1) {	
			print OUT "\n*N".$QNOR[$i][1]." = DNOR( ";
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
				
			$QNOR_nmos[$parallel]	=   @$conpat[$kk]; 
			$QNOR_nmos[$parallel+1]	=  	@$conpat[$kk]; 			
			
			$series += 2;	
			$parallel += 2;				
		}	
		#--------------------------------------------
		
		$i=1;
		$output = $QNOR[0][1];
		
		$currentPmos = ();
		$currentWP = ();
		if($QNOR[0][0] == 2) {
			$currentPmos = $pmos5;
			$currentWP = $WP5;
		}
		elsif($QNOR[0][0] == 3) {
			$currentPmos = $pmos6;
			$currentWP = $WP6;
		}
		elsif($QNOR[0][0] == 4) {
			$currentPmos = $pmos7;
			$currentWP = $WP7;
		}
		
		# printing the nmos transistors				
		$ind = 0;
		for ($k=0; $k < scalar @QNOR_nmos/2; $k++){
			print OUT "M_qnnor".$qnnor."_".($i)." N".$output." N".$QNOR_nmos[$k+$ind]." GND $nmos1\n";								
			print OUT "M_qnnor".$qnnor."_".($i+1)." N".$output." N".$QNOR_nmos[$k+$ind+1]." GND $nmos1\n";								
			$ind += 1;
			$i += 2;

			$tran++;
			$tempArea += $WN1;
			print OUT_AREA "$tran $tempArea\n";			
			
			$tran++;
			$tempArea += $WN1;
			print OUT_AREA "$tran $tempArea\n";			
		}	
		if ($d == 1) {
			print OUT "\n";
		}
		
		$j=0;
		# printing the pmos transistors	
		print OUT "M_qnnor".$qnnor."_".($i)." N".$output." N".$QNOR_pmos[$j]." nrq".$qnnor."_".($j+1)." $currentPmos\n";				
		print OUT "M_qnnor".$qnnor."_".($i+1)." N".$output." N".$QNOR_pmos[$j]." nrq".$qnnor."_".($j+1)." $currentPmos\n";		
		$i += 2;	

		$tran++;
		$tempArea += $currentWP;
		print OUT_AREA "$tran $tempArea\n";
					
		$tran++;
		$tempArea += $currentWP;
		print OUT_AREA "$tran $tempArea\n";				
		
		$l=1;	
		for ($j=2; $j < scalar @QNOR_pmos - 2 - 1; $j+=2){
			print OUT "M_qnnor".$qnnor."_".($i)." nrq".$qnnor."_".($l)." N".$QNOR_pmos[$j]." nrq".$qnnor."_".($l+1)." $currentPmos\n";				
			print OUT "M_qnnor".$qnnor."_".($i+1)." nrq".$qnnor."_".($l)." N".$QNOR_pmos[$j]." nrq".$qnnor."_".($l+1)." $currentPmos\n";	
			$l += 1;
			$i += 2;
			
			$tran++;
			$tempArea += $currentWP;
			print OUT_AREA "$tran $tempArea\n";
					
			$tran++;
			$tempArea += $currentWP;
			print OUT_AREA "$tran $tempArea\n";		
		}
		
		$j = scalar @QNOR_pmos - 2;				
		print OUT "M_qnnor".$qnnor."_".($i)." nrq".$qnnor."_".($l)." N".$QNOR_pmos[$j]." VDD $currentPmos\n";						
		print OUT "M_qnnor".$qnnor."_".($i+1)." nrq".$qnnor."_".($l)." N".$QNOR_pmos[$j]." VDD $currentPmos\n";
		$i += 2;
		
		$tran++;
		$tempArea += $currentWP;
		print OUT_AREA "$tran $tempArea\n";
					
		$tran++;
		$tempArea += $currentWP;
		print OUT_AREA "$tran $tempArea\n";		
				
		if ($d == 1) {
			print OUT "\n";
		}

		$qnnor++;	
		if ($d == 1) {
			print OUT "\n";
		}	
		$area += 2*(scalar @gateList - 1)*$WN1 + 2*(scalar @gateList - 1)*$currentWP;		
	}  

	
	#Matching Guard Gates (GG) or C-Element.
	if (/\bOR\b/i) {	
		
		my @gateList = ($_ =~ m/(\w+)/g);				
		$gateName[0] = $gateList[1];			
		@gateList = ($gateList[0], @gateList[2..$#gateList]);		
		
		$i = 0;
		$GG[$i][0] = scalar @gateList - 1; #number of inputs.
		$GG[$i][1] = $gateList[0]; #output is stored here		
				
		foreach $k (2..scalar @gateList)
		{	$GG[$i][$k] = $gateList[$k-1];	}			                  				
				
		print OUT2 "N".$GG[$i][1]."\n";
		if ($d == 1) {	
		print OUT "\n* N".$GG[$i][1]." = GG( ";
			for ($j=0; $j < $GG[$i][0] ; $j++){
				if ($j == $GG[$i][0]-1){
					print OUT "N".$GG[$i][2+$j]." ) \n";
				} else {
					print OUT "N".$GG[$i][2+$j].", ";
				}
			}
		}
				
		# printing the nmos transistors
		$i=0;
		$j=0;
		
		#C-Element NMOS part
		print OUT "M_N1C$gg ngg".$gg."_".($j+1)." N".$GG[$i][$j+2]." GND $nmos\n";
		$tran++;
		$tempArea += $WN;
		print OUT_AREA "$tran $tempArea\n";
		print OUT "M_N2C$gg c".$gg."_out N".$GG[$i][$j+3]." ngg".$gg."_".($j+1)." $nmos\n";		
		$tran++;
		$tempArea += $WN;
		print OUT_AREA "$tran $tempArea\n";
		print OUT "M_N3C$gg ngg".$gg."_".($j+1)." N".$GG[$i][1]." ngg".$gg."_".($j+2)." $nmos\n";		
		$tran++;
		$tempArea += $WN;
		print OUT_AREA "$tran $tempArea\n";
		print OUT "M_N4C$gg ngg".$gg."_".($j+2)." N".$GG[$i][$j+3]." GND $nmos\n";
		$tran++;
		$tempArea += $WN;
		print OUT_AREA "$tran $tempArea\n";
		print OUT "M_N5C$gg c".$gg."_out N".$GG[$i][$j+2]." ngg".$gg."_".($j+2)." $nmos\n";
		$tran++;
		$tempArea += $WN;
		print OUT_AREA "$tran $tempArea\n";
		
		
		
		print OUT "\n";
		
		#C-Element PMOS part		
		print OUT "M_P1C$gg ngg".$gg."_".($j+3)." N".$GG[$i][$j+2]." VDD $pmos\n";
		$tran++;
		$tempArea += $WP;
		print OUT_AREA "$tran $tempArea\n";
		print OUT "M_P2C$gg c".$gg."_out N".$GG[$i][$j+3]." ngg".$gg."_".($j+3)." $pmos\n";		
		$tran++;
		$tempArea += $WP;
		print OUT_AREA "$tran $tempArea\n";
		print OUT "M_P3C$gg ngg".$gg."_".($j+3)." N".$GG[$i][1]." ngg".$gg."_".($j+4)." $pmos\n";		
		$tran++;
		$tempArea += $WP;
		print OUT_AREA "$tran $tempArea\n";
		print OUT "M_P4C$gg ngg".$gg."_".($j+4)." N".$GG[$i][$j+3]." VDD $pmos\n";
		$tran++;
		$tempArea += $WP;
		print OUT_AREA "$tran $tempArea\n";
		print OUT "M_P5C$gg c".$gg."_out N".$GG[$i][$j+2]." ngg".$gg."_".($j+4)." $pmos\n";
		$tran++;
		$tempArea += $WP;
		print OUT_AREA "$tran $tempArea\n";
		
		print OUT "\n";
								
		# # Generating the inverter		
		print OUT "M_N6C$gg N".$GG[$i][1]." c".$gg."_out GND $nmos\n";		
		$tran++;
		$tempArea += $WN;
		print OUT_AREA "$tran $tempArea\n";
		print OUT "M_P6C$gg N".$GG[$i][1]." c".$gg."_out VDD $pmos\n\n";	
		$tran++;
		$tempArea += $WP;
		print OUT_AREA "$tran $tempArea\n";		
		
		$gg++;
		
		$area += 1.62;
	}
	
		
	#Matching Fully Protected Guard Gates (DGG) or C-Element.
	if (/\bDOR\b/i) {	
		
		my @gateList = ($_ =~ m/(\w+)/g);				
		$gateName[0] = $gateList[1];			
		@gateList = ($gateList[0], @gateList[2..$#gateList]);		
		
		$i = 0;
		$DGG[$i][0] = scalar @gateList - 1; #number of inputs.
		$DGG[$i][1] = $gateList[0]; #output is stored here		
				
		foreach $k (2..scalar @gateList)
		{	$DGG[$i][$k] = $gateList[$k-1];	}			                  				
				
		print OUT2 "N".$DGG[$i][1]."\n";
		if ($d == 1) {	
		print OUT "\n* N".$DGG[$i][1]." = DGG( ";
			for ($j=0; $j < $DGG[$i][0] ; $j++){
				if ($j == $DGG[$i][0]-1){
					print OUT "N".$DGG[$i][2+$j]." ) \n";
				} else {
					print OUT "N".$DGG[$i][2+$j].", ";
				}
			}
		}
				
		# printing the nmos transistors
		$i=0;
		$j=0;
		
		#C-Element NMOS part
		print OUT "M_N11C$dgg ngg".$dgg."_".($j+1)." N".$DGG[$i][$j+2]." GND $nmos1\n";
		print OUT "M_N12C$dgg ngg".$dgg."_".($j+1)." N".$DGG[$i][$j+2]." GND $nmos1\n";
		$tran++;
		$tempArea += $WN1;
		print OUT_AREA "$tran $tempArea\n";
		$tran++;
		$tempArea += $WN1;
		print OUT_AREA "$tran $tempArea\n";
		
		
		print OUT "M_N21C$dgg c".$dgg."_out N".$DGG[$i][$j+3]." ngg".$dgg."_".($j+1)." $nmos1\n";
		print OUT "M_N22C$dgg c".$dgg."_out N".$DGG[$i][$j+3]." ngg".$dgg."_".($j+1)." $nmos1\n";				
		$tran++;
		$tempArea += $WN1;
		print OUT_AREA "$tran $tempArea\n";
		$tran++;
		$tempArea += $WN1;
		print OUT_AREA "$tran $tempArea\n";
		
		print OUT "M_N31C$dgg ngg".$dgg."_".($j+1)." N".$DGG[$i][1]." ngg".$dgg."_".($j+2)." $nmos1\n";
		print OUT "M_N32C$dgg ngg".$dgg."_".($j+1)." N".$DGG[$i][1]." ngg".$dgg."_".($j+2)." $nmos1\n";		
		$tran++;
		$tempArea += $WN1;
		print OUT_AREA "$tran $tempArea\n";
		$tran++;
		$tempArea += $WN1;
		print OUT_AREA "$tran $tempArea\n";
		
		print OUT "M_N41C$dgg ngg".$dgg."_".($j+2)." N".$DGG[$i][$j+3]." GND $nmos1\n";
		print OUT "M_N42C$dgg ngg".$dgg."_".($j+2)." N".$DGG[$i][$j+3]." GND $nmos1\n";
		$tran++;
		$tempArea += $WN1;
		print OUT_AREA "$tran $tempArea\n";
		$tran++;
		$tempArea += $WN1;
		print OUT_AREA "$tran $tempArea\n";
		
		print OUT "M_N51C$dgg c".$dgg."_out N".$DGG[$i][$j+2]." ngg".$dgg."_".($j+2)." $nmos1\n";
		print OUT "M_N52C$dgg c".$dgg."_out N".$DGG[$i][$j+2]." ngg".$dgg."_".($j+2)." $nmos1\n";
		$tran++;
		$tempArea += $WN1;
		print OUT_AREA "$tran $tempArea\n";
		$tran++;
		$tempArea += $WN1;
		print OUT_AREA "$tran $tempArea\n";		
		
		print OUT "\n";
		
		$pmos8 = $pmos1;
		$pmos9 = $pmos1;
		$WP8 = $WP1;
		$WP9 = $WP1;
		$nmos2 = $nmos1;
		$WN2 =  $WN1;
		
		#C-Element PMOS part		
		print OUT "M_P11C$dgg ngg".$dgg."_".($j+3)." N".$DGG[$i][$j+2]." VDD $pmos8\n";
		print OUT "M_P12C$dgg ngg".$dgg."_".($j+3)." N".$DGG[$i][$j+2]." VDD $pmos8\n";
		$tran++;
		$tempArea += $WP8;
		print OUT_AREA "$tran $tempArea\n";
		$tran++;
		$tempArea += $WP8;
		print OUT_AREA "$tran $tempArea\n";
		
		print OUT "M_P21C$dgg c".$dgg."_out N".$DGG[$i][$j+3]." ngg".$dgg."_".($j+3)." $pmos9\n";
		print OUT "M_P22C$dgg c".$dgg."_out N".$DGG[$i][$j+3]." ngg".$dgg."_".($j+3)." $pmos9\n";		
		$tran++;
		$tempArea += $WP8;
		print OUT_AREA "$tran $tempArea\n";
		$tran++;
		$tempArea += $WP8;
		print OUT_AREA "$tran $tempArea\n";
		
		print OUT "M_P31C$dgg ngg".$dgg."_".($j+3)." N".$DGG[$i][1]." ngg".$dgg."_".($j+4)." $pmos8\n";
		print OUT "M_P32C$dgg ngg".$dgg."_".($j+3)." N".$DGG[$i][1]." ngg".$dgg."_".($j+4)." $pmos8\n";		
		$tran++;
		$tempArea += $WP8;
		print OUT_AREA "$tran $tempArea\n";
		$tran++;
		$tempArea += $WP8;
		print OUT_AREA "$tran $tempArea\n";
		
		print OUT "M_P41C$dgg ngg".$dgg."_".($j+4)." N".$DGG[$i][$j+3]." VDD $pmos8\n";
		print OUT "M_P42C$dgg ngg".$dgg."_".($j+4)." N".$DGG[$i][$j+3]." VDD $pmos8\n";
		$tran++;
		$tempArea += $WP8;
		print OUT_AREA "$tran $tempArea\n";
		$tran++;
		$tempArea += $WP8;
		print OUT_AREA "$tran $tempArea\n";
				
		print OUT "M_P51C$dgg c".$dgg."_out N".$DGG[$i][$j+2]." ngg".$dgg."_".($j+4)." $pmos9\n";
		print OUT "M_P52C$dgg c".$dgg."_out N".$DGG[$i][$j+2]." ngg".$dgg."_".($j+4)." $pmos9\n";
		$tran++;
		$tempArea += $WP8;
		print OUT_AREA "$tran $tempArea\n";
		$tran++;
		$tempArea += $WP8;
		print OUT_AREA "$tran $tempArea\n";
		
		print OUT "\n";
								
		# # Generating the inverter		
		print OUT "M_N61C$dgg N".$DGG[$i][1]." c".$dgg."_out GND $nmos2\n";
		print OUT "M_N62C$dgg N".$DGG[$i][1]." c".$dgg."_out GND $nmos2\n";		
		$tran++;
		$tempArea += $WN2;
		print OUT_AREA "$tran $tempArea\n";
		$tran++;
		$tempArea += $WN2;
		print OUT_AREA "$tran $tempArea\n";
		
		print OUT "M_P61C$dgg N".$DGG[$i][1]." c".$dgg."_out VDD $pmos8\n";	
		print OUT "M_P62C$dgg N".$DGG[$i][1]." c".$dgg."_out VDD $pmos8\n\n";	
		$tran++;
		$tempArea += $WP8;
		print OUT_AREA "$tran $tempArea\n";		
		$tran++;
		$tempArea += $WP8;
		print OUT_AREA "$tran $tempArea\n";		
		
		$dgg++;
		
		$area = $tempArea; #8.424; #58.428;
	}
	
	
} #End of File reading.

print OUT "\n\n*Control statements\n";
print OUT ".option post=2\n";
# print OUT ".TR .1ns 1ns 1ns 10ns\n";
print OUT ".TR 1ns 2ns .1ns 3ns 1ns 10ns\n";
# print OUT ".TR 1ns 10ns\n";
# print OUT ".TR 1ns 50ns\n";


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

print OUT ".print TR ";
for ($i=0; $i < $out; $i++){
	if ($flag{$OUTPUT[$i]}==1){
		print OUT "NN".$OUTPUT[$i];
	}
	else{
		print OUT "V(N".$OUTPUT[$i];
	}
	if ($i != $out-1) {
           print OUT ") ";
        } else {
	   # print OUT "), V(xx), V(yy)\n";
	   print OUT ")\n";
	}
}

#########################################################################################################
# Manually add technology file here. This step can be													# 
# automated, probably will do when Ph.D monkey is off my												#
# shoulder. :)																							#
#########################################################################################################
print OUT "\n\n*PTM 45nm NMOS

.MODEL NMOS NMOS (  LEVEL   = 54
+VERSION = 4.3            BINUNIT = 1              MOBMOD  = 2
+CAPMOD  = 2              EPSROX  = 3.9            TOXE    = 2.5E-9
+NGATE   = 3E20           RSH     = 12.5           VTH0    = 0.4739505
+K1      = 0.3288759      K2      = -0.0158543     K3      = 40.7854328
+K3B     = -2.1457348     W0      = 4.161996E-7    LPE0    = 7.081782E-8
+LPEB    = -1.306998E-9   DVT0    = 0.0218474      DVT1    = 0.0775716
+DVT2    = -5.027235E-5   DVTP0   = 0              DVTP1   = 0
+DVT0W   = 0              DVT1W   = 0              DVT2W   = -0.032
+U0      = 241.6713196    UA      = 9.94508E-12    UB      = 3.607248E-18
+UC      = -2.92397E-13   EU      = 0.0187797      VSAT    = 8.405035E4
+A0      = 1.5477984      AGS     = 0.7044088      B0      = 9.45047E-8
+B1      = 1E-7           KETA    = -0.0534235     A1      = 0
+A2      = 1              WINT    = 5.922209E-15   LINT    = 3.007816E-14
+DWG     = -3.146107E-8   DWB     = -1.244296E-8   VOFF    = -0.1368755
+NFACTOR = 1.3762145      ETA0    = 9.143629E-3    ETAB    = -1.7567E-3
+DSUB    = 0.1733722      CIT     = 0              CDSC    = 2.4E-4
+CDSCB   = 0              CDSCD   = 0              PCLM    = 0.5083422
+PDIBLC1 = 1.953204E-3    PDIBLC2 = 0.01           PDIBLCB = -1E-3
+DROUT   = 0.450015       PSCBE1  = 7.984016E8     PSCBE2  = 3E-6
+PVAG    = 0              DELTA   = 8.821768E-3    FPROUT  = 0
+RDSW    = 233.1815191    RDSWMIN = 100            RDW     = 100
+RDWMIN  = 0              RSW     = 100            RSWMIN  = 0
+PRWG    = 1.0222753      PRWB    = 5.438136E-3    WR      = 1
+XPART   = 0.5            CGSO    = 1.5E-10        CGDO    = 1.5E-10
+CGBO    = 1E-12          CF      = 0              CJS     = 1E-4
+CJD     = 1E-4           MJS     = 0.9            MJD     = 0.9
+MJSWS   = 0.55           MJSWD   = 0.55           CJSWS   = 1E-10
+CJSWD   = 1E-10          CJSWGS  = 5E-10          CJSWGD  = 5E-10
+MJSWGS  = 0.33           MJSWGD  = 0.33           PB      = 1
+PBSWS   = 1              PBSWD   = 1              PBSWGS  = 1
+PBSWGD  = 1              TNOM    = 27             PVTH0   = 1E-4
+PRDSW   = 1.0618694      PK2     = 9.998152E-6    WKETA   = 0.0106065
+LKETA   = 0.015308       PKETA   = 1.259635E-3    PETA0   = 0
+PVSAT   = -200           PU0     = -5E-3          PUA     = -1.64182E-19
+PUB     = -1.64146E-20    )

*PTM 45nm PMOS

.MODEL PMOS PMOS (                                LEVEL   = 54
+VERSION = 4.3            BINUNIT = 1              MOBMOD  = 2
+CAPMOD  = 2              EPSROX  = 3.9            TOXE    = 2.5E-9
+NGATE   = 1E20           RSH     = 11.4           VTH0    = -0.2006695
+K1      = 1              K2      = -0.3137426     K3      = 1.029921E-3
+K3B     = 10             W0      = 2.96285E-5     LPE0    = 3.265024E-8
+LPEB    = -7.889114E-9   DVT0    = 0.0168735      DVT1    = 0.0596296
+DVT2    = -3.327424E-3   DVTP0   = 0              DVTP1   = 0
+DVT0W   = 0              DVT1W   = 0              DVT2W   = -0.032
+U0      = 71.2573649     UA      = 1.478939E-9    UB      = 1E-23
+UC      = 5.365897E-10   EU      = 0.9183533      VSAT    = 4.752625E4
+A0      = 2              AGS     = 1.5485876      B0      = 0
+B1      = 8.104319E-11   KETA    = 0.05           A1      = 0
+A2      = 1              WINT    = 8.363067E-10   LINT    = 0
+DWG     = -4.68436E-10   DWB     = -2.027152E-8   VOFF    = 0
+NFACTOR = 4.409062E-3    ETA0    = 3.583869E-3    ETAB    = 0
+DSUB    = 0.2676254      CIT     = 0              CDSC    = 2.4E-4
+CDSCB   = 0              CDSCD   = 0              PCLM    = 1.4439575
+PDIBLC1 = 0.6392007      PDIBLC2 = 8.115123E-3    PDIBLCB = 0
+DROUT   = 1              PSCBE1  = 5.806616E8     PSCBE2  = 9.984169E-6
+PVAG    = 0.0870985      DELTA   = 2.02193E-3     FPROUT  = 1.455413E-5
+RDSW    = 907.4730507    RDSWMIN = 100            RDW     = 100
+RDWMIN  = 0              RSW     = 100            RSWMIN  = 0
+PRWG    = 0.1            PRWB    = 0.1            WR      = 1
+XPART   = 0.5            CGSO    = 1.5E-10        CGDO    = 1.5E-10
+CGBO    = 1E-12          CF      = 0              CJS     = 1.4E-4
+CJD     = 1.4E-4         MJS     = 0.1            MJD     = 0.1
+MJSWS   = 0.5            MJSWD   = 0.5            CJSWS   = 1E-10
+CJSWD   = 1E-10          CJSWGS  = 5E-10          CJSWGD  = 5E-10
+MJSWGS  = 0.33           MJSWGD  = 0.33           PB      = 1
+PBSWS   = 1              PBSWD   = 1              PBSWGS  = 1
+PBSWGD  = 1              TNOM    = 27             PVTH0   = -9.788841E-6
+PRDSW   = 0.0264517      PK2     = -4.059563E-4   WKETA   = -0.1
+LKETA   = 0.0375533      PKETA   = 3.167613E-3    PETA0   = 0
+PVSAT   = 267.341999     PU0     = 0.4896485      PUA     = 9.202761E-22
+PUB     = 7.670109E-22    ) \n\n";
#########################################################################################################
# Technology file addition ends here.																	#
#########################################################################################################
print OUT "\n";
print OUT ".end";
 

print OUT_TEMP "*$circuit benchmark circuit\n\n";

#printing input signals
print OUT_TEMP "*INPUTS ";
for ($i=0; $i < $in; $i++){
	print OUT_TEMP "N".$INPUT[$i];
	if ($i != $in-1) {
           print OUT_TEMP " ";
        } else {
	   print OUT_TEMP "\n";
	}
} 


#printing output signals
print OUT_TEMP "*OUTPUTS ";
for ($i=0; $i < $out; $i++){
	if ($flag{$OUTPUT[$i]}==1){
		print OUT_TEMP "NN".$OUTPUT[$i];
	}
	else{
		print OUT_TEMP "N".$OUTPUT[$i];
	}
	if ($i != $out-1) {
           print OUT_TEMP " ";
        } else {
	   print OUT_TEMP "\n";
	}
}


print OUT_TEMP "\n*Parameters declaration";
print OUT_TEMP "\n.Param ll=$ll"."U WN='(2*ll)' WP='(4*ll)' WN1='($scaling_all_nmos_nor*WN)' WN2='($scaling_nand_23*WN)' WN3='($scaling_nand_34*WN)' WN4='($scaling_nand_45*WN)' WN5='($scaling_quad_nand2*WN)' WN6='($scaling_quad_nand3*WN)' WN7='($scaling_quad_nand4*WN)' WP1='($scaling_all_pmos_nand*WP)' WP2='($scaling_nor_23*WP)' WP3='($scaling_nor_34*WP)' WP4='($scaling_nor_45*WP)' WP5='($scaling_quad_nor2*WP)' WP6='($scaling_quad_nor3*WP)' WP7='($scaling_quad_nor4*WP)' WP8='($scaling_DGG*WP)' WP9='($scaling_DGG2*WP)'\n"; #45nm technology# 

print OUT_TEMP "\n*Power supplies";
print OUT_TEMP "\nVDD VDD GND DC $vdd\n";
# print OUT_TEMP "Vin1 xx GND dc 0 pulse(0 1 0 0.1ns 0.1ns 8ns 15ns)\n";
# print OUT_TEMP "Vin2 yy GND dc 0 pulse(1 0 5ns 0.1ns 0.1ns 6ns 12ns)\n";

close (OUT);
close (OUT_TEMP);

open(IN,"$circuit".".sp") || die " Cannot open input file $circuit".".v \n";
open(OUT,">>test.sp") || die " Cannot open input file $circuit".".v \n";
while (<IN>) {
	print OUT $_;
}
close(IN);
close(OUT);

#write area to a file
open(OUT2,">area.sp") || die " Cannot open input file area.sp \n";
print OUT2 $area;
close (OUT2);
close (OUT_AREA);

#delete the temporary test file.
system ("del $circuit.sp");
system ("ren test.sp $circuit.sp");


$end=time;
$diff = $end - $start;

# print "Number of inputs = $in \n";
# print "Number of outputs= $out \n";
# print "Number of inout pins =$ino \n";
# print "Number of INV gates= $ninv \n";
# print "Number of BUFF gates= $nbuff \n";
# print "Number of NAND gates= $nnand \n";
# print "Number of AND gates= $nand \n";
# print "Number of NOR gates= $nnor \n";
# print "Number of OR gates= $nor \n";
# print "Number of MAJ gates= $maj \n";
# print "Number of MUX gates= $mux \n";
# print "Number of D Flip-Flops= $dff \n";
# print "Number of Majority Voter = $mv\n";
# print "Number of GG = $gg \n\n";
print "\nNumber Transistors = $tran\n";
print "Area = $area\n";

# print "Number of DINV gates= $dninv \n";
# print "Number of DBUFF gates= $dnbuff \n";
# print "Number of DNAND gates= $dnnand \n";
# print "Number of DAND gates= $dnand \n";
# print "Number of DNOR gates= $dnnor \n";
# print "Number of DOR gates= $dnor \n";
# print "Number of DGG gates= $dgg \n\n";


# print "Number of QINV gates= $qninv \n";
# print "Number of QBUFF gates= $qnbuff \n";
# print "Number of QNAND gates= $qnnand \n";
# print "Number of QAND gates= $qnand \n";
# print "Number of QNOR gates= $qnnor \n";
# print "Number of QOR gates= $qnor \n";
# print "Number of QMAJ gates= $qmaj \n";
# print "Number of QMUX gates= $qmux \n";
# print "Number of QGG = $qgg \n\n";
# print "Execution time is $diff seconds \n";
