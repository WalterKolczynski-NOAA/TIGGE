#!/usr/bin/perl -w
## very simple script designed to run shell commands in the correct order for multiple cycles.
#
#   required ARG 0 : path to list file defining cycles <yyyymmddhh> - one on each line.
#   optional ARG 1 : PATH to redefine TIGGE_INPUT
#
sub main::printTime;

# Can change input directory with second arg
if( defined( $ARGV[1] ) && (-d $ARGV[1]) && (-r $ARGV[1]) )
	{ $ENV{TIGGE_INPUT} = $ARGV[1]; }

open( LI,"<",$ARGV[0] ) || die(" need list path in ARGV 0 ");
my @iList = readline(LI);
close(LI);

my $program = "$ENV{TIGGE_TOOLS}/bin/rerun_ncep_convert.pl";
if( !(-e $program) ) 
	{ die("\n### STOP: cannot find program:  $program\n\n"); }
if( !(-x $program) )
        { die("\n### STOP: cannot exec. program:  $program\n\n"); }

foreach my $cyc ( sort @iList ) 
	{
	my $t0 = time;
	chomp($cyc);
	print STDOUT "\n\n ------------------ >> $cyc << -----------\n\n";
	print(`perl rerun_ncep_convert.pl $cyc >&./rerun.$cyc.log `);
        my $t1 = time;

	my $t1Hr = int($t1/3600);
	print STDOUT "\n\n\n <<Done $cyc >> That took $t1 sec.  ($t1Hr hr) \n\n\n";
	}

sub printTime
	{
	print STDOUT scalar localtime(time);
	}

print STDOUT "\n\n$0  FINISHED.\n\n\n";


