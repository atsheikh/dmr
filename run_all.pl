#! /usr/bin/perl -w
use Cwd;

$start = time;
$cwd = getcwd; #get Current Working Directory

@circuits = qw (	
s1238f_IMP60
s1423f_IMP77
s1488f_IMP28
s1494f_IMP65
s298f_IMP4
s344f_IMP4
s386f_IMP10
s444f_IMP21
s510f_IMP29
s641f_IMP8
s713f_IMP16
s953f_IMP45
			   );
			   
	
foreach $i (0..scalar @circuits - 1) {		

	# print "\nProcessing $circuits[$i]...\n";
	# system("perl convert2Blif.pl $circuits[$i]");				
	system("perl convert2eqn.pl $circuits[$i]");				
	# system("perl bench_to_spice_130nm.pl $circuits[$i]");				
	
}

$end = time;
$diff = $end - $start;
print "---Time taken by Conversion Process = $diff \n";
				
	