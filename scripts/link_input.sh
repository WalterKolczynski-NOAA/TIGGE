#! /bin/sh

source $MODULESHOME/init/sh
module load python/3.6.3
module load prod_util/1.1.1

cd "$(dirname $(pwd))/scripts"
./link_input.py $1
