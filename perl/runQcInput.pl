#!/usr/bin/perl -w

# sub BEGIN { 
# 	$ENV{'TIGGE_TOOLS'} = "/home/nomads/tigge-dev";
# 	push @INC,$ENV{'TIGGE_TOOLS'}; }

my $st = time;

if( !(scalar grep(/$ENV{'TIGGE_TOOLS'}/,@INC)) ) 
	{ push(@INC,"$ENV{'TIGGE_TOOLS'}"); }
use ncdcTigge 1.3 (qcGensCycle) ;

if( $ARGV[0] !~ m/^\d{4}[0-1]\d[0-3]\d[0-2]\d$/ ) 
	{
	die("\n### Must supply a YYYYMMDDHH in ARG1\n\tSpecifies cycle to QC\n\n");
	}

# print (`echo "TEST POINT 1"`);

print STDOUT ncdcTigge::qcGensCycle($ARGV[0]);

my $et = time - $st;

print STDOUT "\n That took $et seconds.\n\n\n";

exit 0;
