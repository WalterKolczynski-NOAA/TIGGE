#! /usr/bin/env bash

cd $(dirname ${BASH_SOURCE[0]})

source ../scripts/preamble.sh
source ../scripts/setup_machine.sh
module use ../modulefiles          > /dev/null 2>&1
module load rocoto.${MACHINE}      > /dev/null 2>&1

rocotorun -d hpss.db -w hpss_workflow.xml

date
