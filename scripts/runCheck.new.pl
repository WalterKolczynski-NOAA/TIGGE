#!/usr/local/perl -w
use lib '/usr/local/perl';
use strict;
use NcdcNomads 0.72;

my $VERSION = "0.3";
my $LAST_MODIFIED = "2015-04-21";

sub NcdcNomads::testTarArchive($);

our $monitorMailAddress = "NCDC.NomadsMonitoring\@noaa.gov";

(`source /home/nomads/.bashrc`);

if( ! $ENV{TIGGE_OUTPUT} ) 
	{ die("\nEnv not set TIGGE_OUTPUT : tigge output standard directory path\n\n"); }
if( !(-d $ENV{TIGGE_OUTPUT} ) ) 
	{
	die("\n Env TIGGE_OUTPUT = $ENV{TIGGE_OUTPUT}\nNot a directory but it needs to exist!\n\n\n");
	}
our $targetDir = "$ENV{TIGGE_OUTPUT}/archive";
our $tarChecks    = 0;
our $tarChecksMax = 24;

print STDOUT "\nScanning directory: $targetDir\n\n";
opendir(my $INDIR,$targetDir) || die("\n ! opendir scan failed.  aborting\n\n");
our @units = sort grep(/^tigge\-kwbc\-\d{10}\.tar$/,readdir($INDIR));

my $endUnit = $units[$#units];
my $startUnit = $units[0];

our @pattStart = $startUnit =~ m/(tigge\-kwbc\-)(\d{10})(.*)$/g;
our @pattEnd   = $endUnit =~ m/(tigge\-kwbc\-)(\d{10})(.*)$/g;

our $startDate = $pattStart[1];
our $endDate = $pattEnd[1];

closedir($INDIR);

my $flaged = 0;
my $missingFiles = "";
my $malSized = "";
my $archiveErrors = "";


our $dtg = $startDate;
our $breaker = 0;
my $runCounter = 0;
while( ($dtg lt $endDate) && ($breaker < 10000) )
        {
        $breaker++;
        $dtg = my $yyyymm   = NcdcNomads::timeToDateString(
                        NcdcNomads::addTime( $dtg,6,"hour" ), 3);
	$runCounter++;
	}

# since this runs from oldest to newest... we need to calculate this beforehand.
my $startArchiveCheck = $runCounter - $tarChecksMax;
if( $startArchiveCheck < 0 ) 
	{ $startArchiveCheck = 0; }

print STDOUT "\n$0 is now checking $runCounter TIGGE runs\n.";
print STDOUT "   With tar -tvf verification starting \# $startArchiveCheck\n\n";

my $realRunCounter = 0;
$dtg = $startDate;
$breaker = 0;
while( ($dtg lt $endDate) && ($breaker < 10000) ) 
	{
	$breaker++;
	$realRunCounter++;
	$dtg = my $yyyymm   = NcdcNomads::timeToDateString( 
			NcdcNomads::addTime( $dtg,6,"hour" ), 3);
	my $fNameCheck = "tigge-kwbc-${dtg}\.tar";
	my $pathCheck = "${targetDir}/${fNameCheck}";
	chomp($pathCheck);
	
	my $sizeCheck = -s $pathCheck;
	if( $sizeCheck && $sizeCheck < 4200000000 )
		{
		$malSized = "$malSized\n$pathCheck ($sizeCheck bytes)"; 
		$flaged++;
		}
	if( !(-f $pathCheck ) ) 
		{
		$missingFiles = "$missingFiles\n$pathCheck"; 
		$flaged++;
		}

	# only check a certain number of these.  It takes awhile and lots of I/O.
	if( $realRunCounter >= $startArchiveCheck ) 
		{
		$tarChecks++;

		my ($r1,$l1,$t1,@out1) = NcdcNomads::testTarArchive($pathCheck);
#		print STDOUT "Tar check output $pathCheck \n\t($r1,$l1,$t1,@out1)\n\n";

		if( $r1 != 0 ) 
			{
			$archiveErrors = "$archiveErrors\nTar check failed: $pathCheck :: Code $r1 \n";
			}
		if( $l1 != 0 ) 
			{ 
			$archiveErrors = "$archiveErrors\nProblem with $pathCheck\n\t{\n@out1\n\t}\n";
			}
		}

	}

print STDOUT " Found : $startDate to $endDate ($flaged)\n\n";

 NcdcNomads::sendmail( $monitorMailAddress, $monitorMailAddress,
	"[NCDC-TIGGE $0] TIGGE run report",
	"Cycles not yet completed:\n\n$missingFiles\n\nunder sized packages:\n\n$malSized\n\nDeep Tar Checks [$tarChecks]x\n\n$archiveErrors \n\n$0 Version $VERSION\n\n-- END --");


exit 0;
