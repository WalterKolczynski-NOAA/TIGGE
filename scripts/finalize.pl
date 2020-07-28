#!/usr/bin/perl -w

use ncdcTigge 1.4 (archiveOutput,packCycle);
use strict;

# As the name implies, this independantly runs the final steps to prepare a KWBC-TIGGE package.
# archiveOutput moves the completed ncdcTigge output to the output/archive area.
# packCycle forms it into a .tar package
# Swank (Feb.2018)


if( !(scalar grep(/$ENV{'TIGGE_TOOLS'}/,@INC)) )
	{ push(@INC,"$ENV{'TIGGE_TOOLS'}"); }

my $st = time;

my $run = shift @ARGV;
if( $run !~ m/^\d{10}$/ ) { die("### I need a YYYYMMDDHH in ARG0\n\n"); }

my $runPath = "$ENV{'TIGGE_INPUT'}/${run}";
my $tagFile = "${runPath}/.completed";
my $outputTagFile = "$ENV{'TIGGE_OUTPUT'}/OUTPUT.QC.PASS.${run}";

if( ( -f $tagFile)  && (scalar(grep(/-froce/i,@ARGV))) ) 
	{ die("$0 : Task already completed.  use -force to override.\n\n"); }

if( !(-f $outputTagFile) && !(-f $tagFile)  ) 
	{ die("### This output run ($run) has not passed QC.\n\nTo override, Check file flags :\n$outputTagFile\n$tagFile\n\n"); }
else
	{ print STDOUT " o  Verified tagFile :\n $outputTagFile\n\n"; }


    # Output is OK, proceeed with the final steps
print "$0 : QC Passed.  Finalizing output for:\n\n";
print STDOUT ncdcTigge::archiveOutput("_${run}0000_",
    "\^OUTPUT.QC.PASS.${run}\$");
print STDOUT ncdcTigge::packCycle( $run );

    # Mark a completed run with hidden file
open(TAG,">",$tagFile)
  || print STDOUT "### $0 Error writing tag file!\n";
print TAG "$$\n".localtime(time);
close(TAG);

my $et = time - $st;
print "$0 Took $et seconds.\n\n";

exit 0;
