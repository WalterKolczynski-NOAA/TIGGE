#!/usr/bin/perl -w 
#
#	Calls the ncdcTigge.pm module to the routine which grabs gens-B files
#	ARGS <fctHr Start> <fctHr End> <Member Start> <Member End> [yyyymmddhh]
#
# ENV check
$ENV{'TIGGE_INPUT'} ||
    die("### $0 : Environmental Variable TIGGE_INPUT must be set to a base directory path to place downloaded files!\n\n");
$ENV{'TIGGE_OUTPUT'} ||
    die("### $0 : Environmental Variable TIGGE_OUTPUT must be set to a directory path to place generated data!\n\n");
$ENV{'TIGGE_TOOLS'} ||
    die("### $0 : Environmental Variable TIGGE_TOOLS must be set to the directory path that holds the tigge executables!\n\n");

if( !(scalar grep(/$ENV{'TIGGE_TOOLS'}/,@INC)) )
    { push(@INC,"$ENV{'TIGGE_TOOLS'}"); }

use ncdcTiggeFTP 0.98;

# ARG Parse
if( $#ARGV < 3 ) 
	{ die "### $0 Usage: <fctHr Start> <fctHr End> <Member Start> <Member End> [yyyymmddhh (defaults to latest)]\n\n"; }
my $date = "latest";
if( defined($ARGV[4]) ) 
	{ $date = $ARGV[4]; }

# Run cmd
ncdcTiggeFTP::ingestFtpprd($date,"b",$ARGV[0],$ARGV[1],$ARGV[2],$ARGV[3]);

exit 0;
