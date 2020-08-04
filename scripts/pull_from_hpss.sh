#! /bin/sh

set -x

source $MODULESHOME/init/sh
module load python/3.6.3

cd "$(dirname $(pwd))/scripts"
./pull_from_hpss.py $1
