#!/usr/bin/perl -w
#
#	Invokes the ncdcTigge::runLatest subroutine for ARG-1 (positive int) 
#		cycles.  if ARG-1 is negative, only runs cleanup on input
#	* Processes the latested complete cycle of GENS input
#	Checks output for problems
#

$| = 1;

if( !(scalar grep(/$ENV{'TIGGE_TOOLS'}/,@INC)) )
    { push(@INC,"$ENV{'TIGGE_TOOLS'}"); }

use ncdcTigge 1.1 qw(runLatest cleanupLocation);

print(`echo "System Call test ok."`);

my $startTime = time;
my $cycles = 8;
if( defined($ARGV[0]) && ($ARGV[0] =~ m/\d{1,2}/) ) 
	{ $cycles = $ARGV[0]; }
if( $cycles == 0 ) 
	{ print STDOUT " ! No cycles were run, proceeding to cleanup.\n\n"; }
else
	{
		# -- where the action is happening --
	print STDOUT ncdcTigge::runLatest($cycles);
	}

print "\n\n=============================================================\n\n";

# Run a cleanup of TIGGE_INPUT, certain file types are EXCLUDED

print STDOUT "Cleaning up Input data area...\n\n";
my @EXCLUDE =   (
	"\^MoLode\$","logs","\.c\$","\.p[lm]\$",
	"\.perl\$","\.o\$","\.a\$","\.exe\$","\.log\$","\.csh\$",
	"\.bash\$","\.sh\$","\.txt\$","\.meta\$" );
print STDOUT ncdcTigge::cleanupLocation($ENV{'TIGGE_INPUT'},7.5,@EXCLUDE);

print "\n\n=============================================================\n\n";

$| = 0;
my $endTime = time;
my $elapsedTime = $endTime - $startTime;
print "\n\n$0: Finished.  $elapsedTime sec.\n\n";

exit 0;
