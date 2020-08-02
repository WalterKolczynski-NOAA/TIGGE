#!/usr/bin/perl -w
use strict;
use ncdcTigge 1.4;
use File::Path qw(make_path);
sub convertFile($);
sub qcOutput2($);
sub cleanDevShm();

my $ymdh = shift(@ARGV);
our $CYCLE_YMDH = $ymdh;
if( $ymdh !~ m/\d{4}[0-1]\d[0-3]\d[0-2]\d/ )
        { exit 0; }
our $inputDir     = "$ENV{TIGGE_INPUT}/$ymdh";
our $outputStash  = "$ENV{TIGGE_OUTPUT}/$ymdh";
our $outputArchive  = "$ENV{TIGGE_OUTPUT}/archive/$ymdh";
our $QCREPORT = "tigge-output-qc-report-for-${ymdh}.txt";
our $QCREPORTpath = "$outputStash/$QCREPORT";


print STDOUT "$0 @ARGV Run at ".scalar localtime(time)."\n\n";

my $headline = "$0 (@ARGV) : ";
our $base = "$ENV{TIGGE_TOOLS}/scripts";
our $checkList = "${base}/output-verify.list";
	# A list of patterns to ensure all needed fields were converted.
	# previously this was .txt file, which left it vulnerable to deletion.
our $progressCounter = 0;
print STDOUT "\n$headline Started \@ ".localtime(time)."\n\n";


if( ${ncdcTigge::GRIB_API_BIN} eq "" )
        { die(" Var ncdcTigge::GRIB_API_BIN is unset!\n"); }
if( ! -d ${ncdcTigge::GRIB_API_BIN} )
	{ die(" Var ncdcTigge::GRIB_API_BIN is set incorrectly or target is not a directory.\n"); }
if( ! -r ${ncdcTigge::GRIB_API_BIN} )
	{ die(" Var ncdcTigge::GRIB_API_BIN is set incorrectly or target is unreadable.\n"); }

our $TOOL_GRIB_CONVERT = "${ncdcTigge::GRIB_API_BIN}/grib_filter";
our $TOOLS_TIGGE_CHECK = "${ncdcTigge::GRIB_API_BIN}/tigge_check";
our $TOOLS_TIGGE_SPLIT = "${ncdcTigge::GRIB_API_BIN}/tigge_split";

undef our @cleanUpList;               # holds filenames for the sub END to check if terminated

	# Check GRIB_API dependancies
if( ! -e $TOOL_GRIB_CONVERT )
	{
	print STDERR "Path to GRIB_API grib_filter ($TOOL_GRIB_CONVERT) is not found.  Edit path to GRIB_API_BIN in ncdcTigge.pm and try again. ";
	exit 0;
	}
if( ! -x $TOOL_GRIB_CONVERT )
	{
	print STDERR "Path to GRIB_API grib_filter found <$TOOL_GRIB_CONVERT> but it cannot be executed by effective user.  Investigate the binary permissions.. ";
	exit 0;
	}

if( ! -e $TOOLS_TIGGE_CHECK )
        {
        print STDERR "Path to GRIB_API tigge_check ($TOOLS_TIGGE_CHECK) is not found.  Edit path to GRIB_API_BIN in ncdcTigge.pm and try again. ";
        exit 0;
        }
if( ! -x $TOOLS_TIGGE_CHECK )
        {
        print STDERR "Path to GRIB_API tigge_check found <$TOOLS_TIGGE_CHECK> but it cannot be executed by effective user.  Investigate the binary permissions.. ";
        exit 0;
        }

if( ! -e $TOOLS_TIGGE_SPLIT )
        {
        print STDERR "Path to GRIB_API tigge_split ($TOOLS_TIGGE_SPLIT) is not found.  Edit path to GRIB_API_BIN in ncdcTigge.pm and try again. ";
        exit 0;
        }
if( ! -x $TOOLS_TIGGE_SPLIT )
        {
        print STDERR "Path to GRIB_API tigge_split found <$TOOLS_TIGGE_SPLIT> but it cannot be executed by effective user.  Investigate the binary permissions.. \n\n\n";
        exit 0;
        }

if( ! (-e $checkList) || ! (-r $checkList) ) 
	{
	print STDERR "### Required verif. list not present or unreadable: $checkList \n\n";
	exit 0;
	}

### ==========   Done Dependancy Check =================  ###



	# For diagnostics... 

print STDOUT " environment \& configuration: 
--------------------------------------------------
ENV: TIGGE_INPUT  = $ENV{TIGGE_INPUT}
ENV: TIGGE_OUTPUT = $ENV{TIGGE_OUTPUT}
ENV: TIGGE_TOOLS  = $ENV{TIGGE_TOOLS}

TOOLS_TIGGE_CHECK = $TOOLS_TIGGE_CHECK
TOOLS_TIGGE_SPLIT = $TOOLS_TIGGE_SPLIT
TOOL_GRIB_CONVERT = $TOOL_GRIB_CONVERT
        rules file: ${base}/grib_filter_rules

CYCLE_YMDH        = $CYCLE_YMDH
base              = $base
checkList         = $checkList
inputDir          = $inputDir
outputStash       = $outputStash
QCREPORTpath      = $QCREPORTpath
-------------------------------------------------- \n\n";


if( -f $ymdh ) 
	{
		# only one file targetted, so do it now and quit.
	my $rtn = main::convertFile($ymdh);
	print STDOUT " Converted single file: $ymdh [$rtn]\n";
	exit 0;
	}

if( !(-d $outputStash) )
	{ mkdir($outputStash) || die("\n### $outputStash no such output directory.\n\n"); }

if( !(-d $inputDir) )  { die("\n### not an input directory $inputDir \n\n"); }

cleanDevShm();	# make sure junk does not accumulate.
print STDOUT "$0 proceeding to convert entire directory: [$inputDir] >> [$outputStash] ...\n\n";

opendir(IN,$inputDir);
my @files = sort grep(/${ncdcTigge::gefs_filepattern}/,readdir(IN));
closedir(IN);

# tigge_split bombs output into the current working directory
# so the easiest way to control it is to move in there now and
# use absolute paths to tigge_split input.

our $outCache = "$ENV{TIGGE_OUTPUT}/${ymdh}";
if( !(-d $outCache) )
	{ 
	mkdir($outCache) || die("\n### could not mkdir output directory : $outCache\n\n"); 
	}
chdir($outCache);
if( !(-d $outCache) )
	{ die("\n### could not mkdir output directory : $outCache\n\n"); }

opendir(CLEANER,$outCache );
my @existoutlist = readdir(CLEANER);
closedir(CLEANER);

	# if there anything already in output.. clean it up.
foreach my $tmpoutDel ( @existoutlist ) 
	{ unlink("${outCache}/$tmpoutDel"); }

undef my @rtnCodes;
print STDOUT "\n -- Progress ---------------------------\n\n";
foreach my $f ( @files ) 
	{
	push(@rtnCodes, main::convertFile("$inputDir/$f") );
	}


my @rtn0 = grep(/0/,@rtnCodes  );
my @rtn1 = grep(/-1/,@rtnCodes );
my @rtn2 = grep(/-2/,@rtnCodes );
my @rtn3 = grep(/-3/,@rtnCodes );
my @rtn4 = grep(/-4/,@rtnCodes );
my @rtn5 = grep(/-5/,@rtnCodes );
my $fTot = $#files+1;

	# Diagnostic output results.
print STDOUT "rtnCodes  REPORT -------------------------
  Total : $fTot Files converted
  0 OK                    : $#rtn0 
 -1 Target DNE            : $#rtn1
 -2 Cannot read Target    : $#rtn2
 -3 Bad filePathHead      : $#rtn3
 -4 Rules file missing    : $#rtn4
 -5 Rules unreadable      : $#rtn5 \n\n";

my @finalRtn = main::qcOutput2( $ymdh );
if( $finalRtn[0] eq "OK" ) 
	{
	print STDOUT " Verif. Post process completed: $finalRtn[1]\n\n";
	if( length( $finalRtn[2] ) > 0 ) 
		{  print STDOUT "*** Non critical Errors Were Recorded\n\n$finalRtn[2]\n\nEND of errors\n\n";  }
	}
else
	{
	print STDOUT "### Verifier detected issues: [$#finalRtn] (@finalRtn) \n\n======= END of issues====\n\n\n";
	}


	# Cleanup
opendir( DEL,$outputStash );
my @dellist = readdir(DEL);
closedir( DEL );
foreach my $rmf ( sort @dellist )
	{
	my $targetRm = "$outputStash/$rmf";
	if( !(-f $targetRm) ) { next; }
	unlink($targetRm);
	}
rmdir($outputStash);

print STDOUT "$0 @ARGV DONE   ".scalar localtime(time)."\n\n";

exit(0);

sub convertFile($)
	{
	my $headline = "$0:convertFile() : ";
	my $filePath = shift(@_);
	my $rulesFile = "${base}/grib_filter_rules";

#print STDOUT "DEBUG $headline $filePath w/ $rulesFile\n";

	if( !(-e $filePath) )   { return(-1); }
	if( !(-f $filePath) )   { return(-2); }
	if( !(-f $rulesFile))   { return(-4); }
	if( !(-r $rulesFile))   { return(-5); }

	$progressCounter++;
	if( $progressCounter % 100 == 0 )
		{
		$progressCounter -= 100;
		print STDOUT "o";
		}
# print STDOUT " Sub got << $filePath >> \n";

	my $filePathHead = $filePath;
	if( $filePathHead eq "" || $filePathHead =~ m/^\./ ) 
		 { return(-3); }
	$filePathHead =~ s/^.*\///g;

#print STDOUT " DEBUG > sub > got $filePathHead :: $filePath \n";

	open( LOG,">>","./convert.log" ) || die("\n$0 could not open logging.\n\n");
	if ( !-d $ENV{TIGGE_PTMP}) {
		make_path($ENV{TIGGE_PTMP}) || die ("\n$0 could not create temp directory $ENV{TIGGE_PTMP}\n\n");
	}
	my $tmpOut = "$ENV{TIGGE_PTMP}/${filePathHead}_convert.$$.grb2";

#print STDOUT "DEBUG (main proceedure) \n
#------------------------------------------------------------------
#  my \$tmpOut = $tmpOut
#  my \@rtn01  = $TOOL_GRIB_CONVERT -v $rulesFile $filePath -o $tmpOut 2>&1
#  my \@rtn02  = $TOOLS_TIGGE_CHECK -z -g $tmpOut.good $tmpOut 2>&1
#  my \@rtn03  = $TOOLS_TIGGE_SPLIT -p $tmpOut.good 2>&1
#------------------------------------------------------------------
#\n";

	my @rtn01 = (`$TOOL_GRIB_CONVERT -v $rulesFile $filePath -o $tmpOut 2>&1`);
	my @rtn02 = (`$TOOLS_TIGGE_CHECK -z -g $tmpOut.good $tmpOut 2>&1`);
	my @rtn03 = (`$TOOLS_TIGGE_SPLIT -p $tmpOut.good 2>&1`);

	push( @cleanUpList,$tmpOut );
	push( @cleanUpList,"$tmpOut.good" );

	print LOG "-------------------------------------------------\n";
	print LOG "$filePath <[ @rtn01\n\n@rtn02\n\n@rtn03]>\n\n\n";
	close(LOG);

	unlink($tmpOut);
	#print STDOUT " > sub > END normal\n";
	return(0);
	}


# =========================================================
# Output QC Routine for NCAR-NCDC-TIGGE component
# uses a hard configuration file of patterns to check for.
#  This must be present in ENV TIGGE_HOME
#  If there are no problems, it goes ahead and runs tar on the cycle output

sub qcOutput2($)
{
my $ymdh = shift(@_);
if( $ymdh !~ m/^\d{10}$/ )  { return(-1); }
my $archiveStash = "$ENV{TIGGE_OUTPUT}/archive";

if( !(-d $outputStash) ) 
	{ mkdir($outputStash) || return("\n### $outputStash no such output directory.\n\n"); }
if( !(-f $checkList) )
        { return("\n### $checkList no such verification list file.\n\n"); }

my $subStartTime = time;
undef my @tarList;
undef my @errorList;

open(LIST,"<",$checkList);
my @checkListPatterns = readline(LIST);
close(LIST);

opendir(STASH,$outputStash);
my @theOutput = grep(/\.grib$/,readdir(STASH));
closedir(STASH);

open(REP,">",$QCREPORTpath);

foreach my $pattern ( @checkListPatterns )
	{
	chomp($pattern);
	my @articles = split(/,/,$pattern);
	my $matcher = qq(z_tigge_c_kwbc_.............._...._${articles[6]}_${articles[0]}_${articles[1]}_${articles[2]}_${articles[3]}_${articles[4]}_${articles[5]}.grib);

	my @scan = grep( /$matcher/i, @theOutput );

# print STDOUT " VERIF $matcher = $#scan \n";

	if( $#scan == 0 ) 
		{ push(@tarList,$scan[0]); }
	else 
		{ push(@errorList,"file [$matcher] expected but not found"); }

	print REP " :: $pattern :: [ $#scan ] \n";
	}

close(REP);



# Eventually we will check & stop here if there were QC errors.
#   but this is preliminary.

if( 1 == 1 ) 
	{
	my $tarListFile = "$outputStash/tarListFile$$";
	my $tarArchiveUnit = "$archiveStash/tigge-kwbc-${ymdh}.tar";
        if( !(-d "$archiveStash") )
                { mkdir($archiveStash) || return(-2); }

	open(TARLIST,">",$tarListFile);
	foreach my $unit ( @tarList )
		{ print TARLIST "$unit\n"; }
	print TARLIST "$QCREPORT";
	close(TARLIST);

	if( !(-f $tarArchiveUnit) ) 
		{
		print STDOUT "Concatenating files into smaller units:  $outputStash\n\n";
		my $catRtn = ncdcTigge::mergeRecords( $outputStash, $outputStash, $ymdh );
		if( $catRtn != 0 ) 
			{ print STDOUT "WARNING problem $catRtn concatenating output files!\n\n"; }

		if( !(-d $outputArchive) )    { mkdir($outputArchive); }
        if( !(-d $outputArchive) )
			{
			chdir( $outputStash) || return( "chdir failed","chdir failed" );
			print STDOUT " tarring $tarArchiveUnit \@ ".scalar(localtime(time))."\n";
			print STDOUT (`tar -cf $tarArchiveUnit --files-from=$tarListFile`);
			chdir( $base );
			}
		else		# just mv them to output/archive/ymdh
			{
			print STDOUT "$headline  moving files to $outputArchive\n\n";
			print STDOUT (`mv $outputStash/*.grib $outputArchive`);
			}
		}

	unlink($tarListFile);
	unlink($QCREPORTpath);
	}
else
	{ return("\n\nCounts [$#tarList / $#errorList] ",join("\n",@errorList) ); }

my $subFinishTime = time;
my $subTime = $subFinishTime - $subStartTime;

return("OK","Counts [$#tarList / $#errorList] in $subTime sec.",join("\n",@errorList) );
}


sub cleanDevShm()
        {
        opendir(DSM,"/dev/shm") || return;
        my @rd = grep(/\.gri?b2?/i ,readdir(DSM));
	@rd = grep(/$CYCLE_YMDH/, grep(/\.gri?b2?/i ,readdir(DSM)) );

        closedir(DSM);
        foreach my $f ( sort @rd )
                {
                my $fn = "/dev/shm/$f";
                my $age = (-M $fn);
                if( $age > 0.1 )        # roughly 2.4 hrs
                        { unlink("/dev/shm/$f"); }
                }
        }


sub END
	{
	foreach my $path ( @cleanUpList )
		{
		if( (-e $path) && (-f $path) )
			{
			unlink($path);
			}
		}
	main::cleanDevShm();
	}


