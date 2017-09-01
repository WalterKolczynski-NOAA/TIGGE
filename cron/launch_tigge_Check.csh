#!/bin/csh
#
#        Launches the ncdcTiggeFTP ingest process
#               ARG 1 : YYYYMMDDHH, current if omitted
#

# set echo

set com = $0
echo ""
echo "Executing $com:t ... `date`"
echo "  `uname -a`"
echo ""
set yyyymmddhhmm = `date +%Y%m%d%H%M`
set log_path = "${CRONTAB_LOGS}/tiggeRunCheck.${yyyymmddhhmm}.log"
echo ""
echo "Creating log ..."
echo "  $log_path"
( cd $TIGGE_TOOLS/bin; /usr/bin/perl ./runCheck.pl ) >& $log_path &
echo ""

echo ""
echo "Exiting $com:t ... `date`"
echo "  `uname -a`"
echo ""
exit
