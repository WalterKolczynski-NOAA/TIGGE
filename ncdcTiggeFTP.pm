package ncdcTiggeFTP;

use 5.008000;
use strict;
use warnings;
use Net::FTP;
use vars qw(@ISA $VERSION);
# require("Net/FTP.pm");

require Exporter;

our @ISA = qw(Exporter Net::FTP);

our %EXPORT_TAGS = ( 'all' => 	[
   qw( &ingestFtpprd &uploadResults $ftpGetDelay $ftpTimeout %RequiredVariablesA %RequiredVariablesB ) 
								] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our $VERSION = "0.98";


# Preloaded methods go here.

sub BEGIN 
{
print STDOUT "\n ** Using ncdcTigge PERL Module ** \n";
$ncdcTiggeFTP::startTime = time;
}

	# Important! sets the location where ECMWF GRIB API executables can be found
our $GRIB_API_BIN = "/usr/local/bin";

	# PACKAGE LEVEL "Public" (our scope) VARIABLES / CONSTANTS
our $ENS_MEMBERS    = 20;		# Maximum number of members
our $FCT_HOURS      = 384;		# Maximum forecast hours
our $FCT_INC        = 6;		# Default forecast hour increment

	# FTP download variables
our $ftpSrcSite		= "ftpprd.ncep.noaa.gov";		# Gens Download location
our $ftpSrcLogin	= "anonymous";
our $ftpSrcPasswd	= "NOMADS.ncdc\@noaa.gov";
our $ftpTimeout     = 30;		# Timeout setting (seconds)
our $ftpDebug       = 0;		# ??? not sure what values for this do what
our $ftpGetDelay	= 1;		# Seconds to wait between transfers
our $ftpXferGiveUp  = 10;		# Terminate on # number of consecutive failures

	# FTP Upload variables
our $ftpInfoFile = "ftpUploadInfo.txt";
our $ftpDestSite	= "";
our $ftpDestLogin	= "";
our $ftpDestPasswd	= "";
our $ftpDestPath	= "";

	# Set this to 'yes' to disable certain checks
our $forceOption	= "no";

# These 2 variables need to be implemented!
our $ftpRetry		= 3;		# Number of retry attempts upon trapped errors
our $ftpRetryDelay	= 20;		# Seconds to wait between retry

#	For Input QC
our $qcCenterCode 	= "kwbc";	# Accepted originating center code (NWS/NCEP)
our $qcRecByteMin	= 128;		# Minimum byte size for ANY grib2 record
our $qcGensProcessIdNum = 4;	# GRIB2 Generating process ID for GENS model
our $qcNumPoints	= 65160;	# Number of datapoints contained in GENS-3 Grid
								# GRIB2 Record count, inside GENS files
our $qcGensAnlARecCount	= 45;
our $qcGensFctARecCount	= 51;
our $qcGensAnlBRecCount	= 283;
our $qcGensFctBRecCount	= 288;

our %RequiredVariablesA = (
	"Categorical Snow",			"0,1,95,,,,",
	"Total Precipitation",		"0,1,8,,,,",
	"Tot Precipitable Water",	"0,1,3,200,,,",
	"Accumulated Precip",		"0,1,195,,,,"
	);

our %RequiredVariablesB = (
    "Pressure PV2000",			"3,0,109,2000,,",
	"Temperature PV2000",		"0,0,0,109,2000,,",
	"Soil Temperature 10",		"0,0,0,106,0,106,10",
	"Soil Temperature 40",		"0,0,0,106,10,106,40",
	"Soil Moisture 10",			"2,0,192,106,0,106,10",
	"Soil Moisture 40",			"2,0,192,106,10,106,40",
	"Upward LW Radiation",		"0,5,193,1,,,",
	"Upward LW radiation",		"0,5,192,1,,,",
	"Sfc Latent Heat Flux",		"0,0,10,1,,,",
	"Upward SW radiation",		"0,4,193,1,,,",
	"Downward SW radiation",	"0,4,192,1,,,",
	"Sfc Sensible Heat Flux",	"0,0,11,1,,,",
	"Total Cloud water",		"0,6,6,200,,,"
    );

our @gribLsKeys = (
        "identifier",
        "editionNumber",
        "totalLength",
        "identificationOfOriginatingGeneratingCentre",
        "typeOfGeneratingProcess",
        "perturbationNumber",
        "forecastTime",
        "numberOfDataPoints",
        "parameterCategory",
        "parameterNumber",
        "typeOfFirstFixedSurface",
        "scaledValueOfFirstFixedSurface",
        "typeOfSecondFixedSurface",
        "scaledValueOfSecondFixedSurface",
        "level"
        );

our $Segmentor = "###*****###";

# For output QC
our @tiggeVarCodes = qw(pt sf sm st ttr slhf ssr str sshf tcw tp);


#===========================================================================
#
sub ingestFtpprd($$;$$$$)
{
my $headline = "$0:ncdcTiggeFTP::ingestFtpprd(@_) : ";
my $thisHOST = "Unknown Host";
if( defined($ENV{'HOSTNAME'}) )     { $thisHOST = $ENV{'HOSTNAME'}; }
print STDOUT "\n$headline Run on $thisHOST \@ ".localtime(time)."\n";

my $inDate = shift(@_);
$ncdcTiggeFTP::gensType = shift(@_);

$ENV{'TIGGE_INPUT'} || return("### $headline Required ENV VAR : TIGGE_INPUT is not set!\n\n");

	# Dataset Default Settings -----------------------------------------
my $ENS_MEMBER_START = 0;
my $ENS_MEMBER_END   = 20;
my $FCT_MIN = 0;
my $FCT_MAX = 384;
my $OUTPUT_DIR_BASE = $ENV{'TIGGE_INPUT'};

	# FTP Settings ----------------------------------------------------
my $FTPHostName = $ncdcTiggeFTP::ftpSrcSite;
# $FTPHostName = "ncepalpha-ssmc.woc.noaa.gov";
my $FTPlogin  = $ncdcTiggeFTP::ftpSrcLogin;
my $FTPpasswd = $ncdcTiggeFTP::ftpSrcPasswd;
my $remoteFtpDir = "/pub/data/nccf/com/gens/prod";

$ncdcTiggeFTP::startTime = time;
print STDOUT "\n$headline Executed from $0 on $ENV{'HOSTNAME'} \@ ".localtime($ncdcTiggeFTP::startTime)."\n";

# Capture & range bind / validate optional arguments
my $counter = 0;
my $arg;

# while( $arg = shift(@_) )
for( $counter = 0; $counter <= $#_; $counter++ ) 
    {
	$arg = $_[$counter];
	chomp($arg);
	if( $arg !~ m/^\d{1,3}$/ ) { next; }
	if( $arg < 0 ) { next; }
    if( $counter == 0 ) { $FCT_MIN = int($arg); }
    if( $counter == 1 ) { $FCT_MAX = int($arg); }
    if( $counter == 2 ) { $ENS_MEMBER_START = int($arg); }
    if( $counter == 3 ) { $ENS_MEMBER_END   = int($arg); }
    }
if( $FCT_MIN < 0 )	{ $FCT_MIN = 0; }
if( $FCT_MIN > $ncdcTiggeFTP::FCT_HOURS ) 
	{ $FCT_MIN = $ncdcTiggeFTP::FCT_HOURS;  $FCT_MAX = $ncdcTiggeFTP::FCT_HOURS; }
if( $FCT_MAX > $ncdcTiggeFTP::FCT_HOURS )
    { $FCT_MAX = $ncdcTiggeFTP::FCT_HOURS; }
if( $FCT_MIN > $FCT_MAX ) { $FCT_MIN = $FCT_MAX; }
if( $ENS_MEMBER_START < 0 ) { $ENS_MEMBER_START = 0; }
if( $ENS_MEMBER_START > $ncdcTiggeFTP::ENS_MEMBERS )
	{ $ENS_MEMBER_START = $ncdcTiggeFTP::ENS_MEMBERS;
	  $ENS_MEMBER_END = $ncdcTiggeFTP::ENS_MEMBERS; }
if( $ENS_MEMBER_END > $ncdcTiggeFTP::ENS_MEMBERS )
	{ $ENS_MEMBER_END = $ncdcTiggeFTP::ENS_MEMBERS; }
if( $ENS_MEMBER_START > $ENS_MEMBER_END ) 
	{ $ENS_MEMBER_START = $ENS_MEMBER_END; }
#  ensure forecast hour input is divisable by the increment
if( $FCT_MIN % $ncdcTiggeFTP::FCT_INC != 0 )
	{ $FCT_MIN = int($FCT_MIN / $ncdcTiggeFTP::FCT_INC) * $ncdcTiggeFTP::FCT_INC; }
if( $FCT_MAX % $ncdcTiggeFTP::FCT_INC != 0 )
    { $FCT_MAX = (int($FCT_MAX / $ncdcTiggeFTP::FCT_INC) * $ncdcTiggeFTP::FCT_INC) + $ncdcTiggeFTP::FCT_INC; }

undef $ncdcTiggeFTP::yyyymmdd;
undef $ncdcTiggeFTP::cycle;

	# ARG Handler
if( $inDate =~ m/^\d{4}[0-1]\d[0-3]\d[0-2]\d$/ )
	{
	$ncdcTiggeFTP::yyyymmdd = substr($inDate,0,8);
	$ncdcTiggeFTP::cycle    = substr($inDate,8,2);
	}
elsif( $inDate eq " " or $inDate eq "default" or $inDate eq "latest" ) 
	{     undef $ncdcTiggeFTP::yyyymmdd;	}
else 
    { 
	print STDERR "### $0:ingestFtpprd : Recieved invalid date input.\nExpected YYYYMMDDHH - got $inDate\nDefaulting to latest run.\n\n";
	undef $ncdcTiggeFTP::yyyymmdd;
	}

# Hollar & default to type-a files upon bad input
if( (lc($ncdcTiggeFTP::gensType) ne "a") && (lc($ncdcTiggeFTP::gensType) ne "b") ) 
	{
	print STDOUT "*** $0:ingestFtpprd : ARGS : Invalid file type, defaulting to [a]\n\n";
	$ncdcTiggeFTP::gensType = "a"; 
	}


	#  Connect to FTPprd and change to first varying (date) directory
	#  Logs in using anonymous / and group email addy.


$ncdcTiggeFTP::ftpHandle = Net::FTP->new($FTPHostName, Timeout=>$ncdcTiggeFTP::ftpTimeout,Debug=>$ncdcTiggeFTP::ftpDebug )
      or return("Unable to connect! : ",$ncdcTiggeFTP::ftpHandle->message);
$ncdcTiggeFTP::ftpHandle->login($FTPlogin,$FTPpasswd)
      or return("Cannot login ", $ncdcTiggeFTP::ftpHandle->message);
$ncdcTiggeFTP::ftpHandle->cwd($remoteFtpDir)
      or return("Cannot change working directory ", $ncdcTiggeFTP::ftpHandle->message);
$ncdcTiggeFTP::ftpHandle->binary;


# No yyyymmdd given in ARGS, so using the first avbl. date from ftp->ls
if( !(defined $ncdcTiggeFTP::yyyymmdd) )
   {
   my @dates = $ncdcTiggeFTP::ftpHandle->ls
      or return("Cannot obtain directory listing ",
				 $ncdcTiggeFTP::ftpHandle->message);
   my @gensDates = reverse sort grep(/^gefs.\d{4}[0-1]\d[0-3]\d$/,@dates);
   $ncdcTiggeFTP::yyyymmdd = $gensDates[0];
   $ncdcTiggeFTP::yyyymmdd =~ s/^gefs\.//g;
   }

#   cwd to and obtain listing for current cycles
$remoteFtpDir = "${remoteFtpDir}/gefs.${ncdcTiggeFTP::yyyymmdd}";
$ncdcTiggeFTP::ftpHandle->cwd($remoteFtpDir)
	or return("Failed changing working directory ",
				$ncdcTiggeFTP::ftpHandle->message);

if( !(defined $ncdcTiggeFTP::cycle) ) 
   {
   my @gensRuns = reverse sort $ncdcTiggeFTP::ftpHandle->ls
      or return("Cannot obtain directory listing ", 
				$ncdcTiggeFTP::ftpHandle->message);
   $ncdcTiggeFTP::cycle = $gensRuns[0];
   }

# Move into the Remote directory
$remoteFtpDir 
	= "${remoteFtpDir}/${ncdcTiggeFTP::cycle}/pgrb2${ncdcTiggeFTP::gensType}";
$ncdcTiggeFTP::ftpHandle->cwd($remoteFtpDir)
	or return("Cannot change working directory ", 
				$ncdcTiggeFTP::ftpHandle->message);

	# Ensure output directories are in place, then chdir into it
my $OUTPUT_DIR = "${OUTPUT_DIR_BASE}/${ncdcTiggeFTP::yyyymmdd}${ncdcTiggeFTP::cycle}";
	# A tag file to indicate activity to external subroutines
my $ACTIVITY_TAG = "${OUTPUT_DIR}/CURRENTLY-DOWNLOADING-$$";
if(!(-d $OUTPUT_DIR_BASE) )
	{
	mkdir($OUTPUT_DIR_BASE) || 
		return("### $0 : unable to create base output directory!\n### $OUTPUT_DIR_BASE\n\n");
	}
if(!(-d $OUTPUT_DIR) )
	{
	mkdir($OUTPUT_DIR) || 
		return("### $0 : unable to create output directory!\n\n");
	}
chdir($OUTPUT_DIR);



print STDOUT "\n ingestFtpprd : Obtaining GENS-${ncdcTiggeFTP::gensType} for Date-time ${ncdcTiggeFTP::yyyymmdd}-${ncdcTiggeFTP::cycle}\:00 UTC \n\t From site : ${FTPHostName}\n";

	# Knowing that multiple processes may be going on concurrently...
	# Find an unsed metafile name for the process and lock it.
	# Read cached information from all metafiles into name-keyed hashes
	#   If any metadata is over a day old -> It is not used
my $metafileNum = 0;
my $metaFileName = ".metafile-${ncdcTiggeFTP::gensType}-${metafileNum}";
my $metaFileLock = "${metaFileName}.lock";
while ( -e "./$metaFileLock" ) 
	{
	$metafileNum++;
	$metaFileName = ".metafile-${ncdcTiggeFTP::gensType}-${metafileNum}";
	$metaFileLock = "${metaFileName}.lock";
	}

opendir(CWDIR,".");
my @cwdMetaFiles = grep(/^\.metafile-[ab]-\d*(\.lock)?$/,readdir(CWDIR));
closedir(CWDIR);
open(METAFILELOCK,">",$metaFileLock);
print STDOUT "Claimed Lock file : $metaFileLock\n\n";
undef my @metaEntries;
foreach my $cwdmetas ( @cwdMetaFiles ) 
	{
	# Foreach metafile match, merge all entries into the lock file, & close it
	if( -z "./$cwdmetas") { next; }			# Skip empty files
	if( (-M "./$cwdmetas") > 1 ) { next; }	# Skip old files (>1 day)

# print "DEBUG : Caching Metafile : $cwdmetas\n";
	open(TMP,"<","./$cwdmetas");
	push(@metaEntries,readline(TMP));
	close(TMP);
	}

#  Create a unique hash of file names, takes latest created when 2x+ entries
#   Post the data to the lock file & close it
#   Throw out entries that look damaged or incomplete, (forces redownload)
my %tmpMeta;
my %tmpMetaData;
foreach my $line ( @metaEntries ) 
	{
	chomp($line);
	my @tmpSplit = split(/ /,$line);
		# Ensure all entries are present and numeric
	if( !(defined($tmpSplit[1])) || ($tmpSplit[1] !~ m/^\d*$/ ) ) 
		{ next; }
    if( !(defined($tmpSplit[2])) || ($tmpSplit[2] !~ m/^\d*$/ ) )
        { next; }
    if( !(defined($tmpSplit[3])) || ($tmpSplit[3] !~ m/^\d*$/ ) )
        { next; }
    if( !(defined($tmpSplit[4])) || ($tmpSplit[4] !~ m/^\d*$/ ) )
        { next; }

	if( !defined($tmpMeta{$tmpSplit[0]}) ) 
		{	
		$tmpMeta{$tmpSplit[0]} = $tmpSplit[1];		
		$tmpMetaData{$tmpSplit[0]} = $line;
		}
	elsif( $tmpMeta{$tmpSplit[0]} < $tmpSplit[1] ) 
		{
		$tmpMeta{$tmpSplit[0]} = $tmpSplit[1];
		$tmpMetaData{$tmpSplit[0]} = $line;
		}
	}
foreach my $key ( sort keys(%tmpMetaData) ) 
	{ print METAFILELOCK "$tmpMetaData{$key}\n"; }
close(METAFILELOCK);

#  Use the metafile data to determine which files do not require download
undef my %cache_size;
undef my %cache_modt;
undef my %cache_lsize;
undef my %cache_ctime;
undef my @cachedFileNames;
my $currentTime = time;
if( (-e "./$metaFileName") ) 
	{
	open(META,"<","./$metaFileLock") || last;
	foreach (<META>)
		{
		chomp($_);
		my @tmp = split(/ /,$_);
		my $thisFileName = $tmp[0];

			# record too old
		if( ($currentTime - $tmp[1]) > 86400 ) 			{ next; }
			# Duplicate, or older record
		if( defined($cache_ctime{$thisFileName}) && 
			($cache_ctime{$thisFileName} < $tmp[1]) ) 	{ next; }

        push(@cachedFileNames,$thisFileName);
		$cache_ctime{$thisFileName} = $tmp[1];
		$cache_modt{$thisFileName}  = $tmp[2];
		$cache_size{$thisFileName}  = $tmp[3];
		$cache_lsize{$thisFileName} = $tmp[4];
		}
	close(META);
	}


# MAIN LOOP : All fcthrs : members

my $member;
my $fcthr;

if( !(-e $ACTIVITY_TAG) ) 
	{
	open(TAG,">",$ACTIVITY_TAG);
	print TAG "$$   @_";
	close TAG;
	}

# used for session  stats
undef my @failures;
undef my @missing;
undef my @success;
my $consequtiveErrorCount = 0;
my $bytesTransferred = 0;

# 'processedFiles' keeps track of what files were processed in this run
#    so files not acted on, but present in metafile data --
#    can be carried along at the end
undef my @processedFiles;

$currentTime = time;

$| = 1;  # Sets auto-flush on STDOUT

open(METAFILE,">","./$metaFileName") ||
 return("### ingestFtpprd : Could not open ./$metaFileName for writting!\n\n");

print STDOUT "\n\n\tSTATUS TABLE
Mem X FctHrs:( [*] New or updated, [O] Old, [!] Failed xfer, [X] Not found)
+----------------------------------------------------------------------------+";

for ( $member = 0; $member <= $ncdcTiggeFTP::ENS_MEMBERS; $member++ )
	{
	printf STDOUT ("\n|%02d %1s ",$member,uc($ncdcTiggeFTP::gensType));
    if( $member < $ENS_MEMBER_START || $member > $ENS_MEMBER_END ) 
		{ next; }

	for( $fcthr = 0; $fcthr <= $ncdcTiggeFTP::FCT_HOURS; $fcthr+=$ncdcTiggeFTP::FCT_INC )
		{

		if( $fcthr < $FCT_MIN || $fcthr > $FCT_MAX ) 
			{
			print STDOUT " ";
			if( $fcthr%72 == 0 ) { print STDOUT " "; }
			next;
			}

		my $prefix = "gep";
		if( $member == 0 ) { $prefix = "gec"; }

		# Setup Filenames
		my $aFileName = sprintf("%3s%02d.t%02dz.pgrb2%1sf%02d",
			$prefix,$member,$ncdcTiggeFTP::cycle,$ncdcTiggeFTP::gensType,$fcthr);
		my $aOutFile = sprintf("gens-${ncdcTiggeFTP::gensType}_3_%8d_%02d00_%03d_%02d.grb2",
			$ncdcTiggeFTP::yyyymmdd,$ncdcTiggeFTP::cycle,$fcthr,$member);

			# Used for partial-file transfers, 
			#   unfortunately, NET:FTP does not support this
		my $aFileNameIdx = "$aFileName.idx";

		if( $fcthr%72 == 0 ) { print STDOUT " "; }

		# Check the consecutive error counter and skip to end if exceeded
		#		(assume the ftp session died or otherwise hosed)
		if( $consequtiveErrorCount > $ncdcTiggeFTP::ftpXferGiveUp ) 
			{ print STDOUT "-"; next; } 

			# Obtain size and Mod.time
			# Assume missing file upon failure
		my $modTime = $ncdcTiggeFTP::ftpHandle->mdtm($aFileName);
		if( !defined($modTime) || $modTime eq "" ) 
			{ print STDOUT "X";  push(@missing,$aOutFile); 
			  $consequtiveErrorCount++; next;  }
		my $fileSize = $ncdcTiggeFTP::ftpHandle->size($aFileName);
        if( !defined($fileSize) || $fileSize eq "" )
			{ print STDOUT "X";  push(@missing,$aOutFile);
			  $consequtiveErrorCount++; next; }

		# Check for existing downloaded file...
		my $localPath = "${OUTPUT_DIR}/${aOutFile}";

        # Check for unchanged files to avoid unnecessary transfer
		if( defined($cache_modt{$aOutFile}) && 
		    defined($cache_size{$aOutFile}) && 
		    (-f $localPath )                  ) 
			{ 
			my @localStat = stat($localPath);

			# To skip, File creation size must match AND
			#   the metafile entries must match
			if( int($modTime) == int($cache_modt{$aOutFile})  &&
			    int($fileSize) == int($cache_size{$aOutFile}) &&
			    ($localStat[9] == $cache_ctime{$aOutFile} )    )
				{
				# No change in file, no action - retain entry in metafile
				print METAFILE "$aOutFile $cache_ctime{$aOutFile} $modTime $fileSize $localStat[7] SKIP\n";
				push(@processedFiles,$aOutFile);
				print STDOUT "O";
				$consequtiveErrorCount=0;
				next;
				}
			}

# print " DEBUG : $aOutFile : $fileSize B $modTime \n";

		# Do the transfer
		#   and checks return value for failure
		my $rtn = $ncdcTiggeFTP::ftpHandle->get($aFileName,$aOutFile);
                my @dlStat = stat($localPath);
		if( !defined($rtn) || $rtn eq "" ) 
			{  
			print STDOUT  "!"; push(@failures,$aOutFile); 
			$consequtiveErrorCount++; 
			}
		else
			{
			print STDOUT "*";
			push(@success,$aOutFile);
			my @localStat = stat($localPath);
			print METAFILE "$aOutFile $dlStat[9] $modTime $fileSize $localStat[7] NEW\n";
			$bytesTransferred += $localStat[7];
			push(@processedFiles,$aOutFile);
			$consequtiveErrorCount=0;
			}
		sleep($ncdcTiggeFTP::ftpGetDelay);
		}		# END FctHr loop
	}			# END member loop

# End the table
print STDOUT "
+---------------------------------------------------------------------------+
\n\n";

	# Carry along metadata from metafile for files which were not processed
foreach my $cachedFileName ( @cachedFileNames )
	{
	# If the cached file does not appear in the list of processed files ...
	if( !( scalar grep(/^$cachedFileName$/,@processedFiles) ) ) 
		{
		# Tag it along before closing meta-file handle
		print METAFILE "$cachedFileName $cache_ctime{$cachedFileName} $cache_modt{$cachedFileName} $cache_size{$cachedFileName} $cache_lsize{$cachedFileName}\n";
		}
	}

if( $ncdcTiggeFTP::ftpHandle->close() == 1)
    { print STDOUT "Connection to ${FTPHostName} is closed\n\n"; }
else
    { print STDOUT "### $headline close() command unsuccessful!\n\n"; }

	# Release autoflush, close handles, and release locks
$| = 0;
close(METAFILE);
unlink($metaFileLock);
unlink($ACTIVITY_TAG);

my $bytesTransferredMb = ($bytesTransferred / 1000000);

print STDOUT "Output is in : \n$OUTPUT_DIR\n\n";
printf STDOUT ("%4d\tSuccessful transfers:  (%.2f Mb) \n",
	int($#success+1),$bytesTransferredMb);
printf STDOUT ("%4d\tFailed transfers.\n",int($#failures+1));
printf STDOUT ("%4d\tFiles no longer available, \&/or timeouts\n\n",int($#missing+1));

print STDOUT "\n$headline Finished ".localtime(time)."\n";
return 0;
}
#		End 		ingestFtpprd
#===========================================================================



#					uploader
#===========================================================================

sub uploader($;$)
{
my $headline = "$0:ncdcTiggeFTP::uploader(@_) : ";
my $thisHOST = "Unknown Host";
if( defined($ENV{'HOSTNAME'}) )     { $thisHOST = $ENV{'HOSTNAME'}; }
print STDOUT "\n$headline Run on $thisHOST \@ ".localtime(time)."\n";

my $ftpInfo = "";
if( ($ncdcTiggeFTP::ftpDestSite eq "") || ($ncdcTiggeFTP::ftpDestLogin eq "") ||
	($ncdcTiggeFTP::ftpDestPasswd eq "") || ($ncdcTiggeFTP::ftpDestPath eq "") ) 
	{
	$ENV{'TIGGE_TOOLS'} || return("### $headline Inadequate ftp information\n");
    $ftpInfo = "$ENV{'TIGGE_TOOLS'}/${ncdcTiggeFTP::ftpInfoFile}";
	print STDOUT "$headline  Essential ftp connection information is not set.";
	print STDOUT "\n\n  Looking for an info file: $ftpInfo\n";
	if( !(-e $ftpInfo) || !(-r $ftpInfo) ) 
		{ 
		return("### $headline   Inadequate FTP information
Please create a file $ftpInfo\n that contains following data (1 string on each line, no headers)
	===============================================
<FTP server address: i.e. \"ftp.ncdc.noaa.gov\">
<FTP Login name>
<Password for login name>
[Remote FTP directory]
	=== EOF =======================================
Once $ftpInfo is in place, rerun the program.\n");
		}

	open(FTP,"<",$ftpInfo) || return("### $headline Cannot open $ftpInfo\n\n");
	my @ftpData = readline(FTP);
	close(FTP);	
	if( $#ftpData <= 2 ) 
		{
		print STDOUT "### $headline Insufficent information in $ftpInfo\n\n";
		}
	print STDOUT "  Found $ftpInfo, applying settings...\n\n";
	chomp($ftpData[0]);  chomp($ftpData[1]);  chomp($ftpData[2]);
	$ncdcTiggeFTP::ftpDestSite   = $ftpData[0];
	$ncdcTiggeFTP::ftpDestLogin  = $ftpData[1];
	$ncdcTiggeFTP::ftpDestPasswd = $ftpData[2];
	if( defined($ftpData[3]) )
		{  chomp($ftpData[3]);  $ncdcTiggeFTP::ftpDestPath = $ftpData[3];  }
	}

if( $#_ < 0 ) 
	{ return("### $headline Argument 1 required! Target PATH is missing\n\n"); }
my $localTargetPath = shift(@_);
if( @_ ) { $ftpDestPath = shift(@_); }

if( !(-e $localTargetPath) )
	{
	return("### $headline Target file : $localTargetPath - does not exist\n\n");
	}
if( !(-r $localTargetPath) )
    {
    return("### $headline Target file : $localTargetPath - cannot be read\n\n");
    }

my $localTargetName = $localTargetPath;
$localTargetName =~ s/.*\///g;
my @localTargetStat = stat($localTargetPath);
my $localTargetSize = $localTargetStat[7];

	# Get a FTP Connection handler Object
$ncdcTiggeFTP::ftpHandle = Net::FTP->new($ncdcTiggeFTP::ftpDestSite, Timeout=>$ncdcTiggeFTP::ftpTimeout,Debug=>$ncdcTiggeFTP::ftpDebug ) or return("### $headline Unable to connect! : ",$ncdcTiggeFTP::ftpHandle->message);

my $problem = 0;

	# Login
$ncdcTiggeFTP::ftpHandle->login($ncdcTiggeFTP::ftpDestLogin,$ncdcTiggeFTP::ftpDestPasswd)
      or $problem=1;
if( $problem == 1 )
	{
	$ncdcTiggeFTP::ftpHandle->close();
	return("\n### FTP Server login failed : ".$ncdcTiggeFTP::ftpHandle->message);
	}

	# Chenge to selected directory
$ncdcTiggeFTP::ftpHandle->cwd($ncdcTiggeFTP::ftpDestPath)
      or $problem=1;
if( $problem == 1 ) 
	{
	$ncdcTiggeFTP::ftpHandle->close();
	return("\n### Cannot cwd to directory -> ".$ncdcTiggeFTP::ftpHandle->message);
	}

print STDOUT "Uploading file $localTargetName -> $ncdcTiggeFTP::ftpDestSite\n\n";

	# push the file
$ncdcTiggeFTP::ftpHandle->binary;
my $remoteFile = $ncdcTiggeFTP::ftpHandle->put($localTargetPath);
my $remoteFileSize = $ncdcTiggeFTP::ftpHandle->size($localTargetName);

if( !defined($remoteFile) || ($remoteFileSize != $localTargetSize) ) 
	{ 
		# Zap any caught partially transferred files
	if( $remoteFileSize != $localTargetSize )
		{ 
		print STDOUT "Removing partially transferred file...\n";
		$ncdcTiggeFTP::ftpHandle->delete($localTargetName); 
		}
	$ncdcTiggeFTP::ftpHandle->close(); 
	return("### $headline Push failed! ".$ncdcTiggeFTP::ftpHandle->message." \n");
	}
print STDOUT "Pushed : $remoteFile  $remoteFileSize/$localTargetSize B\n\n";

if( $ncdcTiggeFTP::ftpHandle->close() == 1) 
	{ print STDOUT "Connection to FTP Server has been closed\n\n"; }
else
	{ print STDOUT "### $headline close() command unsuccessful!\n\n"; }

print STDOUT "$headline Finished successfully.  ".localtime(time)."\n";
return("OK");
}

#       End         uploader
#===========================================================================




#					uploadResults
#===========================================================================

sub uploadResults()
{
my $headline = "$0:ncdcTiggeFTP::uploadResults() : ";
my $thisHOST = "Unknown Host";
if( defined($ENV{'HOSTNAME'}) )		{ $thisHOST = $ENV{'HOSTNAME'}; }
print STDOUT "\n$headline Run on $thisHOST \@ ".localtime(time)."\n";

$ENV{'TIGGE_OUTPUT'} || return("### $headline Essential ENV VAR TIGGE_OUTPUT is not defined!\n\n");

print STDOUT "  Gathering information...\n\n";
my $archiveDir = "$ENV{'TIGGE_OUTPUT'}/archive";
opendir(DIR,$archiveDir);
my @dtgList = sort grep(/^[0-9]{4}[0-1]\d[0-3]\d[0-2]\d$/,readdir(DIR));
closedir(DIR);

$| = 1;
foreach my $dtg ( @dtgList )
	{
	my $statusFile = "${archiveDir}/${dtg}/OUTPUT.QC.PASS.$dtg";
	if ( (-f $statusFile ) && (-r $statusFile) ) 
		{
		open(IN,"<",$statusFile);
		my @statusInfo = readline(IN);
		close(IN);

		if( (scalar grep(/^DATA_SENT_SUCCESSFULLY/,@statusInfo) )
			&& ($ncdcTiggeFTP::forceOption eq "no")					)  
			{
			print "  sent  $statusFile\n";
			next;
			}
		if( scalar grep(/^DATA_PACKAGED_SUCCESSFULLY/,@statusInfo) ) 
			{
			my @paths = grep(/gens-tigge_3_.*\.tar\.gz$/,@statusInfo);
			if( $#paths == -1 ) 
				{
				print "   !!   No filepath found in status file\n";
				next;
				}
			my $localTarget = $paths[0];   chomp($localTarget);
			if( !(-e $localTarget) || !(-r $localTarget) ) 
				{
				print "   --   $localTarget\n";
				next;
				}

			# Invoke the uploader
            print "sending $localTarget\n";
			my $uploadRtn = uploader($localTarget);

			if( $uploadRtn =~ m/^OK/i )
				{
				push(@statusInfo,"DATA_SENT_SUCCESSFULLY : ".localtime(time));
				open(OUT,">",$statusFile);
				print OUT @statusInfo;
				close(OUT);
				next;
				}
			else
				{ print " ! Error from uploader:\n$uploadRtn\n"; }
			}
		}
	else
		{
		print "   --   $statusFile\n";
		next;
		}
	}
print STDOUT "\n$headline Finished successfully.  ".localtime(time)."\n";
$| = 0;
return("OK");
}

#		End			uploadResults
#===========================================================================


# 					Destructor
sub END
{

if( defined($ncdcTiggeFTP::ftpHandle) ) 
	{ $ncdcTiggeFTP::ftpHandle->quit; }

$ncdcTiggeFTP::endTime = time;
my $ET = $ncdcTiggeFTP::endTime - $ncdcTiggeFTP::startTime;
print STDOUT ("ncdcTigge: Done : ".localtime($ncdcTiggeFTP::endTime).
	"  $ET Seconds ET\n\n");
}

#       End         Destructor
#===========================================================================

#   END -- Preloaded methods go here.




        # FILE LEVEL "Private" VARIABLES
my $yyyymmdd;		# Holds model initialization Date
my $cycle;			# Holds Model initialization time (cycle)
my $ftpHandle;		# For NET::FTP Object Handler
my $startTime;		# For timers
my $endTime;		#  ''
my $gensType;		# Type of GENS :  A or B 

1;

# Autoload methods go after =cut, and are processed by the autosplit program.

__END__

=head1 NAME

ncdcTigge - Self contained perl module

=head1 SYNOPSIS

#   use ncdcTigge;

NCDC-NOMADS Tigge Project - Phase 1
PERL module that contains generalized routines used for/to :
1)  Obtain GENS a & b data from ftpprd
2)  Verify downloaded files, then executes the ncdcTigge C code that 
	processes the tigge data.
3)  Verify the TIGGE output records.
4)  Ships the data to an FTP server at NCAR

=head1 DESCRIPTION

This package contains subroutines which accomplish the following tasks--

1)  Obtain GENS a & b data from ftpprd
2)  Verify downloaded files, then executes the ncdcTigge C code that
        processes the tigge data.
3)  Verify the TIGGE output records.
4)  Ships the data to an FTP server at NCAR

		--- Routine documentation ---
 - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
    sub ingestFtpprd($$;$$$$)
        	@ v.0.84
		Obtain the GENS ENS Data from FTPPRD using PERL NET::FTP

       ARGS   (-> input, <- output, <= returns)  Required, [optional]
	 1  -> YYYYMMDDHH, or "" for latest
	 2  -> Type of gens file ("a" or "b")
	[3] -> Starting Forecast hour [0] *Enter negative number to skip opts*
	[4] -> Final forecast hour [384]  Increment is 6hr
	[5] -> Starting Member Number [0]
	[6] -> Final Member Number [20]  Increment is 1
	    <- STDOUT: Progress messages
	    <- STDERR: FTP session info and other critical errors
	    <= Returns null string on success, error string if problem

 - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	sub uploader($;$)
		Uploads target file (arg1), to optional destination (arg2) through ftp
		requires NET::FTP
		Requires package level variables to be set:
			$ftpDestSite
			$ftpDestLogin
			$ftpDestPasswd
			$ftpDestPath
		OR, file: $ftpInfoFile to be set, and the text file to be setup
		
	 1	->	PATH of file to upload
	[2]	->	Optional Remote path on the destination server
		<-	STDOUT - Progress/Messages
		<*	"OK" on success, "### Error" on failure

 - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	sub uploadResults()
		Looks in TIGGE_OUTPUT for tar.gz files
		Checks status file to avoid re-upload
		calls uploader on new files

		->	No input necessary
		<-	STDOUT - Progress/Messages
		<*	"Finished successfully.", or "### Error message"

 - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -


=head2 EXPORT

None by default.

=head1 SEE ALSO

NET::FTP
http://search.cpan.org/~gbarr/libnet-1.22/Net/FTP.pm

Support / feedback:
NOMADS.ncdc@noaa.gov

Related Web sites:
http://nomads.ncdc.noaa.gov/
http://tigge.ucar.edu/home/home.htm

=head1 AUTHOR

Dan.Swank, <lt>dan.swank@noaa.gov<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007 by Dan Swank

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.


=cut

