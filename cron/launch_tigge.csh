#!/bin/csh
#
# Launches the ncdcTigge end-to-end gens processing
#       ARG 1 ($1) may be used to specify the number of previous cycles to
#        process
#
# Also launches an instance of the file uploader, to send completed files
#       To NCAR
#
# set echo
set com = $0
echo ""
echo "Executing $com:t ... `date`"
echo "  `uname -a`"
echo ""
set yyyymmddhhmm = `date +%Y%m%d%H%M`
set log_path = "${CRONTAB_LOGS}/runTigge.${yyyymmddhhmm}.log"
echo ""
echo "Creating log ..."
echo "  $log_path"
( cd $TIGGE_TOOLS/bin; /usr/bin/perl ./runTigge.pl $1 ) >& $log_path &

echo ""

# --  ftp upload to NCAR is no longer used. --
#
# set log_path = "${CRONTAB_LOGS}/runTiggeUpload.${yyyymmddhhmm}.log"
echo ""
echo "Creating log ..."
echo "  $log_path"
( cd $TIGGE_TOOLS; /usr/bin/perl ./runUploader.pl ) >& $log_path &

echo ""
echo "Exiting $com:t ... `date`"
echo "  `uname -a`"
echo ""
exit
