#! /usr/bin/perl 

###############################################################
#                                                             #
# Description: A perl script to convert a circuit in  bench   #
#              to TMR (triple modular redundancy).            #
#                                                             #
#                                                             #
# Author: Aiman H. El-Maleh (KFUPM)                           #
#                                                             #
# Date: July 14, 2006.                                        #
#                                                             #
###############################################################



#************************************************************************
#                                                                       *
#    Main Program                                                       *
#                                                                       *
#************************************************************************

$start = time;

$circuit=$ARGV[0];


open(IN,"$circuit".".bench") || die " Cannot open input file $circuit".".bench \n";
open(OUT,">$circuit"."_tmr.bench") || die " Cannot open input file $circuit"."_tmr.bench \n";

$tout=0;
$ino=0;


while(<IN>){
   
#        print OUT $_;

# Matching Inputs
   
	if (/INPUT\((.*)\)/) {       
	   $Gate[$ng][0]="INPUT";
	    $Gate[$ng][1]=0; # we store here configuration type i.e. 1, 2, or 3. 0 means not yet configured.
	    $Gate[$ng][2]=0; # Number of inputs
	    $Gate[$ng][3]=$1;
	    $ng++;

	    $Input[$ni]=$1;
	    $ni++;	
	    $flag{$1}=1;       
                     	   	   	   	           
         }

# Matching Outputs

	if (/OUTPUT\((.*)\)/) {
        	$TOUT[$tout]=$1;
		$tout++;
	}


# Matching NOT gates

       if (/(.*) = NOT\((.*)\)/) {
				
	    $Gate[$ng][0]="NOT";
	    $Gate[$ng][1]=0; # we store here configuration type i.e. 1, 2, or 3. 0 means not yet configured.
	    $Gate[$ng][2]=1; # Number of inputs	   
	    $Gate[$ng][3]=$1;
	    $Gate[$ng][4]=$2;
	    $ng++;
        }


# Matching BUF gates

       if (/(.*) = BUFF\((.*)\)/) {
				
	    $Gate[$ng][0]="BUFF";
	    $Gate[$ng][1]=0; # we store here configuration type i.e. 1, 2, or 3. 0 means not yet configured.
	    $Gate[$ng][2]=1; # Number of inputs	   
	    $Gate[$ng][3]=$1;
	    $Gate[$ng][4]=$2;
	    $ng++;
        }

# Matching NAND gates

	if (/(.*) = NAND\((.*), (.*), (.*), (.*), (.*), (.*), (.*), (.*), (.*)\)/) {
		
	    $Gate[$ng][0]="NAND";
	    $Gate[$ng][1]=0; # we store here configuration type i.e. 1, 2, or 3. 0 means not yet configured.
	    $Gate[$ng][2]=9; # we store here the number of inputs in a gate
	    $Gate[$ng][3]=$1;
	    $Gate[$ng][4]=$2;
	    $Gate[$ng][5]=$3;
	    $Gate[$ng][6]=$4;
	    $Gate[$ng][7]=$5;
	    $Gate[$ng][8]=$6;
	    $Gate[$ng][9]=$7;
	    $Gate[$ng][10]=$8;
	    $Gate[$ng][11]=$9;
	    $Gate[$ng][12]=$10;	 
	    $ng++;

        }
	elsif (/(.*) = NAND\((.*), (.*), (.*), (.*), (.*), (.*), (.*), (.*)\)/) {
		
  	    $Gate[$ng][0]="NAND";
	    $Gate[$ng][1]=0; # we store here configuration type i.e. 1, 2, or 3. 0 means not yet configured.
	    $Gate[$ng][2]=8; # we store here the number of inputs in a gate
	    $Gate[$ng][3]=$1;
	    $Gate[$ng][4]=$2;
	    $Gate[$ng][5]=$3;
	    $Gate[$ng][6]=$4;
	    $Gate[$ng][7]=$5;
	    $Gate[$ng][8]=$6;
	    $Gate[$ng][9]=$7;
	    $Gate[$ng][10]=$8;
	    $Gate[$ng][11]=$9;	    
	    $ng++;
        }
	elsif (/(.*) = NAND\((.*), (.*), (.*), (.*), (.*), (.*), (.*)\)/) {
		
  	    $Gate[$ng][0]="NAND";
	    $Gate[$ng][1]=0; # we store here configuration type i.e. 1, 2, or 3. 0 means not yet configured.
	    $Gate[$ng][2]=7; # we store here the number of inputs in a gate
	    $Gate[$ng][3]=$1;
	    $Gate[$ng][4]=$2;
	    $Gate[$ng][5]=$3;
	    $Gate[$ng][6]=$4;
	    $Gate[$ng][7]=$5;
	    $Gate[$ng][8]=$6;
	    $Gate[$ng][9]=$7;
	    $Gate[$ng][10]=$8;   
	    $ng++;
        }
	elsif (/(.*) = NAND\((.*), (.*), (.*), (.*), (.*), (.*)\)/) {
		
 	    $Gate[$ng][0]="NAND";
	    $Gate[$ng][1]=0; # we store here configuration type i.e. 1, 2, or 3. 0 means not yet configured.
	    $Gate[$ng][2]=6; # we store here the number of inputs in a gate
	    $Gate[$ng][3]=$1;
	    $Gate[$ng][4]=$2;
	    $Gate[$ng][5]=$3;
	    $Gate[$ng][6]=$4;
	    $Gate[$ng][7]=$5;
	    $Gate[$ng][8]=$6;
	    $Gate[$ng][9]=$7;
	    $ng++;
        }
 
	elsif (/(.*) = NAND\((.*), (.*), (.*), (.*), (.*)\)/) {
		
	    $Gate[$ng][0]="NAND";
	    $Gate[$ng][1]=0; # we store here configuration type i.e. 1, 2, or 3. 0 means not yet configured.
	    $Gate[$ng][2]=5; # we store here the number of inputs in a gate
	    $Gate[$ng][3]=$1;
	    $Gate[$ng][4]=$2;
	    $Gate[$ng][5]=$3;
	    $Gate[$ng][6]=$4;
	    $Gate[$ng][7]=$5;
	    $Gate[$ng][8]=$6;
	    $ng++;
        }

	 elsif (/(.*) = NAND\((.*), (.*), (.*), (.*)\)/) {
		
	    $Gate[$ng][0]="NAND";
	    $Gate[$ng][1]=0; # we store here configuration type i.e. 1, 2, or 3. 0 means not yet configured.
	    $Gate[$ng][2]=4; # we store here the number of inputs in a gate
	    $Gate[$ng][3]=$1;
	    $Gate[$ng][4]=$2;
	    $Gate[$ng][5]=$3;
	    $Gate[$ng][6]=$4;
	    $Gate[$ng][7]=$5;
	    $ng++;
        }
 
	elsif (/(.*) = NAND\((.*), (.*), (.*)\)/) {
		
	    $Gate[$ng][0]="NAND";
	    $Gate[$ng][1]=0; # we store here configuration type i.e. 1, 2, or 3. 0 means not yet configured.
	    $Gate[$ng][2]=3; # we store here the number of inputs in a gate
	    $Gate[$ng][3]=$1;
	    $Gate[$ng][4]=$2;
	    $Gate[$ng][5]=$3;
	    $Gate[$ng][6]=$4;
	    $ng++;
        }
        elsif (/(.*) = NAND\((.*), (.*)\)/) {
		
	    $Gate[$ng][0]="NAND";
	    $Gate[$ng][1]=0; # we store here configuration type i.e. 1, 2, or 3. 0 means not yet configured.
	    $Gate[$ng][2]=2; # we store here the number of inputs in a gate
	    $Gate[$ng][3]=$1;
	    $Gate[$ng][4]=$2;
	    $Gate[$ng][5]=$3;
	    $ng++;
        }
       
# Matching AND gates

	if (/(.*) = AND\((.*), (.*), (.*), (.*), (.*), (.*), (.*), (.*), (.*)\)/) {
		
	    $Gate[$ng][0]="AND";
	    $Gate[$ng][1]=0; # we store here configuration type i.e. 1, 2, or 3. 0 means not yet configured.
	    $Gate[$ng][2]=9; # we store here the number of inputs in a gate
	    $Gate[$ng][3]=$1;
	    $Gate[$ng][4]=$2;
	    $Gate[$ng][5]=$3;
	    $Gate[$ng][6]=$4;
	    $Gate[$ng][7]=$5;
	    $Gate[$ng][8]=$6;
	    $Gate[$ng][9]=$7;
	    $Gate[$ng][10]=$8;
	    $Gate[$ng][11]=$9;
	    $Gate[$ng][12]=$10;	 
	    $ng++;

        }
	elsif (/(.*) = AND\((.*), (.*), (.*), (.*), (.*), (.*), (.*), (.*)\)/) {
		
  	    $Gate[$ng][0]="AND";
	    $Gate[$ng][1]=0; # we store here configuration type i.e. 1, 2, or 3. 0 means not yet configured.
	    $Gate[$ng][2]=8; # we store here the number of inputs in a gate
	    $Gate[$ng][3]=$1;
	    $Gate[$ng][4]=$2;
	    $Gate[$ng][5]=$3;
	    $Gate[$ng][6]=$4;
	    $Gate[$ng][7]=$5;
	    $Gate[$ng][8]=$6;
	    $Gate[$ng][9]=$7;
	    $Gate[$ng][10]=$8;
	    $Gate[$ng][11]=$9;	    
	    $ng++;
        }
	elsif (/(.*) = AND\((.*), (.*), (.*), (.*), (.*), (.*), (.*)\)/) {
		
  	    $Gate[$ng][0]="AND";
	    $Gate[$ng][1]=0; # we store here configuration type i.e. 1, 2, or 3. 0 means not yet configured.
	    $Gate[$ng][2]=7; # we store here the number of inputs in a gate
	    $Gate[$ng][3]=$1;
	    $Gate[$ng][4]=$2;
	    $Gate[$ng][5]=$3;
	    $Gate[$ng][6]=$4;
	    $Gate[$ng][7]=$5;
	    $Gate[$ng][8]=$6;
	    $Gate[$ng][9]=$7;
	    $Gate[$ng][10]=$8;   
	    $ng++;
        }
	elsif (/(.*) = AND\((.*), (.*), (.*), (.*), (.*), (.*)\)/) {
		
 	    $Gate[$ng][0]="AND";
	    $Gate[$ng][1]=0; # we store here configuration type i.e. 1, 2, or 3. 0 means not yet configured.
	    $Gate[$ng][2]=6; # we store here the number of inputs in a gate
	    $Gate[$ng][3]=$1;
	    $Gate[$ng][4]=$2;
	    $Gate[$ng][5]=$3;
	    $Gate[$ng][6]=$4;
	    $Gate[$ng][7]=$5;
	    $Gate[$ng][8]=$6;
	    $Gate[$ng][9]=$7;
	    $ng++;
        }
 
	elsif (/(.*) = AND\((.*), (.*), (.*), (.*), (.*)\)/) {
		
	    $Gate[$ng][0]="AND";
	    $Gate[$ng][1]=0; # we store here configuration type i.e. 1, 2, or 3. 0 means not yet configured.
	    $Gate[$ng][2]=5; # we store here the number of inputs in a gate
	    $Gate[$ng][3]=$1;
	    $Gate[$ng][4]=$2;
	    $Gate[$ng][5]=$3;
	    $Gate[$ng][6]=$4;
	    $Gate[$ng][7]=$5;
	    $Gate[$ng][8]=$6;
	    $ng++;
        }

	 elsif (/(.*) = AND\((.*), (.*), (.*), (.*)\)/) {
		
	    $Gate[$ng][0]="AND";
	    $Gate[$ng][1]=0; # we store here configuration type i.e. 1, 2, or 3. 0 means not yet configured.
	    $Gate[$ng][2]=4; # we store here the number of inputs in a gate
	    $Gate[$ng][3]=$1;
	    $Gate[$ng][4]=$2;
	    $Gate[$ng][5]=$3;
	    $Gate[$ng][6]=$4;
	    $Gate[$ng][7]=$5;
	    $ng++;
        }
 
	elsif (/(.*) = AND\((.*), (.*), (.*)\)/) {
		
	    $Gate[$ng][0]="AND";
	    $Gate[$ng][1]=0; # we store here configuration type i.e. 1, 2, or 3. 0 means not yet configured.
	    $Gate[$ng][2]=3; # we store here the number of inputs in a gate
	    $Gate[$ng][3]=$1;
	    $Gate[$ng][4]=$2;
	    $Gate[$ng][5]=$3;
	    $Gate[$ng][6]=$4;
	    $ng++;
        }
        elsif (/(.*) = AND\((.*), (.*)\)/) {
		
	    $Gate[$ng][0]="AND";
	    $Gate[$ng][1]=0; # we store here configuration type i.e. 1, 2, or 3. 0 means not yet configured.
	    $Gate[$ng][2]=2; # we store here the number of inputs in a gate
	    $Gate[$ng][3]=$1;
	    $Gate[$ng][4]=$2;
	    $Gate[$ng][5]=$3;
	    $ng++;
        }
       

# Matching NOR gates

	if (/(.*) = NOR\((.*), (.*), (.*), (.*), (.*), (.*), (.*), (.*), (.*)\)/) {
		
	    $Gate[$ng][0]="NOR";
	    $Gate[$ng][1]=0; # we store here configuration type i.e. 1, 2, or 3. 0 means not yet configured.
	    $Gate[$ng][2]=9; # we store here the number of inputs in a gate
	    $Gate[$ng][3]=$1;
	    $Gate[$ng][4]=$2;
	    $Gate[$ng][5]=$3;
	    $Gate[$ng][6]=$4;
	    $Gate[$ng][7]=$5;
	    $Gate[$ng][8]=$6;
	    $Gate[$ng][9]=$7;
	    $Gate[$ng][10]=$8;
	    $Gate[$ng][11]=$9;
	    $Gate[$ng][12]=$10;	 
	    $ng++;

        }
	elsif (/(.*) = NOR\((.*), (.*), (.*), (.*), (.*), (.*), (.*), (.*)\)/) {
		
  	    $Gate[$ng][0]="NOR";
	    $Gate[$ng][1]=0; # we store here configuration type i.e. 1, 2, or 3. 0 means not yet configured.
	    $Gate[$ng][2]=8; # we store here the number of inputs in a gate
	    $Gate[$ng][3]=$1;
	    $Gate[$ng][4]=$2;
	    $Gate[$ng][5]=$3;
	    $Gate[$ng][6]=$4;
	    $Gate[$ng][7]=$5;
	    $Gate[$ng][8]=$6;
	    $Gate[$ng][9]=$7;
	    $Gate[$ng][10]=$8;
	    $Gate[$ng][11]=$9;	    
	    $ng++;
        }
	elsif (/(.*) = NOR\((.*), (.*), (.*), (.*), (.*), (.*), (.*)\)/) {
		
  	    $Gate[$ng][0]="NOR";
	    $Gate[$ng][1]=0; # we store here configuration type i.e. 1, 2, or 3. 0 means not yet configured.
	    $Gate[$ng][2]=7; # we store here the number of inputs in a gate
	    $Gate[$ng][3]=$1;
	    $Gate[$ng][4]=$2;
	    $Gate[$ng][5]=$3;
	    $Gate[$ng][6]=$4;
	    $Gate[$ng][7]=$5;
	    $Gate[$ng][8]=$6;
	    $Gate[$ng][9]=$7;
	    $Gate[$ng][10]=$8;   
	    $ng++;
        }
	elsif (/(.*) = NOR\((.*), (.*), (.*), (.*), (.*), (.*)\)/) {
		
 	    $Gate[$ng][0]="NOR";
	    $Gate[$ng][1]=0; # we store here configuration type i.e. 1, 2, or 3. 0 means not yet configured.
	    $Gate[$ng][2]=6; # we store here the number of inputs in a gate
	    $Gate[$ng][3]=$1;
	    $Gate[$ng][4]=$2;
	    $Gate[$ng][5]=$3;
	    $Gate[$ng][6]=$4;
	    $Gate[$ng][7]=$5;
	    $Gate[$ng][8]=$6;
	    $Gate[$ng][9]=$7;
	    $ng++;
        }
 
	elsif (/(.*) = NOR\((.*), (.*), (.*), (.*), (.*)\)/) {
		
	    $Gate[$ng][0]="NOR";
	    $Gate[$ng][1]=0; # we store here configuration type i.e. 1, 2, or 3. 0 means not yet configured.
	    $Gate[$ng][2]=5; # we store here the number of inputs in a gate
	    $Gate[$ng][3]=$1;
	    $Gate[$ng][4]=$2;
	    $Gate[$ng][5]=$3;
	    $Gate[$ng][6]=$4;
	    $Gate[$ng][7]=$5;
	    $Gate[$ng][8]=$6;
	    $ng++;
        }

	 elsif (/(.*) = NOR\((.*), (.*), (.*), (.*)\)/) {
		
	    $Gate[$ng][0]="NOR";
	    $Gate[$ng][1]=0; # we store here configuration type i.e. 1, 2, or 3. 0 means not yet configured.
	    $Gate[$ng][2]=4; # we store here the number of inputs in a gate
	    $Gate[$ng][3]=$1;
	    $Gate[$ng][4]=$2;
	    $Gate[$ng][5]=$3;
	    $Gate[$ng][6]=$4;
	    $Gate[$ng][7]=$5;
	    $ng++;
        }
 
	elsif (/(.*) = NOR\((.*), (.*), (.*)\)/) {
		
	    $Gate[$ng][0]="NOR";
	    $Gate[$ng][1]=0; # we store here configuration type i.e. 1, 2, or 3. 0 means not yet configured.
	    $Gate[$ng][2]=3; # we store here the number of inputs in a gate
	    $Gate[$ng][3]=$1;
	    $Gate[$ng][4]=$2;
	    $Gate[$ng][5]=$3;
	    $Gate[$ng][6]=$4;
	    $ng++;
        }
        elsif (/(.*) = NOR\((.*), (.*)\)/) {
		
	    $Gate[$ng][0]="NOR";
	    $Gate[$ng][1]=0; # we store here configuration type i.e. 1, 2, or 3. 0 means not yet configured.
	    $Gate[$ng][2]=2; # we store here the number of inputs in a gate
	    $Gate[$ng][3]=$1;
	    $Gate[$ng][4]=$2;
	    $Gate[$ng][5]=$3;
	    $ng++;
        }


# Matching OR gates

	if (/(.*) = OR\((.*), (.*), (.*), (.*), (.*), (.*), (.*), (.*), (.*)\)/) {
		
	    $Gate[$ng][0]="OR";
	    $Gate[$ng][1]=0; # we store here configuration type i.e. 1, 2, or 3. 0 means not yet configured.
	    $Gate[$ng][2]=9; # we store here the number of inputs in a gate
	    $Gate[$ng][3]=$1;
	    $Gate[$ng][4]=$2;
	    $Gate[$ng][5]=$3;
	    $Gate[$ng][6]=$4;
	    $Gate[$ng][7]=$5;
	    $Gate[$ng][8]=$6;
	    $Gate[$ng][9]=$7;
	    $Gate[$ng][10]=$8;
	    $Gate[$ng][11]=$9;
	    $Gate[$ng][12]=$10;	 
	    $ng++;

        }
	elsif (/(.*) = OR\((.*), (.*), (.*), (.*), (.*), (.*), (.*), (.*)\)/) {
		
  	    $Gate[$ng][0]="OR";
	    $Gate[$ng][1]=0; # we store here configuration type i.e. 1, 2, or 3. 0 means not yet configured.
	    $Gate[$ng][2]=8; # we store here the number of inputs in a gate
	    $Gate[$ng][3]=$1;
	    $Gate[$ng][4]=$2;
	    $Gate[$ng][5]=$3;
	    $Gate[$ng][6]=$4;
	    $Gate[$ng][7]=$5;
	    $Gate[$ng][8]=$6;
	    $Gate[$ng][9]=$7;
	    $Gate[$ng][10]=$8;
	    $Gate[$ng][11]=$9;	    
	    $ng++;
        }
	elsif (/(.*) = OR\((.*), (.*), (.*), (.*), (.*), (.*), (.*)\)/) {
		
  	    $Gate[$ng][0]="OR";
	    $Gate[$ng][1]=0; # we store here configuration type i.e. 1, 2, or 3. 0 means not yet configured.
	    $Gate[$ng][2]=7; # we store here the number of inputs in a gate
	    $Gate[$ng][3]=$1;
	    $Gate[$ng][4]=$2;
	    $Gate[$ng][5]=$3;
	    $Gate[$ng][6]=$4;
	    $Gate[$ng][7]=$5;
	    $Gate[$ng][8]=$6;
	    $Gate[$ng][9]=$7;
	    $Gate[$ng][10]=$8;   
	    $ng++;
        }
	elsif (/(.*) = OR\((.*), (.*), (.*), (.*), (.*), (.*)\)/) {
		
 	    $Gate[$ng][0]="OR";
	    $Gate[$ng][1]=0; # we store here configuration type i.e. 1, 2, or 3. 0 means not yet configured.
	    $Gate[$ng][2]=6; # we store here the number of inputs in a gate
	    $Gate[$ng][3]=$1;
	    $Gate[$ng][4]=$2;
	    $Gate[$ng][5]=$3;
	    $Gate[$ng][6]=$4;
	    $Gate[$ng][7]=$5;
	    $Gate[$ng][8]=$6;
	    $Gate[$ng][9]=$7;
	    $ng++;
        }
 
	elsif (/(.*) = OR\((.*), (.*), (.*), (.*), (.*)\)/) {
		
	    $Gate[$ng][0]="OR";
	    $Gate[$ng][1]=0; # we store here configuration type i.e. 1, 2, or 3. 0 means not yet configured.
	    $Gate[$ng][2]=5; # we store here the number of inputs in a gate
	    $Gate[$ng][3]=$1;
	    $Gate[$ng][4]=$2;
	    $Gate[$ng][5]=$3;
	    $Gate[$ng][6]=$4;
	    $Gate[$ng][7]=$5;
	    $Gate[$ng][8]=$6;
	    $ng++;
        }

	 elsif (/(.*) = OR\((.*), (.*), (.*), (.*)\)/) {
		
	    $Gate[$ng][0]="OR";
	    $Gate[$ng][1]=0; # we store here configuration type i.e. 1, 2, or 3. 0 means not yet configured.
	    $Gate[$ng][2]=4; # we store here the number of inputs in a gate
	    $Gate[$ng][3]=$1;
	    $Gate[$ng][4]=$2;
	    $Gate[$ng][5]=$3;
	    $Gate[$ng][6]=$4;
	    $Gate[$ng][7]=$5;
	    $ng++;
        }
 
	elsif (/(.*) = OR\((.*), (.*), (.*)\)/) {
		
	    $Gate[$ng][0]="OR";
	    $Gate[$ng][1]=0; # we store here configuration type i.e. 1, 2, or 3. 0 means not yet configured.
	    $Gate[$ng][2]=3; # we store here the number of inputs in a gate
	    $Gate[$ng][3]=$1;
	    $Gate[$ng][4]=$2;
	    $Gate[$ng][5]=$3;
	    $Gate[$ng][6]=$4;
	    $ng++;
        }
        elsif (/(.*) = OR\((.*), (.*)\)/) {
		
	    $Gate[$ng][0]="OR";
	    $Gate[$ng][1]=0; # we store here configuration type i.e. 1, 2, or 3. 0 means not yet configured.
	    $Gate[$ng][2]=2; # we store here the number of inputs in a gate
	    $Gate[$ng][3]=$1;
	    $Gate[$ng][4]=$2;
	    $Gate[$ng][5]=$3;
	    $ng++;
        }
              
       
     
}


# Associating gate names with indixes

for ($i=1; $i<$ng; $i++){
				
	$Index{$Gate[$i][3]}=$i;
		
}



# Generating TMR logic

# Generating Inputs

print "Number of inputs=$ni \n";
for ($i=0; $i<$ni; $i++){
	print OUT "INPUT($Input[$i])\n";
}

print OUT "\n";

# Generating Outputs

#computing proper output signals
#print "tout=$tout \n";

for ($i=0; $i<$tout; $i++){
	$outn=$TOUT[$i];
                  # print "1\n";
	if ($flago{$outn}!=1){	
	    	$flago{$outn}=1;          	
		
		if ($flag{$outn}==1){		
			$INOUT[$ino]=$outn;
			$ino++;
			print OUT "OUTPUT(IO".$outn.")\n";
		} 
		else {		
			print OUT "OUTPUT(".$outn.")\n";			
			
			#######################################################################
			#Uncomment the following lines for protected voter.
			#######################################################################
			#print OUT $outn." = MAJ(".$outn."_1, ".$outn."_2, ".$outn."_3) \n";
			# print OUT $outn." = QMAJ(".$outn."_1, ".$outn."_2, ".$outn."_3) \n";
			#######################################################################
			
			#######################################################################
			#Uncomment the following lines for un-protected voter.
			#######################################################################
			print OUT $outn."_4 = NAND(".$outn."_1, ".$outn."_2) \n";
			print OUT $outn."_5 = NAND(".$outn."_1, ".$outn."_3) \n";
			print OUT $outn."_6 = NAND(".$outn."_2, ".$outn."_3) \n";
			print OUT $outn." = NAND(".$outn."_4, ".$outn."_5, ".$outn."_6) \n";
			#######################################################################
		}	    
	}
}	

# Generating BUFF gates for inout signals

print "Number of inout signals = $ino \n";

for ($i=0; $i<$ino; $i++) {
		print OUT "IO".$INOUT[$i]." = BUFF(".$INOUT[$i].") \n"; 
							
#		print OUT "IO".$INOUT[$i]."_g1 = BUFF(".$INOUT[$i].") \n"; 
#		print OUT "IO".$INOUT[$i]."_g2 = BUFF(".$INOUT[$i].") \n"; 	
#		print OUT "IO".$INOUT[$i]."_g3 = BUFF(".$INOUT[$i].") \n"; 
#		print OUT $INOUT[$i]."_g4 = QAND(".$INOUT[$i]."_g1, ".$INOUT[$i]."_g2) \n";
#		print OUT $INOUT[$i]."_g5 = QAND(".$INOUT[$i]."_g1, ".$INOUT[$i]."_g3) \n";
#		print OUT $INOUT[$i]."_g6 = QAND(".$INOUT[$i]."_g2, ".$INOUT[$i]."_g3) \n";
#		print OUT $INOUT[$i]." = QOR(".$INOUT[$i]."_g4, ".$INOUT[$i]."_g5, ".$INOUT[$i]."_g6) \n";
#
}

for ($i=1; $i<$ng; $i++){

	if ($Gate[$i][2]>0) {
	for ($k=1; $k<=3; $k++){
   	
		 print OUT $Gate[$i][3]."_$k = $Gate[$i][0]"."(";
		 for ($j=0; $j<$Gate[$i][2]; $j++){

			$ig = $Index{$Gate[$i][4+$j]};				
			if ($Gate[$ig][0] eq "INPUT"){
					if ($j==($Gate[$i][2]-1)){
						print OUT  $Gate[$i][4+$j].")\n";
					}
					else {
						print OUT  $Gate[$i][4+$j].", ";
					}
				}
				else {
					if ($j==($Gate[$i][2]-1)){
						print OUT  $Gate[$i][4+$j]."_$k)\n";
					}
					else {
						print OUT  $Gate[$i][4+$j]."_$k, ";
					}
				}							
			}			
		}
		
		
		#print QMAJ voter at its correct location.
		# if (grep {$_ eq $Gate[$i][3]} @TOUT) {
			# print OUT $Gate[$i][3]." = QMAJ(".$Gate[$i][3]."_1, ".$Gate[$i][3]."_2, ".$Gate[$i][3]."_3) \n";			
		# }
		print OUT "\n";
	}
}

close(IN);
close(OUT);

system("perl sortg.pl $circuit"."_tmr");
        


$end=time;
$diff = $end - $start;

print "Number of gates= ".($ng-$ni)." \n";
print "Execution time is $diff seconds \n";


