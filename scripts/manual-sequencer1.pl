#!/usr/bin/perl -w
#
## simple script designed to run shell commands in the correct order to rerun multiple cycles.
#
##  This assumes cycles have passed runQcInput.pl already.
##  verified cycles are given in a list file (arg0) in form <yyyymmddhh> one per line.
#
#  Important:  ncdcTigge C binary expects a directory called ./input to be present.
#     as one might expect, this is where it draws its input.
#  For this reason, a chdir() to TIGGE_TOOLS is done in case this script is run in
#      a different directory.
#

sub main::printTime;

chdir($ENV{TIGGE_TOOLS}) || die("\n### cannot chdir to \"$ENV{TIGGE_TOOLS}\", to access binaries.
If empty, one needs to define ENV TIGGE_TOOLS\n\n");

if( !(-d "./input") )
	{ die("### ./input does not exist.  mkdir or sym.link this for input stash.\n"); }

open( LI,"<",$ARGV[0] ) || die("\nneed list file in ARG 0.\n\n");
my @iList = readline(LI);
close(LI);

foreach my $cyc ( sort @iList ) 
	{
	my $t0 = time;
	chomp($cyc);

        if( $cyc !~ m/^\d{10}$/ )
            { next; }
	my $dirTest = "./input/$cyc";
	if( !(-d $dirTest) || !(-r $dirTest) ) 
	   { print " x  No Input Directory: $dirTest : adjust sym link?\n";  next; }

	print STDOUT "\n\n ------------------ >> $cyc << -----------\n\n";
	print(`./ncdcTigge $cyc all`);
        my $t1 = time;
	my $et1 = $t1 - $t0;
	print(`perl runQcOutput.pl $cyc`);
        my $t2 = time;
	my $et2 = $t2 - $t0;
	print(`perl finalize.pl $cyc`);
	my $et = time - $t0;
	print STDOUT "\n\n\n <<Done $cyc >> [$et sec. :: $et1, $et2] \n\n\n";
	}

sub printTime
	{
	print STDOUT scalar localtime(time);
	}


