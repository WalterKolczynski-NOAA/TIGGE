#!/bin/sh --login
set -x

source $MODULESHOME/init/sh                       2>/dev/null
module load lsf/10.1                              2>/dev/null
module use /usrx/local/dev/emc_rocoto/modulefiles 2>/dev/null
module load ruby/2.5.1 rocoto/complete            2>/dev/null

cd $(dirname ${BASH_SOURCE[0]})

rocotorun -d tigge_from_hpss.db -w tigge_from_hpss.xml

date
