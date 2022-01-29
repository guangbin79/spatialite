#!/bin/bash

TARGET=x86_64-windows
ARCH=windows-x86_64
PREFIX=$PWD/build/x86_64
SYSROOT=$PWD/build/x86_64

export AR=x86_64-w64-mingw32-gcc-ar
export CC=x86_64-w64-mingw32-gcc
export AS=$CC
export CXX=x86_64-w64-mingw32-g++
export LD=x86_64-w64-mingw32-ld
export RANLIB=x86_64-w64-mingw32-ranlib
export STRIP=x86_64-w64-mingw32-strip
export CFLAGS+="-fPIC"
export CPPFLAGS+="-fPIC"

echo "xxxbuild zlib"
cd ../zlib-1.2.11
./configure --static --prefix=$PREFIX
make
make install

echo "xxxbuild iconv"
cd ../libiconv-1.16
./configure --host=$TARGET --with-sysroot=$SYSROOT --prefix=$PREFIX --enable-static=yes --enable-shared=no
make
make install

echo "xxxbuild sqlite"
cd ../sqlite-autoconf-3370200
autoreconf -f -i
CFLAGS="$CFLAGS -DSQLITE_CORE" ./configure --host=$TARGET --with-sysroot=$SYSROOT  --prefix=$PREFIX --enable-static=yes --enable-shared=no
make
make install

echo "xxxbuild proj"
cd ../proj-4.9.3
autoreconf -f -i
./configure --host=$TARGET --with-sysroot=$SYSROOT --prefix=$PREFIX --enable-static=yes --enable-shared=no
make
make install

echo "xxxbuild geos"
cd ../geos-3.9.2
./configure --host=$TARGET --with-sysroot=$SYSROOT --prefix=$PREFIX --enable-static=yes --enable-shared=no
make -j6
make install

echo "xxxbuild spatialite"
cd ../libspatialite-4.3.0
CFLAGS="$CFLAGS -ULOADABLE_EXTENSION" PKG_CONFIG_PATH="$SYSROOT/lib/pkgconfig" CPPFLAGS="$CPPFLAGS -I$SYSROOT/include" LDFLAGS="$LDFLAGS -L$SYSROOT/lib -lsqlite3 -lproj -lgeos_c -lgeos" ./configure --host=arm-linux-eabi --prefix=$PREFIX --enable-static=yes --enable-shared=no --enable-freexl=no --enable-libxml2=no  --enable-gcp=yes --enable-examples=no --with-geosconfig=$SYSROOT/bin/geos-config
make -j6
make install

echo "xxxbuild 3rd.dll"
cd $SYSROOT
cmake \
    -DCMAKE_TOOLCHAIN_FILE=./mingw-w64-x86_64.cmake \
    -DCMAKE_C_FLAGS=-DGIT_VERSION=`git describe --tags --always --long --dirty=-dev` \
    -DCMAKE_CXX_FLAGS=-DGIT_VERSION=`git describe --tags --always --long --dirty=-dev` -Wl,--out-implib,3rd.lib \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_SHARED_LINKER_FLAGS_RELEASE=-s \
    -DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
    -DCMAKE_FIND_ROOT_PATH_MODE_LIBRARY=./build/x86_64/lib \
    ../..
make -C .
