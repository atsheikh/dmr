#! /usr/bin/perl 

###############################################################
#                                                             #
# Description: A perl script to print input/output ports first#
#                                                             #
#                                                             #
# Author: Aiman H. El-Maleh (KFUPM)                           #
#                                                             #
# Date: August 22, 2006.                                      #
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
open(OUT,">$circuit"."_tmp.bench") || die " Cannot open input file $circuit"."_tmp.bench \n";




$ng = 0;


while(<IN>){
   
#        print $_;

# Matching Inputs
   
	if (/INPUT\((.*)\)/) {          
            $Gate[$ng][0]="INPUT";
	    $Gate[$ng][1]=0; # we store here if the gate is eliminated or not
	    $Gate[$ng][2]=0; # Number of inputs
	    $Gate[$ng][3]=$1;
	    $FC[$ng]=0; #we stoare here the no. of fanout
	    $ng++;				           
         }

# Matching Outputs

	if (/OUTPUT\((.*)\)/) {
	    $Gate[$ng][0]="OUTPUT";
	    $Gate[$ng][1]=0; # we store here if the gate is eliminated or not
	    $Gate[$ng][2]=0; # Number of inputs
	    $Gate[$ng][3]=$1;	   
	    $ng++;		           
         }




# Matching NOT gates

       if (/(.*) = NOT\((.*)\)/) {
				
	    $Gate[$ng][0]="NOT";
	    $Gate[$ng][1]=0; # we store here configuration type i.e. 1,2,or 3. 0 means not yet configured.
	    $Gate[$ng][2]=1; # Number of inputs	   
	    $Gate[$ng][3]=$1;
	    $Gate[$ng][4]=$2;
	    $ng++;
        }

# Matching BUFF gates

       if (/(.*) = BUFF\((.*)\)/) {
				
	    $Gate[$ng][0]="BUFF";
	    $Gate[$ng][1]=0; # we store here configuration type i.e. 1,2,or 3. 0 means not yet configured.
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
	    $Gate[$ng][1]=0; # we store here configuration type i.e. 1, 2,or 3. 0 means not yet configured.
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

	if (/(.*) = OR\((.*), (.*), (.*), (.*), (.*), (.*), (.*), (.*), (.*)\)/)
	{
		
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
	    $Gate[$ng][1]=0; # we store here configuration type i.e. 1, 2,or 3. 0 means not yet configured.
	    $Gate[$ng][2]=2; # we store here the number of inputs in a gate
	    $Gate[$ng][3]=$1;
	    $Gate[$ng][4]=$2;
	    $Gate[$ng][5]=$3;
	    $ng++;
        }    

# Matching QAND gates

        if (/(.*) = QAND\((.*), (.*)\)/) {
		
	    $Gate[$ng][0]="QAND";
	    $Gate[$ng][1]=0; # we store here configuration type i.e. 1, 2,or 3. 0 means not yet configured.
	    $Gate[$ng][2]=2; # we store here the number of inputs in a gate
	    $Gate[$ng][3]=$1;
	    $Gate[$ng][4]=$2;
	    $Gate[$ng][5]=$3;
	    $ng++;
        }   
		
# Matching QOR gates

	if (/(.*) = QOR\((.*), (.*), (.*), (.*), (.*), (.*), (.*), (.*), (.*)\)/)
	{
		
	    $Gate[$ng][0]="QOR";
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
	elsif (/(.*) = QOR\((.*), (.*), (.*), (.*), (.*), (.*), (.*), (.*)\)/) {
		
  	    $Gate[$ng][0]="QOR";
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
	elsif (/(.*) = QOR\((.*), (.*), (.*), (.*), (.*), (.*), (.*)\)/) {
		
  	    $Gate[$ng][0]="QOR";
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
	elsif (/(.*) = QOR\((.*), (.*), (.*), (.*), (.*), (.*)\)/) {
		
 	    $Gate[$ng][0]="QOR";
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
 
	elsif (/(.*) = QOR\((.*), (.*), (.*), (.*), (.*)\)/) {
		
	    $Gate[$ng][0]="QOR";
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

	 elsif (/(.*) = QOR\((.*), (.*), (.*), (.*)\)/) {
		
	    $Gate[$ng][0]="QOR";
	    $Gate[$ng][1]=0; # we store here configuration type i.e. 1, 2, or 3. 0 means not yet configured.
	    $Gate[$ng][2]=4; # we store here the number of inputs in a gate
	    $Gate[$ng][3]=$1;
	    $Gate[$ng][4]=$2;
	    $Gate[$ng][5]=$3;
	    $Gate[$ng][6]=$4;
	    $Gate[$ng][7]=$5;
	    $ng++;
        }
 
	elsif (/(.*) = QOR\((.*), (.*), (.*)\)/) {
		
	    $Gate[$ng][0]="QOR";
	    $Gate[$ng][1]=0; # we store here configuration type i.e. 1, 2, or 3. 0 means not yet configured.
	    $Gate[$ng][2]=3; # we store here the number of inputs in a gate
	    $Gate[$ng][3]=$1;
	    $Gate[$ng][4]=$2;
	    $Gate[$ng][5]=$3;
	    $Gate[$ng][6]=$4;
	    $ng++;
        }
        elsif (/(.*) = QOR\((.*), (.*)\)/) {
		
	    $Gate[$ng][0]="QOR";
	    $Gate[$ng][1]=0; # we store here configuration type i.e. 1, 2,or 3. 0 means not yet configured.
	    $Gate[$ng][2]=2; # we store here the number of inputs in a gate
	    $Gate[$ng][3]=$1;
	    $Gate[$ng][4]=$2;
	    $Gate[$ng][5]=$3;
	    $ng++;
        }   
		
		# Matching MAJ gates

        if (/(.*) = MAJ\((.*), (.*), (.*)\)/) {
		
	    $Gate[$ng][0]="MAJ";
	    $Gate[$ng][1]=0; # we store here configuration type i.e. 1, 2,or 3. 0 means not yet configured.
	    $Gate[$ng][2]=3; # we store here the number of inputs in a gate
	    $Gate[$ng][3]=$1;
	    $Gate[$ng][4]=$2;
	    $Gate[$ng][5]=$3;
		$Gate[$ng][6]=$4;
	    $ng++;
        }   
		
		# Matching QMAJ gates

        if (/(.*) = QMAJ\((.*), (.*), (.*)\)/) {
		
	    $Gate[$ng][0]="QMAJ";
	    $Gate[$ng][1]=0; # we store here configuration type i.e. 1, 2,or 3. 0 means not yet configured.
	    $Gate[$ng][2]=3; # we store here the number of inputs in a gate
	    $Gate[$ng][3]=$1;
	    $Gate[$ng][4]=$2;
	    $Gate[$ng][5]=$3;
		$Gate[$ng][6]=$4;
	    $ng++;
        }

		# Matching MV gates

        if (/(.*) = MV\((.*), (.*), (.*)\)/) {
		
	    $Gate[$ng][0]="MV";
	    $Gate[$ng][1]=0; # we store here configuration type i.e. 1, 2,or 3. 0 means not yet configured.
	    $Gate[$ng][2]=3; # we store here the number of inputs in a gate
	    $Gate[$ng][3]=$1;
	    $Gate[$ng][4]=$2;
	    $Gate[$ng][5]=$3;
		$Gate[$ng][6]=$4;
	    $ng++;
        }		
}
close(IN);

print OUT "\n";
#generating inputs
for ($i=0; $i<$ng; $i++){
	if ($Gate[$i][0] eq "INPUT"){
		print OUT "INPUT(".$Gate[$i][3].")\n";
	}
}

print OUT "\n";
# generating outputs
for ($i=0; $i<$ng; $i++){
	if ($Gate[$i][0] eq "OUTPUT"){
		print OUT "OUTPUT(".$Gate[$i][3].")\n";
	}
}

print OUT "\n";
#Generating gates
for ($i=0; $i<$ng; $i++){
	if ($Gate[$i][2]>0) {		   	
		print OUT $Gate[$i][3]." = $Gate[$i][0]"."(";
		for ($j=0; $j<$Gate[$i][2]; $j++){											
			if ($j==($Gate[$i][2]-1)){
				print OUT  $Gate[$i][4+$j].") \n";
			}
			else {
				print OUT  $Gate[$i][4+$j].", ";
			}													
		}		
	}	
}
        

close(OUT);
system("move $circuit"."_tmp.bench $circuit".".bench");
$end=time;
$diff = $end - $start;
#print "Execution time is $diff seconds \n";




