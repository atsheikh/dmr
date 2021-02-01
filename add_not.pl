###############################################################
#                                                             #
# Description: A perl script to add additional NOT to each 	  #
# cone and add latches output as primary output               #
#                                                             #
# Author: Ayed S Al-Qahtani (KFUPM)                           #
#                                                             #
# Date: Nov 10, 2009.                                         #
#                                                             #
###############################################################



#************************************************************************
#                                                                       *
#    Main Program                                                       *
#                                                                       *
#************************************************************************

#-------------------------------------------------------------#
#            Constants and variables declarations             #
#-------------------------------------------------------------#
$latch_count=0;
$out_count =0;
$Input_latch_count=0;
$Not_Input_latch_count=0; # Not gate counter if the input of the Not gate is primary input or a lactch output.

$Seprator_index=0;
$number_of_sperator =0; # number of points that define the parsing points of the file
$number_of_latches =0;
$start_duplicate=0; #store index in which you duplicate after it.

$ng=0;
#-------------------------------------------------------------#
#    Assigning the test bench                                 #
#-------------------------------------------------------------#
$circuit = $ARGV[0] || die "No circuit name specified";


#-----------------------------------------------------------------------------#
#   find the seperators between the cones								  	  #
#	Find all NOT gates in which thier input is primary input or a latch       #
#	find the latches														  #
#-----------------------------------------------------------------------------#
open(IN,"$circuit".".bench") || die " Cannot open input file $circuit".".bench \n";
while(<IN>){
	#-------------------#
	# Matching Inputs	#
	#-------------------#
   	if (/INPUT\((.*)\)/) {  
		$Input_latch[$Input_latch_count] = $1;
		$Input_latch_count++;
         }
	#-------------------#
	# Matching Outputs  #
	#-------------------#
	if (/OUTPUT\((.*)\)/) {
		if($1 =~ m/^latch/i)
		{
			;  # dont add tmr
		}
		else
		{ 
			$Sperator[$Seprator_index]= $1;# add tmr
			$Seprator_index++;
			$number_of_sperator++;
			$out_count ++;
		}	
    }
	#----------------------#
	# Matching DFF gates   #
	#----------------------#
    if (/(.*) = DFF\((.*)\)/) {
		$Sperator[$Seprator_index]= $2; 
		$Seprator_index++;
		$number_of_sperator++;
		$number_of_latches ++;
		
		$Input_latch[$Input_latch_count] = $1;
		$Input_latch_count++;
		
		$latches[$latch_count] = $1;
		$latch_count++;
		}
	#-------------------#
	# Matching NOT gates#
	#-------------------#
    if (/(.*) = NOT\((.*)\)/) {
	    for ($m=0; $m < $Input_latch_count; $m++){
				if ($2 eq $Input_latch[$m])
					{
						$Not_Input_latch[$Not_Input_latch_count][0] = $1;
						$Not_Input_latch[$Not_Input_latch_count][1] = $2;
						$Not_Input_latch[$Not_Input_latch_count][2] = 0;
						$Not_Input_latch_count++;
					}
				}
        }
}

#for ($m=0; $m < $Not_Input_latch_count; $m++){
#			print	$Not_Input_latch[$m][0]."\t";
#			print	$Not_Input_latch[$m][2]."\n";
#}
		
#for ($m=0; $m <= $number_of_sperator; $m++){
#	print "$Sperator[$m]\n";
#	}
close(IN); 
#-----------------------------------------------------------------------------------------#
#            Parsing the input file and counting number of gates.						  #
# 			 Primary input and primary output are considered gates.			              #
#-----------------------------------------------------------------------------------------#
open(IN,"$circuit".".bench") || die " Cannot open input file $circuit".".bench \n";

while(<IN>){

	#-------------------#
	# Matching Inputs	#
	#-------------------#
   	if (/INPUT\((.*)\)/) {  
		
        $Gate[$ng][0]="INPUT";
	    $Gate[$ng][1]=0; # we store here if the gate is eliminated or not
	    $Gate[$ng][2]=0; # Number of inputs
	    $Gate[$ng][3]=$1;
	    $ng++;				           
         }
	#-------------------#
	# Matching Outputs  #
	#-------------------#
	if (/OUTPUT\((.*)\)/) {
		
	    $Gate[$ng][0]="OUTPUT";
	    $Gate[$ng][1]=0; # we store here if the gate is eliminated or not
	    $Gate[$ng][2]=0; # Number of inputs
	    $Gate[$ng][3]=$1;	
	    $ng++;		           
         }
	#-------------------#
	# Matching NOT gates#
	#-------------------#
    if (/(.*) = NOT\((.*)\)/) {
				
	    $Gate[$ng][0]="NOT";
	    $Gate[$ng][1]=0; # we store here configuration type i.e. 1, 2, or 3. 0 means not yet configured.
	    $Gate[$ng][2]=1; # Number of inputs	   
	    $Gate[$ng][3]=$1;
	    $Gate[$ng][4]=$2;
	    $ng++;
        }
	#----------------------#
	# Matching BUF gates  #
	#----------------------#
    if (/(.*) = BUF\((.*)\)/) {
				
	    $Gate[$ng][0]="BUF";
	    $Gate[$ng][1]=0; # we store here configuration type i.e. 1, 2, or 3. 0 means not yet configured.
	    $Gate[$ng][2]=1; # Number of inputs	   
	    $Gate[$ng][3]=$1;
	    $Gate[$ng][4]=$2;
	    $ng++;
        }
		
	#----------------------#
	# Matching DFF gates   #
	#----------------------#
    if (/(.*) = DFF\((.*)\)/) {
				
	    $Gate[$ng][0]="DFF";
	    $Gate[$ng][1]=0; # we store here configuration type i.e. 1, 2, or 3. 0 means not yet configured.
	    $Gate[$ng][2]=1; # Number of inputs	   
	    $Gate[$ng][3]=$1;
	    $Gate[$ng][4]=$2;
	    $ng++;
        }
	#--------------------------------------------------#
	# Matching NAND gates from 9-in nand to 2-in nand  #
	#--------------------------------------------------#
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

	#---------------------------------------------------#		
	# Matching AND gates from 9-in and to 2-in and		#
	#---------------------------------------------------#
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
	#-------------------------------------------------#	
    # Matching NOR gates from 9-in nor to 2-in nor	  #
	#-------------------------------------------------#	
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
    #-------------------------------------------------#	
	# Matching OR gates 9-in or to 2-in or			  #
	#-------------------------------------------------#	
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
close(IN);
#------------------------------------------------------------------------------------------------#
# Generate NOT for each cone if it used in the cone and it was for primary input or latches      #
#------------------------------------------------------------------------------------------------#
$circuit1 = $circuit;
$circuit1 =~ s/.kiss2/_/i;   
open(OUT,">$circuit"."n.bench") or die "cannot open $circuit"."n.bench\n";
$first_out =0;
print OUT "\n";
for ($i=0; $i<$ng ; $i++){
		
		#-----------#	
		# INPUT		#
		#-----------#
		if(($Gate[$i][0] cmp "INPUT" ) == 0 ) 
		{
			print OUT "INPUT($Gate[$i][3])\n";
		}
		#-----------#	
		# Output	#
		#-----------#
		elsif(($Gate[$i][0] cmp "OUTPUT" ) == 0)
		{
			if($first_out == 0)
			{
				for($iii=0 ; $iii < $latch_count; $iii++)
				{
#				print OUT "OUTPUT($latches[$iii])\n";
				}
				print OUT "OUTPUT($Gate[$i][3])\n";
				$first_out = 1
			}
			else
			{
				print OUT "OUTPUT($Gate[$i][3])\n";
			}
			
		}
		#-------#	
		# DFF   #
		#-------#
		elsif(($Gate[$i][0] cmp "DFF" ) == 0)  #($Gate[$i][0] cmp "BUF" ) == 0 ||
		{
			print OUT "$Gate[$i][3] = $Gate[$i][0]($Gate[$i][4])\n";
		}
		else
		{
			$found_sep=0;
			for ($m=0; $m < $number_of_sperator; $m++){
				if ($Gate[$i][3] eq $Sperator[$m])
					{
						$found_sep=1;
					}
			}
			if($found_sep == 0)
			{
				#---------------------------#	
				#  NOT						#
				#---------------------------#
				if(($Gate[$i][0] cmp "NOT" ) == 0 || ($Gate[$i][0] cmp "BUF" ) == 0)
				{
					print OUT "$Gate[$i][3] = $Gate[$i][0]($Gate[$i][4])\n";
				}
				#---------------------------#	
				#  NAND || AND || NOR || OR	#
				#---------------------------#
				elsif( ($Gate[$i][0] cmp "NAND" ) == 0 || ($Gate[$i][0] cmp "OR" ) == 0 ||
					($Gate[$i][0] cmp "AND" ) == 0 || ($Gate[$i][0] cmp "NOR" ) == 0  )    
				{
					print OUT "$Gate[$i][3] = $Gate[$i][0](";
					$m=0;
					for ( ; $m < ($Gate[$i][2] -1) ; $m++) 
					{
						print OUT "$Gate[$i][$m+4]".", ";
					}
					print OUT "$Gate[$i][$m+4]".")\n";
				}	
			}
			else
			{
				#---------------------------#	
				#  NOT						#
				#---------------------------#
				if(($Gate[$i][0] cmp "NOT" ) == 0 || ($Gate[$i][0] cmp "BUF" ) == 0)
				{
					print OUT "$Gate[$i][3] = $Gate[$i][0]($Gate[$i][4])\n";
				}
				#---------------------------#	
				#  NAND || AND || NOR || OR	#
				#---------------------------#
				elsif( ($Gate[$i][0] cmp "NAND" ) == 0 || ($Gate[$i][0] cmp "OR" ) == 0 ||
					($Gate[$i][0] cmp "AND" ) == 0 || ($Gate[$i][0] cmp "NOR" ) == 0  )    
				{
					print OUT "$Gate[$i][3] = $Gate[$i][0](";
					$m=0;
					for ( ; $m < ($Gate[$i][2] -1) ; $m++) 
					{
						print OUT "$Gate[$i][$m+4]".", ";
					}
					print OUT "$Gate[$i][$m+4]".")\n";
				}
				
				#reset all $Not_Input_latch[$m][3].
				print OUT "\n";
				for ($m=0; $m < $Not_Input_latch_count; $m++)
				{
					$Not_Input_latch[$m][3] = 0;
				}
				
				
				$next_seperator_found = 0;
				for ($j=$i+1; $j< $ng && $next_seperator_found == 0 ; $j++){ # check next gates in the same cone
					for ($l=0; $l < ($Gate[$j][2]) ; $l++){	# check each input of the current gate
						 for ($m=0; $m < $Not_Input_latch_count; $m++) # match each input with each NOT
						{
							if($Gate[$j][$l+4] eq $Not_Input_latch[$m][0] ){
								$Gate[$j][$l+4] = $Gate[$j][$l+4]."_n"."$Not_Input_latch[$m][2]"."$m"; 
								$Not_Input_latch[$m][3] = 1;
							}
						}
					}
					#print "\t";
					#print $Gate[$j][3];
					for ($k=0; $k < $number_of_sperator; $k++){
						if($Gate[$j][3] eq $Sperator[$k])
						{
							$next_seperator_found = 1;
							#print "\t";
							#print $Gate[$j][3];
							#print "\n";
						}
						
					}
				}
				
				# be sure duplicate NOT gates is not in the next gates of the same cone
				$next_seperator_found = 0;
				for ($j=$i+1; $j< $ng && $next_seperator_found == 0 ; $j++){ # check next gates in the same cone
					for ($m=0; $m < $Not_Input_latch_count; $m++){ # match each input with each NOT
						if($Gate[$j][3] eq $Not_Input_latch[$m][0])
						{
						$Gate[$j][$3] = $Gate[$j][$3]."_n"."$Not_Input_latch[$m][2]"."$m "; 
						#	$Not_Input_latch[$m][3] = 0;
						}
					}
					
					for ($k=0; $k < $number_of_sperator; $k++){
						if($Gate[$j][3] eq $Sperator[$k])
						{
							$next_seperator_found = 1;
						}
					}
				}
				
				for ($m=0; $m < $Not_Input_latch_count; $m++)
				{
					if($Not_Input_latch[$m][3] == 1)
					{
						print OUT	"$Not_Input_latch[$m][0]"."_n"."$Not_Input_latch[$m][2]"."$m = NOT($Not_Input_latch[$m][1])\n";
					}
					$Not_Input_latch[$m][2]++;
				}
				
			}
		}
	}
print OUT "END\n";
close OUT;
