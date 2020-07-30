#!/usr/bin/perl -w
#
#	Invokes the ncdcTigge::runLatest subroutine for ARG-1 (positive int) 
#		cycles.  if ARG-1 is negative, only runs cleanup on input
#	* Processes the latested complete cycle of GENS input
#	Checks output for problems
#

$| = 1;

if( !(scalar grep(/$ENV{'TIGGE_TOOLS'}\/bin/,@INC)) )
    { push(@INC,"$ENV{'TIGGE_TOOLS'}/bin"); }

use ncdcTigge 1.4 qw(runLatest cleanupLocation);

#print(`echo "System Call test ok."`);

my $startTime = time;
# -- where the action happens --
print STDOUT ncdcTigge::runCycle( $ARGV[0] );

print STDOUT "\n\n=============================================================\n\n";

$| = 0;
my $endTime = time;
my $elapsedTime = $endTime - $startTime;
print "\n\n$0: Finished.  $elapsedTime sec.\n\n";

exit 0;
