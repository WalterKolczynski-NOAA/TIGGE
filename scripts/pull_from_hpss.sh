#! /bin/sh

set -x

source $MODULESHOME/init/sh
module load python/3.6.3
module load HPSS/5.0.2.5

cd "$(dirname $(pwd))/scripts"
./pull_from_hpss.py $1
