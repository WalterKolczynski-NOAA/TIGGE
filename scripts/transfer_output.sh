#! /usr/bin/sh

set -x

time=$1
year=$(echo $time | cut -c1-4)
month=$(echo $time | cut -c5-6)

cd "${TIGGE_OUTPUT}/archive"
tarfile="tigge-kwbc-${time}.tar"
remote="rzdm:/home/ftp/emc/ufs/global/ensemble/tigge/$tarfile"

rsync -a -e 'ssh -C -F /u/Walter.Kolczynski/ssh_config' --partial-dir=.tmp $tarfile $remote

err=$?
if [[ $err != 0 ]]; then
	echo "FATAL ERROR from rsync: $err"
	exit $err
else
	echo "rsync to rzdm completed successfully"
fi

exit $err
