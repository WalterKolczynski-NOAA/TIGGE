#! /usr/bin/sh

set -x

time=$1
year=$(echo $time | cut -c1-4)
month=$(echo $time | cut -c5-6)

cd "${TIGGE_OUTPUT}/archive"
tarfile="tigge-kwbc-${time}.tar"
hpss="/NCEPDEV/emc-ensemble/2year/tigge"

source $MODULESHOME/init/sh                       2>/dev/null
module load HPSS/5.0.2.5
hsi mkdir $hpss/$year
hsi mkdir $hpss/$year/$month
hsi put $tarfile : $hpss/$year/$month/$tarfile

err=$?
if [[ $err != 0 ]]; then
	echo "FATAL ERROR from hsi: $err"
else
	echo "Archive to HPSS completed successfully"
fi
exit $err
