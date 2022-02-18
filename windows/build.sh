#!/bin/bash

TARGET=x86_64-windows
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
cd contrib/minizip
autoreconf -f -i
./configure --host=$TARGET --with-sysroot=$SYSROOT --prefix=$PREFIX --enable-static=yes --enable-shared=no
make
make install
cd ../..

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

echo "xxxbuild pcre"
cd ../pcre-8.45
./configure --host=$TARGET --with-sysroot=$SYSROOT --prefix=$PREFIX --enable-static=yes --enable-shared=no
make
make install

echo "xxxbuild sqlite3-pcre"
cd ../sqlite3-pcre
CFLAGS="$CFLAGS -I$SYSROOT/include -DPCRE_STATIC" make
mv libsqlite3-pcre.a $SYSROOT/lib
cp sqlite3-pcre.h $SYSROOT/include

echo "xxxbuild proj"
cd ../proj-6.3.2
autoreconf -f -i
CPPFLAGS="$CPPFLAGS -I$SYSROOT/include" LDFLAGS="$LDFLAGS -L$SYSROOT/lib" ./configure --host=$TARGET --with-sysroot=$SYSROOT --prefix=$PREFIX --enable-static=yes --enable-shared=no
make -j6
make install

echo "xxxbuild geos"
cd ../geos-3.9.2
./configure --host=$TARGET --with-sysroot=$SYSROOT --prefix=$PREFIX --enable-static=yes --enable-shared=no
make -j6
make install

echo "xxxbuild rttopo"
cd ../librttopo-librttopo-1.1.0/librttopo
./autogen.sh
CPPFLAGS="$CPPFLAGS -I$SYSROOT/include" LDFLAGS="$LDFLAGS -L$SYSROOT/lib" ./configure --host=$TARGET --prefix=$PREFIX --enable-static=yes --enable-shared=no --with-geosconfig=$SYSROOT/bin/geos-config
make
make install
cd ..

echo "xxxbuild spatialite"
cd ../libspatialite-5.0.1
autoreconf -f -i
CFLAGS="$CFLAGS -ULOADABLE_EXTENSION -DPROJ_NEW" CPPFLAGS="$CPPFLAGS -I$SYSROOT/include" LDFLAGS="$LDFLAGS -L$SYSROOT/lib" ./configure --host=$TARGET --prefix=$PREFIX --enable-static=yes --enable-shared=no --enable-freexl=no --enable-libxml2=no --enable-examples=no --with-geosconfig=$SYSROOT/bin/geos-config
make -j6
make install

echo "xxxbuild 3rd.dll"
cd $SYSROOT
cmake \
    -DCMAKE_TOOLCHAIN_FILE=./mingw-w64-x86_64.cmake \
    -DCMAKE_C_FLAGS=-DGIT_VERSION=`git describe --tags --always --long --dirty=-dev` \
    -DCMAKE_CXX_FLAGS=-DGIT_VERSION=`git describe --tags --always --long --dirty=-dev` \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_SHARED_LINKER_FLAGS_RELEASE=-s \
    -DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
    -DCMAKE_FIND_ROOT_PATH_MODE_LIBRARY=./build/x86_64/lib \
    ../..
make -C .
