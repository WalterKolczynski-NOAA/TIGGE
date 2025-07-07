#! /usr/bin/env bash

cd "$(dirname ${BASH_SOURCE[0]})"
source preamble.sh
source setup_machine.sh

time=${1}
module use ../modulefiles > /dev/null 2>&1
module load run.${MACHINE} > /dev/null 2>&1

year=${time:1:4}
month=${time:4:2}

cd "${TIGGE_OUTPUT}/archive"
tarfile="tigge-kwbc-${time}.tar"
remote="s3://noaa-nws-global-pds/tigge"
# expiration_date=$(date --utc -d "28 days" +"%Y-%m-%dT%H:%M%SZ")

# Compute sha256 checksum and save
sha256sum "${tarfile}" > "${tarfile}.sha256"

# Transfer files to AWS S3 bucket
# aws s3 cp "${tarfile}" "${tarfile}.sha256" "${remote}/" --expires "${expiration_date}"
# aws s3 cp "${tarfile}" "${tarfile}.sha256" "${remote}/"
aws s3 cp "${tarfile}" "${remote}/"
aws s3 cp "${tarfile}.sha256" "${remote}/"

err=$?
if ((err != 0)); then
	echo "FATAL ERROR from AWS: ${err}"
	exit "${err}"
else
	echo "rsync to AWS completed successfully"
fi

exit "${err}"
