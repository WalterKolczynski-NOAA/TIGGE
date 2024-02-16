#! /usr/bin/env bash

cd "$(dirname ${BASH_SOURCE[0]})"
source preamble.sh
source setup_machine.sh

time=${1}
module use ../modulefiles > /dev/null 2>&1
module load run.${MACHINE} > /dev/null 2>&1

year=$(echo $time | cut -c1-4)
month=$(echo $time | cut -c5-6)

cd "${TIGGE_OUTPUT}/archive"
tarfile="tigge-kwbc-${time}.tar"
hpss="/NCEPDEV/emc-ensemble/2year/tigge"

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
