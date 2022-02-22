#!/bin/bash

TARGET=x86_64-windows
PREFIX=$PWD/build/x86_64

export AR=x86_64-w64-mingw32-gcc-ar
export CC=x86_64-w64-mingw32-gcc
export AS=$CC
export CXX=x86_64-w64-mingw32-g++
export LD=x86_64-w64-mingw32-ld
export RANLIB=x86_64-w64-mingw32-ranlib
export STRIP=x86_64-w64-mingw32-strip

export CFLAGS="-fPIC -O2 -I$PREFIX/include"
export CPPFLAGS="-fPIC -O2 -I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"

echo "xxxbuild zlib"
cd ../zlib-1.2.11
./configure --static --prefix=$PREFIX
make
make install
cd contrib/minizip
autoreconf -f -i
./configure --host=$TARGET --prefix=$PREFIX --enable-static=yes --enable-shared=no
make
make install
cd ../..

echo "xxxbuild iconv"
cd ../libiconv-1.16
./configure --host=$TARGET --prefix=$PREFIX --enable-static=yes --enable-shared=no
make
make install

echo "xxxbuild sqlite"
cd ../sqlite-autoconf-3370200
autoreconf -f -i
CFLAGS+=" -DSQLITE_CORE -DSQLITE_THREADSAFE=2" ./configure --host=$TARGET  --prefix=$PREFIX --enable-static=yes --enable-shared=no --enable-threadsafe=no
make
make install

echo "xxxbuild pcre"
cd ../pcre-8.45
./configure --host=$TARGET --prefix=$PREFIX --enable-static=yes --enable-shared=no
make
make install

echo "xxxbuild sqlite3-pcre"
cd ../sqlite3-pcre
CFLAGS+=" -DPCRE_STATIC" make
mv libsqlite3-pcre.a $PREFIX/lib
cp sqlite3-pcre.h $PREFIX/include

echo "xxxbuild proj"
cd ../proj-6.3.2
autoreconf -f -i
SQLITE3_LIBS=$PREFIX/lib LIBS+=" -lsqlite3" ./configure --host=$TARGET --prefix=$PREFIX --enable-static=yes --enable-shared=no
make -j6
make install

echo "xxxbuild geos"
cd ../geos-3.9.2
./configure --host=$TARGET --prefix=$PREFIX --enable-static=yes --enable-shared=no
make -j6
make install

echo "xxxbuild rttopo"
cd ../librttopo-librttopo-1.1.0/librttopo
./autogen.sh
./configure --host=$TARGET --prefix=$PREFIX --enable-static=yes --enable-shared=no --with-geosconfig=$PREFIX/bin/geos-config
make
make install
cd ..

echo "xxxbuild spatialite"
cd ../libspatialite-5.0.1
autoreconf -f -i
CFLAGS+=" -ULOADABLE_EXTENSION -DPROJ_NEW" ./configure --host=$TARGET --prefix=$PREFIX --enable-static=yes --enable-shared=no --enable-freexl=no --enable-libxml2=no --enable-examples=no --with-geosconfig=$PREFIX/bin/geos-config
make -j6
make install
