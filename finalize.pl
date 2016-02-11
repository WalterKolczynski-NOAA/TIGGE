#!/usr/bin/perl -w

if( !(scalar grep(/$ENV{'TIGGE_TOOLS'}/,@INC)) )
    { push(@INC,"$ENV{'TIGGE_TOOLS'}"); }

use ncdcTigge 1.1 (archiveOutput,packCycle);

$run = shift @ARGV;
if( $run !~ m/^\d{10}$/ ) { die("### I need a YYYYMMDDHH in ARG0\n\n"); }

my $runPath = "$ENV{'TIGGE_INPUT'}/${run}";
my $tagFile = "${runPath}/.completed";
my $outputTagFile = "$ENV{'TIGGE_OUTPUT'}/OUTPUT.QC.PASS.${run}";

if( ( -f $tagFile)  && (scalar(grep(/-froce/i,@ARGV))) ) 
	{ die("$0 : Task already completed.  use -force to override.\n\n"); }

if( !(-f $outputTagFile) && !(-f $tagFile)  ) 
	{ die("### This output run ($run) has not passed QC.\n\n"); }
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

exit 0;
