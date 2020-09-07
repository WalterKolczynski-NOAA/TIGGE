#!/bin/sh

cd ..
module use modulefiles
module load tigge.wcoss_dell

cd grib-api
./configure --with-jasper="$JASPER_LIBDIR/.." --with-openjpeg="$PNG_LIBDIR" --prefix=$(pwd)
make
make install
make clean

cd ../src
make
make install