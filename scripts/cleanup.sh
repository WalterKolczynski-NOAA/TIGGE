#! /usr/bin/env bash

cd "$(dirname ${BASH_SOURCE[0]})"
source preamble.sh
source setup_machine.sh

time=${1:?}
module use ../modulefiles > /dev/null 2>&1
module load run.${MACHINE} > /dev/null 2>&1

year=$(echo $time | cut -c1-4)
month=$(echo $time | cut -c5-6)
PDY=$(echo $time | cut -c1-8)
cyc=$(echo $time | cut -c9-10)

cd "${TIGGE_PTMP}"
for location in "hpss/gefs.${PDY}/${cyc}" "${TIGGE_INPUT:-?}/${time}" "${TIGGE_OUTPUT:-?}/archive/${time}" "${TIGGE_OUTPUT:-?}/archive/tigge-kwbc-${time}.tar"; do
	if [[ -e $location ]]; then
		rm -r ${location}
	fi
done
