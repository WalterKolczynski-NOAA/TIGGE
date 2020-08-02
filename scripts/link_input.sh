#! /bin/sh

source $MODULESHOME/init/sh
module load python/3.6.3

cd "$(dirname $(pwd))/scripts"
./link_input.py $1
