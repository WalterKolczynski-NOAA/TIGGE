#!/usr/bin/perl -w
# Shell calling script that will rerun a cycle that has successfully run ncdcTigge
#  but has a problem with run_ncep_convert portion.

use strict;

my $start = time; 

my $theDate = scalar(localtime(time));
my $cycleYMDH = shift(@ARGV);
if( $cycleYMDH !~ m/^\d{10}$/ )  
	{ die("\nInvalid arguments.  Give the yyyymmddhh for the cycle to rerun.\n\n"); }

print STDOUT "\n$0 @ARGV Started $theDate \n\n";

my $primary = "$ENV{TIGGE_OUTPUT}/archive/tigge-kwbc-${cycleYMDH}.tar";
my $secondary = "$ENV{TIGGE_OUTPUT}/archive/gens-tigge_3_${cycleYMDH}.tar";
my $secondarySize = (-s $secondary);

if( !(-e $secondary) || !(-r $secondary) )
        {
        die("\nSecondary does not exist.  run [ncdcTigge $cycleYMDH all] and finalize\n x  $secondary\n\n");
        }
if( $secondarySize < 720000000 )
	{ 
	die("\nSecondary appears deficient size.  rerun [ncdcTigge $cycleYMDH all] and finalize\n\n"); 
	}


$theDate = scalar(localtime(time));
print STDOUT "\n$theDate : Regenerating primary \n ($primary)...\n\n";
if( -e $primary ) 
	{ 
	print STDOUT "Cleared existing primary ($primary)...\n\n";
	unlink($primary); 
	}
print STDOUT (`perl $ENV{TIGGE_TOOLS}/bin/run_ncep_convert.pl $cycleYMDH >&./rerun.$cycleYMDH.log`);

$theDate = scalar(localtime(time));
print STDOUT "\n$theDate * Concatenating secondary \n ($secondary) $secondarySize bytes\n\n";
print STDOUT (`tar --concatenate --file=$primary  $secondary`);

$theDate = scalar(localtime(time));
my $et = time - $start;
my $etMin = int($et/60)+1;
print STDOUT "$theDate : Done. - That took $etMin minutes\n\n";
exit 0;
