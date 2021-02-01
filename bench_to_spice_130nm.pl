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
$and=0;
$or=0;

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
$mux=0;

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
$scaling_all_pmos_nand = 2.4;
$scaling_not_2 = 2.8;
$scaling_nand_23 = 3.1;
$scaling_nand_34 = 4.1;
$scaling_nand_45 = 5.1;

$scaling_quad_not = 2.8;
$scaling_quad_nand2 = 3.1;
$scaling_quad_nand3 = 4.1;
$scaling_quad_nand4 = 5.1;

$scaling_all_nmos_nor = 2;
$scaling_nor_23 = 4.4;
$scaling_nor_34 = 6.2;
$scaling_nor_45 = 7.5;

$scaling_quad_nor2 = 6;
$scaling_quad_nor3 = 6.2;
$scaling_quad_nor4 = 7.5;

$scaling_DGG = 25;
$scaling_DGG2 = 26.5;
#############################################################

#########################################################
#	Basic Dimensions of a transistor					#
#########################################################
$ll = 0.13;
$vdd = 1.3;

$WN = 2*$ll;
$WP = 4*$ll;
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
		
		my @gateList = ($_ =~ m/(\w+\d)/g);			#Read All the Gates
		my @gateName = ($_ =~ m/(\w+)\(/i);	 #Read the gate Name i.e. NOT		
		
		my @gateList = ($_ =~ m/\w+/g);	
		
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
		
		my @gateList = ($_ =~ m/(\w+\d)/g);			#Read All the Gates
		my @gateName = ($_ =~ m/(\w+)\(/i);	 #Read the gate Name i.e. NOT		
		
		my @gateList = ($_ =~ m/\w+/g);	
		
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
	
	
	#Matching OR gates		
	if (/\bOR\b/i) {	
		my @gateList = ($_ =~ m/(\w+\d)/g);	 #Read All the Gates
		my @gateName = ($_ =~ m/(\w+)\(/i);	 #Read the gate Name i.e. OR					
		
		my @gateList = ($_ =~ m/\w+/g);				
		@gateList = ($gateList[0], @gateList[2..$#gateList]);
			
		$i=0;
		$NOR[$i][0] = scalar @gateList - 1; #number of inputs.
		$NOR[$i][1] = $gateList[0]; #output is stored here		
			
		foreach $k (2..scalar @gateList)
		{	$NOR[$i][$k] = $gateList[$k-1];	}			                  				
				
		if ($d == 1) {	
		print OUT "\n*N".$NOR[$i][1]." = OR( ";
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
			print OUT "M_nnnor".$or."_".($k+1)." N".$NOR[$i][1]."_TEMP N".$NOR[$i][$k+2]." GND $nmos \n";	
			$count++;
			$tran++;
			$tempArea += $WN;
			print OUT_AREA "$tran $tempArea\n";					
		}
		
		if ($d == 1) {
			print OUT "\n";
		}

		# printing the pmos transistors
		print OUT "M_nnnor".$or."_".($tran+1)." N".$NOR[$i][1]."_TEMP N".$NOR[$i][$j+2]." nr".$or."_".($j+1)." $pmos\n";	
		$tran++;
		$tempArea += $WP;
		print OUT_AREA "$tran $tempArea\n";
			
		for ($j=1; $j < $NOR[$i][0]-1 ; $j++) {
			print OUT "M_nnnor".$or."_".($tran+1)." nr".$or."_".($j)." N".$NOR[$i][$j+2]." nr".$or."_".($j+1)." $pmos\n";
			$tran++;
			$tempArea += $WP;
			print OUT_AREA "$tran $tempArea\n";		
        }
		
		$j = ($NOR[$i][0]-2);	
		print OUT "M_nnnor".$or."_".($tran+1)." nr".$or."_".($j+1)." N".$NOR[$i][$j+3]." VDD $pmos\n";
		$tran++;
		$tempArea += $WP;
		print OUT_AREA "$tran $tempArea\n";				
		
		$or++;
		$area += (scalar @gateList - 1)*$WN + (scalar @gateList - 1)*$WP;
		
		#  nmos transistor
		print OUT "\n";
		print OUT "M_not".$ninv."_1 N".$NOR[$i][1]." N".$NOR[$i][1]."_TEMP GND $nmos\n";
		$tran++;
		$tempArea += $WN;
		print OUT_AREA "$tran $tempArea\n";
		
		#  pmos transistors
		print OUT "M_not".$ninv."_2 N".$NOR[$i][1]." N".$NOR[$i][1]."_TEMP VDD $pmos\n";
		$tran++;
		$tempArea += $WP;
		print OUT_AREA "$tran $tempArea\n";
		
		$ninv++;
		$area += $WN + $WP;			
	}
		
	
	# Matching AND gates	
	if (/\bAND\b/i) {	
		my @gateList = ($_ =~ m/(\w+\d)/g);			#Read All the Gates
		my @gateName = ($_ =~ m/(\w+)\(/i);	 #Read the gate Name i.e. NAND		
		
		my @gateList = ($_ =~ m/\w+/g);				
		@gateList = ($gateList[0], @gateList[2..$#gateList]);
		
		$i = 0;
		$NAND[$i][0] = scalar @gateList - 1; #number of inputs.
		$NAND[$i][1] = $gateList[0]; #output is stored here		
			
		foreach $k (2..scalar @gateList)
		{	$NAND[$i][$k] = $gateList[$k-1];	}			
		
		if ($d == 1) {		
			print OUT "\n*N".$NAND[$i][1]." = AND( ";
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
		print OUT "M_nnand".$and."_1 N".$NAND[$i][1]."_TEMP N".$NAND[$i][$j+2]." nd".$and."_".($j+1)." $nmos\n";		
		
		$tran++;
		$tempArea += $WN;
		print OUT_AREA "$tran $tempArea\n";
					
		for ($j=1; $j < $NAND[$i][0]-1 ; $j++){			
			print OUT "M_nnand".$and."_".($j+1)." nd".$and."_".($j)." N".$NAND[$i][$j+2]." nd".$and."_".($j+1)." $nmos\n";								
			$tran++;
			$tempArea += $WN;
			print OUT_AREA "$tran $tempArea\n";
		}

		$j = ($NAND[$i][0]-2);		
		print OUT "M_nnand".$and."_".$NAND[$i][0]." nd".$and."_".($j+1)." N".$NAND[$i][$j+3]." GND $nmos\n";		
		$tran++;
		$tempArea += $WN;
		print OUT_AREA "$tran $tempArea\n";
		
		if ($d == 1) {
			print OUT "\n";
		}

		# printing the pmos transistors		
		for ($k=0; $k < $NAND[$i][0] ; $k++){			
			print OUT "M_nnand".$and."_".($NAND[$i][0]+$k+1)." N".$NAND[$i][1]."_TEMP N".$NAND[$i][$k+2]." VDD $pmos \n";
			$tran++;
			$tempArea += $WP;
			print OUT_AREA "$tran $tempArea\n";
		}	

		$and++;

		#  nmos transistor
		print OUT "\n";
		print OUT "M_not".$ninv."_1 N".$NAND[$i][1]." N".$NAND[$i][1]."_TEMP GND $nmos\n";
		$tran++;
		$tempArea += $WN;
		print OUT_AREA "$tran $tempArea\n";
		
		#  pmos transistors
		print OUT "M_not".$ninv."_2 N".$NAND[$i][1]." N".$NAND[$i][1]."_TEMP VDD $pmos\n";
		$tran++;
		$tempArea += $WP;
		print OUT_AREA "$tran $tempArea\n";
		
		$ninv++;
		$area += $WN + $WP;		
		
		$area += (scalar @gateList - 1)*$WN + (scalar @gateList - 1)*$WP;		
    }
       
	
	# Matching NAND gates	
	if (/\bNAND\b/i) {	
		my @gateList = ($_ =~ m/(\w+\d)/g);			#Read All the Gates
		my @gateName = ($_ =~ m/(\w+)\(/i);	 #Read the gate Name i.e. NAND		
		
		my @gateList = ($_ =~ m/\w+/g);				
		@gateList = ($gateList[0], @gateList[2..$#gateList]);		
		# print "GL :@gateList \n"; exit;
		
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
		my @gateList = ($_ =~ m/(\w+\d)/g);			#Read All the Gates
		my @gateName = ($_ =~ m/(\w+)\(/i);	 #Read the gate Name i.e. NOR					
		
		my @gateList = ($_ =~ m/\w+/g);				
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
		
		my @gateList = ($_ =~ m/(\w+\d)/g);			#Read All the Gates
		my @gateName = ($_ =~ m/(\w+)\(/i);  		#Read the gate Name i.e. DNAND				
				
		my @gateList = ($_ =~ m/\w+/g);				
				
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
		
		my @gateList = ($_ =~ m/(\w+\d)/g);			#Read All the Gates
		my @gateName = ($_ =~ m/(\w+)\(/i);  		#Read the gate Name i.e. DNAND				
		
		my @gateList = ($_ =~ m/\w+/g);				
		
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
		
		my @gateList = ($_ =~ m/(\w+\d)/g);			#Read All the Gates
		my @gateName = ($_ =~ m/(\w+)\(/i);  		#Read the gate Name i.e. DNAND				
		
		my @gateList = ($_ =~ m/\w+/g);				
		
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
				
		my @gateList = ($_ =~ m/\w+/g);				
		
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
			
		my @gateList = ($_ =~ m/(\w+\d)/g);			#Read All the Gates
		my @gateName = ($_ =~ m/(\w+)\(/i);  		#Read the gate 
		
		my @gateList = ($_ =~ m/\w+/g);						
				
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
		
		my @gateList = ($_ =~ m/(\w+\d)/g);			#Read All the Gates
		my @gateName = ($_ =~ m/(\w+)\(/i);  		#Read the gate Name
		
		my @gateList = ($_ =~ m/\w+/g);				
				
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
					
		my @gateList = ($_ =~ m/(\w+\d)/g);			#Read All the Gates
		my @gateName = ($_ =~ m/(\w+)\(/i);  		#Read the gate Name
		
		my @gateList = ($_ =~ m/\w+/g);				
				
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
		
		my @gateList = ($_ =~ m/(\w+\d)/g);			#Read All the Gates
		my @gateName = ($_ =~ m/(\w+)\(/i);  		#Read the gate Name i.e. NAND23
		
		my @gateList = ($_ =~ m/\w+/g);		
				
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
		
		my @gateList = ($_ =~ m/(\w+\d)/g);			#Read All the Gates
		my @gateName = ($_ =~ m/(\w+)\(/i);  		#Read the gate Name i.e. NAND34	
		
		my @gateList = ($_ =~ m/\w+/g);						
		
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
		
		my @gateList = ($_ =~ m/(\w+\d)/g);			#Read All the Gates
		my @gateName = ($_ =~ m/(\w+)\(/i);  		#Read the gate Name i.e. NAND48
		
		my @gateList = ($_ =~ m/\w+/g);				
		
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
		
		my @gateList = ($_ =~ m/(\w+\d)/g);			#Read All the Gates
		my @gateName = ($_ =~ m/(\w+)\(/i);  		#Read the gate Name i.e. DNOR						
		
		my @gateList = ($_ =~ m/\w+/g);						
		
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
		
		my @gateList = ($_ =~ m/(\w+\d)/g);			#Read All the Gates
		my @gateName = ($_ =~ m/(\w+)\(/i);  		#Read the gate Name i.e. NOR32 or NOR42
			
		my @gateList = ($_ =~ m/\w+/g);							
		
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
		
		my @gateList = ($_ =~ m/(\w+\d)/g);		#Read All the Gates
		my @gateName = ($_ =~ m/(\w+)\(/i);  	#Read the gate Name i.e. NOR43
			
		my @gateList = ($_ =~ m/\w+/g);							
		
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
		
		my @gateList = ($_ =~ m/(\w+\d)/g);		#Read All the Gates
		my @gateName = ($_ =~ m/(\w+)\(/i);  	#Read the gate Name i.e. NOR22, NOR33 or NOR44				
			
		my @gateList = ($_ =~ m/\w+/g);							
		
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
		
		my @gateList = ($_ =~ m/(\w+\d)/g);		#Read All the Gates
		my @gateName = ($_ =~ m/(\w+)\(/i);  	#Read the gate Name 
		
		my @gateList = ($_ =~ m/\w+/g);				
		
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
		
		my @gateList = ($_ =~ m/(\w+\d)/g);		#Read All the Gates
		my @gateName = ($_ =~ m/(\w+)\(/i);  	#Read the gate Name 
		
		my @gateList = ($_ =~ m/\w+/g);				
		
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
		
		my @gateList = ($_ =~ m/(\w+\d)/g);		#Read All the Gates
		my @gateName = ($_ =~ m/(\w+)\(/i);  	#Read the gate Name 
		
		my @gateList = ($_ =~ m/\w+/g);				
		
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
		
		my @gateList = ($_ =~ m/(\w+\d)/g);		#Read All the Gates
		my @gateName = ($_ =~ m/(\w+)\(/i);  	#Read the gate Name i.e. NOR23				
			
		my @gateList = ($_ =~ m/\w+/g);							
		
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
		
		my @gateList = ($_ =~ m/(\w+\d)/g);		#Read All the Gates
		my @gateName = ($_ =~ m/(\w+)\(/i);  	#Read the gate Name 
			
		my @gateList = ($_ =~ m/\w+/g);							
		
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
		
		my @gateList = ($_ =~ m/(\w+\d)/g);		#Read All the Gates
		my @gateName = ($_ =~ m/(\w+)\(/i);  	#Read the gate Name i.e. NOR45				

		my @gateList = ($_ =~ m/\w+/g);				
			
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
	
		my @gateList = ($_ =~ m/(\w+\d)/g);			#Read All the Gates
		my @gateName = ($_ =~ m/(\w+)\(/i);  		#Read the gate Name i.e. QNOT				
		my @allGates = ($_ =~ m/\((\w.*)\)/ig);  	#Read all Gates including 's' and 'p' keywords			
				
		#print "Gate List = @gateList  size = ",scalar @gateList,"\n All Gates = @allGates \n Gate Name = $gateName[0]\n";
				
		push (@connectionPattern_QNOT, [ split(m/,\s|,/, $allGates[0]) ]);					
				
		$i=0;
		$QINV[$i][0] = $gateList[0]; #output is stored here						
		$QINV[$i][1] = $gateList[1]; #input is stored here						
				
		my $conpat = shift(@connectionPattern_QNOT);		
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
		
		my @gateList = ($_ =~ m/(\w+\d)/g);			#Read All the Gates
		my @gateName = ($_ =~ m/(\w+)\(/i);  		#Read the gate Name i.e. QNAND				
		my @allGates = ($_ =~ m/\((\w.*)\)/ig);  	#Read all Gates including 's' and 'p' keywords			
		
		my @gateList = ($_ =~ m/\w+/g);				
		@gateList = ($gateList[0], @gateList[2..$#gateList]);				
		
		push (@connectionPattern_QNAND, [ split(m/,\s|,/, $allGates[0]) ]);					
		
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
		my @gateList = ($_ =~ m/(\w+\d)/g);			#Read All the Gates
		my @gateName = ($_ =~ m/(\w+)\(/i);  		#Read the gate Name i.e. QNAND				
		my @allGates = ($_ =~ m/\((\w.*)\)/ig);  	#Read all Gates including 's' and 'p' keywords		
		
		my @gateList = ($_ =~ m/\w+/g);				
		@gateList = ($gateList[0], @gateList[2..$#gateList]);		
				
		push (@connectionPattern_QNOR, [ split(m/,\s|,/, $allGates[0]) ]);				
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
			$currentWP = $WP2;
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
	if (/\bGG\b/i) {	
		my @gateList = ($_ =~ m/(\w+\d)/g);			#Read All the Gates		
		
		my @gateList = ($_ =~ m/\w+/g);				
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
		
		$area += 4.68;
	}
	
		
	#Matching Fully Protected Guard Gates (DGG) or C-Element.
	if (/\bDGG\b/i) {	
		
		my @gateList = ($_ =~ m/(\w+\d)/g);			#Read All the Gates		
		
		my @gateList = ($_ =~ m/\w+/g);				
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
		
		$area += 21.216; 
	}
	
	
	#Matching a MUX
	if (/\bMUX\b/i) {

		my @gateList = ($_ =~ m/\w+/g);							
		@gateList = ($gateList[0], @gateList[2..$#gateList]);
		
		# print "GL: @gateList \n";
		
		$i = 0;
		$MUX[$i][0] = scalar @gateList - 1; #number of inputs.
		$MUX[$i][1] = $gateList[0]; #output is stored here		
				
		foreach $k (2..scalar @gateList) {				
			$MUX[$i][$k] = $gateList[$k-1];			
		}			                  				
				
		
				
		if ($d == 1) {	
			print OUT "\n* N".$MUX[$i][1]." = MUX( ";
			for ($j=0; $j < $MUX[$i][0] ; $j++){
				if ($j == $MUX[$i][0]-1){
					print OUT "N".$MUX[$i][2+$j]." ) \n";
				} else {
					print OUT "N".$MUX[$i][2+$j].", ";
				}
			}
		}
		
		################################
		# INPUT A
		################################
		$i=0;
		$j=0;
		
		#  nmos transistor
		print OUT "M_not".$ninv."_1 Nmux_".$mux."_temp1 N".$MUX[$i][4]." GND $nmos\n";
		$tran++;
		$tempArea += $WN;
		print OUT_AREA "$tran $tempArea\n";
		
		#  pmos transistors
		print OUT "M_not".$ninv."_2 Nmux_".$mux."_temp1 N".$MUX[$i][4]." VDD $pmos\n";				
		$ninv++;
		$area += $WN + $WP;		
		$tran++;
		$tempArea += $WP;
		print OUT_AREA "$tran $tempArea\n";
		
		print OUT "M_mux".$mux."_1 N".$MUX[$i][1]." Nmux_".$mux."_temp1 N".$MUX[$i][2]." $nmos\n";		
		print OUT "M_mux".$mux."_2 N".$MUX[$i][1]." N".$MUX[$i][4]." N".$MUX[$i][2]." $pmos\n\n";	

		$area += $WN + $WP;					
		
		################################
		# INPUT B
		################################
		$i=0;
		$j=0;
		
		#  nmos transistor
		print OUT "M_not".$ninv."_1 Nmux_".$mux."_temp2 N".$MUX[$i][4]." GND $nmos\n";
		$tran++;
		$tempArea += $WN;
		print OUT_AREA "$tran $tempArea\n";
		
		#  pmos transistors
		print OUT "M_not".$ninv."_2 Nmux_".$mux."_temp2 N".$MUX[$i][4]." VDD $pmos\n";				
		$ninv++;
		$area += $WN + $WP;		
		$tran++;
		$tempArea += $WP;
		print OUT_AREA "$tran $tempArea\n";
		
		print OUT "M_mux".$mux."_3 N".$MUX[$i][1]." N".$MUX[$i][4]." N".$MUX[$i][3]." $nmos\n";	
		print OUT "M_mux".$mux."_4 N".$MUX[$i][1]." Nmux_".$mux."_temp2 N".$MUX[$i][3]." $pmos\n\n";		
		
		$area += $WN + $WP;							
		$mux++;		
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
print OUT "\n\n* Beta Version released on 2/22/06

* PTM 130nm NMOS 

.MODEL NMOS NMOS (  LEVEL   = 54

+version = 4.0          binunit = 1            paramchk= 1            mobmod  = 0          
+capmod  = 2            igcmod  = 1            igbmod  = 1            geomod  = 1          
+diomod  = 1            rdsmod  = 0            rbodymod= 1            rgatemod= 1          
+permod  = 1            acnqsmod= 0            trnqsmod= 0          

+tnom    = 27           toxe    = 2.25e-9      toxp    = 1.6e-9       toxm    = 2.25e-9   
+dtox    = 0.65e-9      epsrox  = 3.9          wint    = 5e-009       lint    = 10.5e-009   
+ll      = 0            wl      = 0            lln     = 1            wln     = 1          
+lw      = 0            ww      = 0            lwn     = 1            wwn     = 1          
+lwl     = 0            wwl     = 0            xpart   = 0            toxref  = 2.25e-9   
+xl      = -60e-9
+vth0    = 0.3782       k1      = 0.4          k2      = 0.01         k3      = 0          
+k3b     = 0            w0      = 2.5e-006     dvt0    = 1            dvt1    = 2       
+dvt2    = -0.032       dvt0w   = 0            dvt1w   = 0            dvt2w   = 0          
+dsub    = 0.1          minv    = 0.05         voffl   = 0            dvtp0   = 1.2e-010     
+dvtp1   = 0.1          lpe0    = 0            lpeb    = 0            xj      = 3.92e-008   
+ngate   = 2e+020       ndep    = 1.54e+018    nsd     = 2e+020       phin    = 0          
+cdsc    = 0.0002       cdscb   = 0            cdscd   = 0            cit     = 0          
+voff    = -0.13        nfactor = 1.5          eta0    = 0.0092       etab    = 0          
+vfb     = -0.55        u0      = 0.05928      ua      = 6e-010       ub      = 1.2e-018     
+uc      = 0            vsat    = 100370       a0      = 1            ags     = 1e-020     
+a1      = 0            a2      = 1            b0      = 0            b1      = 0          
+keta    = 0.04         dwg     = 0            dwb     = 0            pclm    = 0.06       
+pdiblc1 = 0.001        pdiblc2 = 0.001        pdiblcb = -0.005       drout   = 0.5        
+pvag    = 1e-020       delta   = 0.01         pscbe1  = 8.14e+008    pscbe2  = 1e-007     
+fprout  = 0.2          pdits   = 0.08         pditsd  = 0.23         pditsl  = 2.3e+006   
+rsh     = 5            rdsw    = 200          rsw     = 100          rdw     = 100        
+rdswmin = 0            rdwmin  = 0            rswmin  = 0            prwg    = 0          
+prwb    = 6.8e-011     wr      = 1            alpha0  = 0.074        alpha1  = 0.005      
+beta0   = 30           agidl   = 0.0002       bgidl   = 2.1e+009     cgidl   = 0.0002     
+egidl   = 0.8          

+aigbacc = 0.012        bigbacc = 0.0028       cigbacc = 0.002     
+nigbacc = 1            aigbinv = 0.014        bigbinv = 0.004        cigbinv = 0.004      
+eigbinv = 1.1          nigbinv = 3            aigc    = 0.012        bigc    = 0.0028     
+cigc    = 0.002        aigsd   = 0.012        bigsd   = 0.0028       cigsd   = 0.002     
+nigc    = 1            poxedge = 1            pigcd   = 1            ntox    = 1          

+xrcrg1  = 12           xrcrg2  = 5          
+cgso    = 2.4e-010     cgdo    = 2.4e-010     cgbo    = 2.56e-011    cgdl    = 2.653e-10     
+cgsl    = 2.653e-10    ckappas = 0.03         ckappad = 0.03         acde    = 1          
+moin    = 15           noff    = 0.9          voffcv  = 0.02       

+kt1     = -0.11        kt1l    = 0            kt2     = 0.022        ute     = -1.5       
+ua1     = 4.31e-009    ub1     = 7.61e-018    uc1     = -5.6e-011    prt     = 0          
+at      = 33000      

+fnoimod = 1            tnoimod = 0          

+jss     = 0.0001       jsws    = 1e-011       jswgs   = 1e-010       njs     = 1          
+ijthsfwd= 0.01         ijthsrev= 0.001        bvs     = 10           xjbvs   = 1          
+jsd     = 0.0001       jswd    = 1e-011       jswgd   = 1e-010       njd     = 1          
+ijthdfwd= 0.01         ijthdrev= 0.001        bvd     = 10           xjbvd   = 1          
+pbs     = 1            cjs     = 0.0005       mjs     = 0.5          pbsws   = 1          
+cjsws   = 5e-010       mjsws   = 0.33         pbswgs  = 1            cjswgs  = 3e-010     
+mjswgs  = 0.33         pbd     = 1            cjd     = 0.0005       mjd     = 0.5        
+pbswd   = 1            cjswd   = 5e-010       mjswd   = 0.33         pbswgd  = 1          
+cjswgd  = 5e-010       mjswgd  = 0.33         tpb     = 0.005        tcj     = 0.001      
+tpbsw   = 0.005        tcjsw   = 0.001        tpbswg  = 0.005        tcjswg  = 0.001      
+xtis    = 3            xtid    = 3          

+dmcg    = 0e-006       dmci    = 0e-006       dmdg    = 0e-006       dmcgt   = 0e-007     
+dwj     = 0.0e-008     xgw     = 0e-007       xgl     = 0e-008     

+rshg    = 0.4          gbmin   = 1e-010       rbpb    = 5            rbpd    = 15         
+rbps    = 15           rbdb    = 15           rbsb    = 15           ngcon   = 1        )  

* PTM 130nm PMOS
 
.MODEL PMOS PMOS ( LEVEL   = 54

+version = 4.0          binunit = 1            paramchk= 1            mobmod  = 0          
+capmod  = 2            igcmod  = 1            igbmod  = 1            geomod  = 1          
+diomod  = 1            rdsmod  = 0            rbodymod= 1            rgatemod= 1          
+permod  = 1            acnqsmod= 0            trnqsmod= 0          

+tnom    = 27           toxe    = 2.35e-009    toxp    = 1.6e-009     toxm    = 2.35e-009   
+dtox    = 0.75e-9      epsrox  = 3.9          wint    = 5e-009       lint    = 10.5e-009   
+ll      = 0            wl      = 0            lln     = 1            wln     = 1          
+lw      = 0            ww      = 0            lwn     = 1            wwn     = 1          
+lwl     = 0            wwl     = 0            xpart   = 0            toxref  = 2.35e-009   
+xl      = -60e-9
+vth0    = -0.321       k1      = 0.4          k2      = -0.01        k3      = 0          
+k3b     = 0            w0      = 2.5e-006     dvt0    = 1            dvt1    = 2       
+dvt2    = -0.032       dvt0w   = 0            dvt1w   = 0            dvt2w   = 0          
+dsub    = 0.1          minv    = 0.05         voffl   = 0            dvtp0   = 1e-009     
+dvtp1   = 0.05         lpe0    = 0            lpeb    = 0            xj      = 3.92e-008   
+ngate   = 2e+020       ndep    = 1.14e+018    nsd     = 2e+020       phin    = 0          
+cdsc    = 0.000258     cdscb   = 0            cdscd   = 6.1e-008     cit     = 0          
+voff    = -0.126       nfactor = 1.5          eta0    = 0.0092       etab    = 0          
+vfb     = 0.55         u0      = 0.00835      ua      = 2.0e-009     ub      = 0.5e-018     
+uc      = -3e-011      vsat    = 70000        a0      = 1.0          ags     = 1e-020     
+a1      = 0            a2      = 1            b0      = -1e-020      b1      = 0          
+keta    = -0.047       dwg     = 0            dwb     = 0            pclm    = 0.12       
+pdiblc1 = 0.001        pdiblc2 = 0.001        pdiblcb = 3.4e-008     drout   = 0.56       
+pvag    = 1e-020       delta   = 0.01         pscbe1  = 8.14e+008    pscbe2  = 9.58e-007  
+fprout  = 0.2          pdits   = 0.08         pditsd  = 0.23         pditsl  = 2.3e+006   
+rsh     = 5            rdsw    = 240          rsw     = 120          rdw     = 120        
+rdswmin = 0            rdwmin  = 0            rswmin  = 0            prwg    = 3.22e-008  
+prwb    = 6.8e-011     wr      = 1            alpha0  = 0.074        alpha1  = 0.005      
+beta0   = 30           agidl   = 0.0002       bgidl   = 2.1e+009     cgidl   = 0.0002     
+egidl   = 0.8          

+aigbacc = 0.012        bigbacc = 0.0028       cigbacc = 0.002     
+nigbacc = 1            aigbinv = 0.014        bigbinv = 0.004        cigbinv = 0.004      
+eigbinv = 1.1          nigbinv = 3            aigc    = 0.69         bigc    = 0.0012     
+cigc    = 0.0008       aigsd   = 0.0087       bigsd   = 0.0012       cigsd   = 0.0008     
+nigc    = 1            poxedge = 1            pigcd   = 1            ntox    = 1 
         
+xrcrg1  = 12           xrcrg2  = 5          
+cgso    = 2.4e-010     cgdo    = 2.4e-010     cgbo    = 2.56e-011    cgdl    = 2.653e-10
+cgsl    = 2.653e-10    ckappas = 0.03         ckappad = 0.03         acde    = 1
+moin    = 15           noff    = 0.9          voffcv  = 0.02

+kt1     = -0.11        kt1l    = 0            kt2     = 0.022        ute     = -1.5       
+ua1     = 4.31e-009    ub1     = 7.61e-018    uc1     = -5.6e-011    prt     = 0          
+at      = 33000      

+fnoimod = 1            tnoimod = 0          

+jss     = 0.0001       jsws    = 1e-011       jswgs   = 1e-010       njs     = 1          
+ijthsfwd= 0.01         ijthsrev= 0.001        bvs     = 10           xjbvs   = 1          
+jsd     = 0.0001       jswd    = 1e-011       jswgd   = 1e-010       njd     = 1          
+ijthdfwd= 0.01         ijthdrev= 0.001        bvd     = 10           xjbvd   = 1          
+pbs     = 1            cjs     = 0.0005       mjs     = 0.5          pbsws   = 1          
+cjsws   = 5e-010       mjsws   = 0.33         pbswgs  = 1            cjswgs  = 3e-010     
+mjswgs  = 0.33         pbd     = 1            cjd     = 0.0005       mjd     = 0.5        
+pbswd   = 1            cjswd   = 5e-010       mjswd   = 0.33         pbswgd  = 1          
+cjswgd  = 5e-010       mjswgd  = 0.33         tpb     = 0.005        tcj     = 0.001      
+tpbsw   = 0.005        tcjsw   = 0.001        tpbswg  = 0.005        tcjswg  = 0.001      
+xtis    = 3            xtid    = 3          

+dmcg    = 0e-006       dmci    = 0e-006       dmdg    = 0e-006       dmcgt   = 0e-007     
+dwj     = 0.0e-008     xgw     = 0e-007       xgl     = 0e-008     

+rshg    = 0.4          gbmin   = 1e-010       rbpb    = 5            rbpd    = 15         
+rbps    = 15           rbdb    = 15           rbsb    = 15           ngcon   = 1 ) \n\n";
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

print "Area = $area\n";

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
 