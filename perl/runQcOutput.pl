#!/usr/bin/perl -w

if( !(scalar grep(/$ENV{'TIGGE_TOOLS'}/,@INC)) )
    { push(@INC,"$ENV{'TIGGE_TOOLS'}"); }

my $st = time;

use ncdcTigge 1.3 (qcOutput);

# Driver for the routine : ncdcTigge::qcOutput
#  Checks files created by ncdcTigge application
#	 neeeds a DTG, will check data in TIGGE_OUTPUT

if( !($ARGV[0] =~ m/\d{4}[0-1]\d[0-3]\d[0-2]\d/) ) 
	{ die("\n\n### $0 : I need a DTG in arg 1.\n\n"); }
my $DTG = shift(@ARGV);

@results =  ncdcTigge::qcOutput($DTG);
foreach my $r ( @results ) 
	{ print STDOUT "  $r\n"; }
my $et = time - $st;
print STDOUT "\n$0 : Done  ($et seconds) \n\n";
exit 0;
