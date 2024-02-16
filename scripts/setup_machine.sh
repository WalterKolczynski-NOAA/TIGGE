#! /usr/bin/env bash

set +x
if [[ -d /scratch1 ]]; then
	if ( ! eval module help > /dev/null 2>&1 ); then
		source /apps/lmod/lmod/init/bash
	fi
	export LMOD_SYSTEM_DEFAULT_MODULES='contrib'
	module reset
	export MACHINE="hera"

elif [[ -d /lfs/h2 ]]; then
	module reset
	export MACHINE="wcoss2"
fi
${TRACE_ON:-set -x}
