#! /usr/bin/perl -w
use Cwd;

$start = time;
$cwd = getcwd; #get Current Working Directory

# @threshold1  = qw (0.1 0.05 0.02 0.01 0.001);
# @threshold2  = qw (0.25 0.5 0.75 1 2);

# @circuits = qw (	alu4
					# apex1
					# apex2
					# apex3
					# apex4
					# b12
					# con1
					# clip
					# cordic
					# ex5
					# misex1					
					# misex2					
					# misex3
					# rd84	
					# seq
					# squar5
					# table3
					# table5
					# z5xp1					
			   # );
@circuits = qw (	alu4
					apex1
					apex2
					apex3
					apex4			
					clip
					cordic
					ex5							
					misex2					
					misex3
					rd84	
					seq					
					table3
					table5									
			   );
			   
			   # bench1
					# cps
					# duke2
					# ex101
					# exp
					# m3
					# spla
					# test1
			   
		
# @outputs = qw (8 45 3 50 19 9 5 2 63 7 18 14 4 35 8 14 15 10);
# @inputs = qw (14 45 39 54 9 15 9 23 8 8 25 14 8 41 5 14 17 7);
@inputs = qw (14 45 39 54 9 9 23 8 25 14 8 41 14 17);


%majPhase = (   'alu4'		=> '11111110',
                'apex1' 	=> '000000000000000000000000000000000000100000000',
                'apex2' 	=> '000',
                'apex3' 	=> '00000000000000000000000000000000000000000000000000', 
                'apex4' 	=> '0000000000000000000', 
                'b12'		=> '000111011', 
                'con1'		=> '01', 
                'clip'		=> '11111', 
                'cordic'	=> '10', 
                'ex5' 		=> '000000000000000000000000000000011111111111111111111111111111111',              
                'misex1' 	=> '0000100', 
                'misex2' 	=> '000000000000000000', 
                'misex3' 	=> '00000000000001', 
                'rd84' 		=> '0101', 
                'seq' 		=> '00000000000000000000010000000000010', 
                'squar5' 	=> '00000000', 
                'table3' 	=> '00000000000000', 
                'table5' 	=> '000000000000000', 
                'z5xp1' 	=> '0001111111'				
            );
			
				# 'bench1'	=> '000000000',
					# 'cps'		=>	'0000000000000000000000010000000000000000000000000000000000000000000000000000000000000000010000000000000000000',
					# 'duke2'		=>	'00000000000000000000000000000',
					# 'ex1010'	=>	'1001111011',
					# 'exp'		=>	'000000000000000000',
					# 'm3'		=>	'0000000000000000',
					# 'spla'		=>	'0000000000000000000000000000000000000000000000',
					# 'test1'		=>	'0000000000'

open (TRACE, ">phaseArea.dat") or die $!;
print TRACE "DMR Phase Area ... \n\n";
	
foreach $i (0..scalar @circuits - 1) {		

	$fileName = "$circuits[$i].pla";	
	print "Processing $circuits[$i]...\n";
	
	system("perl dmr.pl $fileName p $majPhase{$circuits[$i]}");
		
	# system("perl dmr.pl $fileName");
	system("perl gen_rnd_vecs.pl $inputs[$i] $circuits[$i]");
	system("hope -t $circuits[$i].test $circuits[$i].bench -l $circuits[$i].log");	
	system("perl outputStats4mHope.pl $circuits[$i]"); next;
	
	# system("perl bench_to_spice_130nm.pl $circuits[$i]_MAJ 1");	
	
	##Read area from file
	open(AR, "area.sp") or die $!;
	while (<AR>) {
		chomp;
		$area1 = $_;			
	}
	close (AR);
	print TRACE "$area1\n";
	
	# @currentPhase1 = ();
	# @currentPhase2 = ();
	
	# ###########################
	# # Construct initial phase
	# ###########################
	# foreach $l (0..$outputs[$i]-1) {
		# $currentPhase1[$l] = 1;
	# }
			
	# foreach $k (0..$outputs[$i]-1) {		
		
		# ####
		# #Apply the current Phase
		# $ph1 = join('', @currentPhase1);
		# system("perl dmr.pl $fileName p $min_phase[$i]");
		# system("perl bench_to_spice_45nm.pl $circuits[$i]");
		
		# $area1 = 0;
		# $area2 = 0;
		
		#Read area from file
		# open(AR, "area.sp") or die $!;
		# while (<AR>) {
			# chomp;
			# $area1 = $_;			
		# }
		# close (AR);
		# #####################################
		
		# ##############################
		# #Apply phase 2
		# ##############################
		# @currentPhase2 = @currentPhase1;
		# $currentPhase2[$k] = 0;
		# $ph2 = join('', @currentPhase2);
		# system("perl dmr.pl $fileName p $ph2");
		# system("perl bench_to_spice_45nm.pl $circuits[$i]");
		
		# #Read area from file
		# open(AR, "area.sp") or die $!;
		# while (<AR>) {
			# chomp;
			# $area2 = $_;			
		# }
		# close (AR);
		# #####################################
				
		# if ($area2 < $area1 ) {
			# @currentPhase1 = @currentPhase2;
			# print TRACE "$ph2 $area2\n";
		# }			
		# else {
			# print TRACE "$fileName $area1\n";
		# }
		# # print "Next Phase $ph1\n";		
		
	# }
	
	# system("hope -r 100000 $fileName.bench -l $fileName.log");	
	# system("perl outputStats4mHope.pl $fileName");
		
	# print "\n---Processing $circuits[$i]...";
	# system("perl integrated-algos.pl $circuits[$i].faults");	
	
	# system("perl bench_to_spice_45nm.pl $circuits[$i]");	
}
close (TRACE);

system ("rm -rf *_min.pla");
system ("rm -rf *STATS");
system ("rm -rf *.sp");
system ("rm -rf *.DAT");
system ("rm -rf *.script");
# system ("rm -rf *WP.bench");

$end = time;
$diff = $end - $start;
print "---Time taken by Conversion Process = $diff \n";
				
	