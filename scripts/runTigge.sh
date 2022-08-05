#! /usr/bin/env bash

cd "$(dirname ${BASH_SOURCE[0]})"
source preamble.sh
source setup_machine.sh

time=${1}
module use ../modulefiles  > /dev/null 2>&1
module load run.${MACHINE} > /dev/null 2>&1

export TIGGE_TOOLS=${TIGGE_TOOLS:-$(cd ..; pwd -P)}
export TIGGE_INPUT=${TIGGE_INPUT}
export TIGGE_OUTPUT=${TIGGE_OUTPUT}
export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:$TIGGE_TOOLS/grib-api/lib"

./runTigge.pl $time
