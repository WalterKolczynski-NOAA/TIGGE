#!/usr/bin/perl -w

use ncdcTigge 1.1;
use NcdcNomads;

my $daysToCheck = shift(@ARGV);
if( ! $daysToCheck ) { $daysToCheck = 7; }

my $cycleSecs = 21600;

my $now = time - ($cycleSecs*2);
my $secsBack = $now - (86400*$daysToCheck);

my $rectifyStart = int($secsBack / $cycleSecs) * $cycleSecs;
my $rectifyNow   = int($now / $cycleSecs) * $cycleSecs;

my $cycleStart = NcdcNomads::timeToDateString( $rectifyStart, 4 );
my $cycleNow = NcdcNomads::timeToDateString( $rectifyNow, 4 );

#                        NcdcNomads::addTime( $dtg,6,"hour" ), 3);


my $looper = $rectifyStart;
my $recoverNum = 0;
while( $looper <= $rectifyNow ) 
	{
	$looper += $cycleSecs;
	my $thisCycle = NcdcNomads::timeToDateString( $looper, 3 );
	print STDOUT " >> $thisCycle ";
		# this does the scan.
	my $tmp0 = ncdcTigge::ncepNomadsBackupSource($thisCycle);
	my @tmp = $tmp0 =~ m/\( ok (\d*) \/ not ok (\d*) \) recovered (\d*)/;

	if( defined($tmp[2]) ) 
		{ 
		print STDOUT " [@tmp]\n";
		$recoverNum += $tmp[2]; 
		}
	else 
		{
	#	$recoverNum += int(ncdcTigge::ncepNomadsBackupSource($thisCycle));
		print STDOUT " : Message \"$tmp0\" \n";
		}

	}

my $finish = time;
my $ET = $now - $finish;
print "\n\n$0 Completed.  Recovered $recoverNum file units in $ET secs\n\n";


exit 0;
