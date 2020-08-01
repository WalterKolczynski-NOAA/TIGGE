#! /usr/bin/sh

set -x

time=$1

export TIGGE_TOOLS=$(dirname $(pwd))
export TIGGE_INPUT="$TIGGE_TOOLS/input"
export TIGGE_OUTPUT="$TIGGE_TOOLS/output"
export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:$TIGGE_TOOLS/grib-api/lib"

source $MODULESHOME/init/sh
module use "$TIGGE_TOOLS/modulefiles"
module load tigge.wcoss_dell

cd "${TIGGE_TOOLS}/scripts"
./runTigge.pl $time