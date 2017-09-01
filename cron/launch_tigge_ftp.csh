#!/bin/csh
#
#        Launches the ncdcTiggeFTP ingest process
#               ARG 1 : YYYYMMDDHH, current if omitted

# set echo

set com = $0
echo ""
echo "Executing $com:t ... `date`"
echo "  `uname -a`"
echo ""
set yyyymmddhhmm = `date +%Y%m%d%H%M`
set log_path = "${CRONTAB_LOGS}/runTiggeFTP-a-1.${yyyymmddhhmm}.log"
echo ""
echo "Creating log ..."
echo "  $log_path"
( cd $TIGGE_TOOLS/bin; /usr/bin/perl ./ftpprdPull-a.pl 0 384 0 10 $1 ) >& $log_path &
echo ""

sleep 5;

set log_path = "${CRONTAB_LOGS}/runTiggeFTP-a-2.${yyyymmddhhmm}.log"
echo ""
echo "Creating log ..."
echo "  $log_path"
( cd $TIGGE_TOOLS/bin; /usr/bin/perl ./ftpprdPull-a.pl 0 384 11 20 $1 ) >& $log_path &
echo ""

sleep 5;

set log_path = "${CRONTAB_LOGS}/runTiggeFTP-b.${yyyymmddhhmm}.log"
echo ""
echo "Creating log ..."
echo "  $log_path"
( cd $TIGGE_TOOLS; /usr/bin/perl ./ftpprdPull-b.pl 0 384 0 20 $1 ) >& $log_path &
echo ""

echo ""
echo "Exiting $com:t ... `date`"
echo "  `uname -a`"
echo ""
exit
