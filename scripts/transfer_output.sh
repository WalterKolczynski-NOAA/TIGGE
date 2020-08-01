#! /usr/bin/sh

time=$1
year=$(echo $time | cut -c1-4)
month=$(echo $time | cut -c5-6)

cd "$(dirname $(pwd))/output/archive"
tarfile="tigge-kwbc-${time}.tar"
remote="rzdm:/home/ftp/emc/ufs/global/ensemble/tigge/$tarfile"
hpss="/NCEPDEV/emc-ensemble/2year/tigge"

rsync -a --progress -e 'ssh -C -F /u/Walter.Kolczynski/ssh_config' --partial-dir=.tmp $tarfile $remote

err=$?
if [[ $err != 0 ]]; then
	echo "FATAL ERROR from rsync: $err"
	exit $err
fi

hsi mkdir $hpss/$year
hsi mkdir $hpss/$year/$month
hsi put $tarfile : $hpss/$year/$month/$tarfile

err=$?
if [[ $err != 0 ]]; then
	echo "FATAL ERROR from hsi: $err"
fi
exit $err
