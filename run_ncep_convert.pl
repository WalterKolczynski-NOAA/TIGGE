#!/usr/bin/perl -w
use strict;
use ncdcTigge 1.1;
sub convertFile($);
sub qcOutput2($);
sub cleanDevShm();

my $ymdh = shift(@ARGV);

print STDOUT "$0 @ARGV Run at ".scalar localtime(time)."\n\n";

my $headline = "$0 (@ARGV) : ";
print STDOUT "\n$headline Started \@ ".localtime(time)."\n\n";


our $TOOL_GRIB_CONVERT = "${ncdcTigge::GRIB_API_BIN}/grib_filter";
our $TOOLS_TIGGE_CHECK = "${ncdcTigge::GRIB_API_BIN}/tigge_check";
our $TOOLS_TIGGE_SPLIT = "${ncdcTigge::GRIB_API_BIN}/tigge_split";

undef our @cleanUpList;               # holds filenames for the sub END to check if terminated

	# Check GRIB_API dependancies
if( ! -e $TOOL_GRIB_CONVERT )
	{
	print STDERR "Path to GRIB_API grib_filter is not found.  Edit path to GRIB_API_PATH in ncdcTigge.pm and try again. ";
	exit 0;
	}
if( ! -x $TOOL_GRIB_CONVERT )
	{
	print STDERR "Path to GRIB_API grib_filter found <$TOOL_GRIB_CONVERT> but it cannot be executed by effective user.  Investigate the binary permissions.. ";
	exit 0;
	}

if( ! -e $TOOLS_TIGGE_CHECK )
        {
        print STDERR "Path to GRIB_API tigge_check is not found.  Edit path to GRIB_API_PATH in ncdcTigge.pm and try again. ";
        exit 0;
        }
if( ! -x $TOOLS_TIGGE_CHECK )
        {
        print STDERR "Path to GRIB_API tigge_check found <$TOOLS_TIGGE_CHECK> but it cannot be executed by effective user.  Investigate the binary permissions.. ";
        exit 0;
        }

if( ! -e $TOOLS_TIGGE_SPLIT )
        {
        print STDERR "Path to GRIB_API tigge_split is not found.  Edit path to GRIB_API_PATH in ncdcTigge.pm and try again. ";
        exit 0;
        }
if( ! -x $TOOLS_TIGGE_SPLIT )
        {
        print STDERR "Path to GRIB_API tigge_split found <$TOOLS_TIGGE_SPLIT> but it cannot be executed by effective user.  Investigate the binary permissions.. \n\n\n";
        exit 0;
        }

### ==========   Done Dependancy Check =================  ###



print STDOUT "GRIB tool configuration: 
TOOL_GRIB_CONVERT = $TOOL_GRIB_CONVERT
	rules file: $ENV{TIGGE_TOOLS}/grib_filter_rules
TOOLS_TIGGE_CHECK = $TOOLS_TIGGE_CHECK
TOOLS_TIGGE_SPLIT = $TOOLS_TIGGE_SPLIT \n\n";

if( -f $ymdh ) 
	{
		# only one file targetted, so do it now and quit.
	my $rtn = main::convertFile($ymdh);
	print STDOUT " Converted single file: $ymdh [$rtn]\n";
	exit 0;
	}

if( $ymdh !~ m/\d{4}[0-1]\d[0-3]\d[0-2]\d/ )  
	{ exit 0; }

our $inputDir     = "$ENV{TIGGE_INPUT}/$ymdh";
our $outputStash  = "$ENV{TIGGE_OUTPUT}/$ymdh";
if( !(-d $outputStash) )
	{ mkdir($outputStash) || die("\n### $outputStash no such output directory.\n\n"); }

if( !(-d $inputDir) )  { die("\n### not an input directory $inputDir \n\n"); }

cleanDevShm();	# make sure junk does not accumulate.
print STDOUT "$0 proceeding to convert entire directory: [$inputDir] >> [$outputStash] ...\n\n";

opendir(IN,$inputDir);
my @files = sort grep(/\.grb2$/,readdir(IN));
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

# -testing-
# main::convertFile("/home/nomads/tigge-svn/input/2014090418/gens-b_3_20140904_1800_384_12.grb2");
# main::convertFile("/home/nomads/tigge-svn/input/2014090418/gens-b_3_20140904_1800_060_08.grb2");
# main::convertFile("/home/nomads/tigge-svn/input/2014090418/gens-b_3_20140904_1800_120_11.grb2");
# main::convertFile("/home/nomads/tigge-svn/input/2014090418/gens-b_3_20140904_1800_180_13.grb2");
undef my @rtnCodes;
foreach my $f ( @files ) 
	{
	push(@rtnCodes, main::convertFile("$inputDir/$f") );
	}

my @finalRtn = main::qcOutput2( $ymdh );
if( $finalRtn[0] eq "OK" ) 
	{
	print STDOUT " Verif. Post process completed: $finalRtn[1]\n\n";
	}
else
	{
	print STDOUT "### Verifier detected issues:  $finalRtn[1]\n\n$finalRtn[2]\n\n======= END of issues====\n\n\n";
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
	my $filePath = shift(@_);

	if( !(-e $filePath) )   { return(-1); }
	if( !(-f $filePath) )   { return(-1); }

# print STDOUT " Sub got << $filePath >> \n";

	my $filePathHead = $filePath;
	if( $filePathHead eq "" || $filePathHead =~ m/^\./ ) 
		 { return(-2); }
	$filePathHead =~ s/^.*\///g;

	#print STDOUT " > sub > got $filePathHead :: $filePath \n";

	open(LOG,">>","./convert.log") || die("\n$0 could not open logging.\n\n");

	my $tmpOut = "/dev/shm/${filePathHead}_convert.$$.grb2";
	my @rtn01 = (`$TOOL_GRIB_CONVERT -v $ENV{TIGGE_TOOLS}/grib_filter_rules $filePath -o $tmpOut 2>&1`);
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
my $checkList = "$ENV{TIGGE_TOOLS}/output-list.txt";

if( !(-d $outputStash) ) 
	{ mkdir($outputStash) || return("\n### $outputStash no such output directory.\n\n"); }
if( !(-f $checkList) )
        { return("\n### $checkList no such verification list file.\n\n"); }

my $subStartTime = time;
undef my @tarList;
undef my @errorList;
our $QCREPORT = "tigge-output-qc-report-for-${ymdh}.txt";
our $QCREPORTpath = "$outputStash/$QCREPORT";

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
	my $matcher = "z_tigge_c_kwbc_.............._...._${articles[6]}_${articles[0]}_${articles[1]}_${articles[2]}_${articles[3]}_${articles[4]}_${articles[5]}.grib";

# z_tigge_c_kwbc_20140910120000_glob_prod_pf_sl_0384_020_0000_2t.grib
# pf,sl,0384,004,0000,mn2t6,prod

	my @scan = grep( /$matcher/i, @theOutput );

	print STDOUT " VERIF $matcher = $#scan \n";

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
		{
		print TARLIST "$unit\n";
		}
	print TARLIST "$QCREPORT";
	close(TARLIST);

	if( !(-f $tarArchiveUnit) ) 
		{
		chdir($outputStash) || return("chdir failed","chdir failed");
		print STDOUT " tar: Creating $tarArchiveUnit \@ ".scalar(localtime(time))."\n";
		print STDOUT (`tar -cf $tarArchiveUnit --files-from=$tarListFile`);
		chdir($ENV{"TIGGE_TOOLS"});
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
	}


