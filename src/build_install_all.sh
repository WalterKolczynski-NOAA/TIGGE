#!/bin/sh

cd ..
module purge
module use modulefiles
module load tigge.wcoss_dell

cd grib-api
./configure --with-jasper="$JASPER_LIBDIR/.." --with-openjpeg="$PNG_LIBDIR" --prefix=$(pwd)
make clean
make
make install

cd ../src
rm ../bin/ncdcTigge
make clean
make
make install