#!/usr/bin/perl -w

# THIS IS NO LONGER USED TO TRANSFER DATA
exit 0;

if( !(scalar grep(/$ENV{'TIGGE_TOOLS'}/,@INC)) )
    { push(@INC,"$ENV{'TIGGE_TOOLS'}"); }

use ncdcTiggeFTP 0.85 (uploadResults);

# Driver for the routine : ncdcTigge::uploadResults
#  locates and uploads all completed tar.gz files that
#	 have not already been uploaded to NCAR

$ncdcTigge::forceOption  = "no";
$ncdcTigge::ftpTimeout   = 20;
$ncdcTigge::ftpDebug     = 0;
print STDOUT ncdcTiggeFTP::uploadResults();
print "\n\n$0 : Done with test.\n\n";
exit 0;
