#! /usr/bin/env bash

set +x
if [[ -d /scratch1 ]]; then
	source /apps/lmod/8.5.2/init/sh > /dev/null 2&>1
	export MACHINE="hera"

elif [[ -d /lfs/h2 ]]; then
	export MACHINE="wcoss2"
fi
${TRACE_ON:-set -x}
