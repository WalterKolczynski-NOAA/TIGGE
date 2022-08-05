#!/bin/bash

source ../scripts/setup_machine.sh

cd ..
module purge
module use modulefiles
module load build.${MACHINE}

cd grib-api
./configure --with-jasper="$JASPER_LIBRARIES/.." --with-openjpeg="$PNG_LIBBRARIES" --prefix=$(pwd)
make clean
make
make install

cd ../src
rm ../bin/ncdcTigge
make clean
make
make install
