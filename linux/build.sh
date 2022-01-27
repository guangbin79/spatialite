#!/bin/bash

PREFIX=$PWD/build
SYSROOT=$PWD/build

export CFLAGS+="-fPIC"
export CPPFLAGS+="-fPIC"

echo "xxxbuild zlib"
cd ../zlib-1.2.11
./configure --static --prefix=$PREFIX
make
make install

echo "xxxbuild iconv"
cd ../libiconv-1.16
./configure --with-sysroot=$SYSROOT --prefix=$PREFIX --enable-static=yes --enable-shared=no
make
make install

echo "xxxbuild sqlite"
cd ../sqlite-autoconf-3370200
autoreconf -f -i
CFLAGS="$CFLAGS -DSQLITE_CORE" ./configure --with-sysroot=$SYSROOT  --prefix=$PREFIX --enable-static=yes --enable-shared=no
make
make install

echo "xxxbuild proj"
cd ../proj-4.9.3
autoreconf -f -i
./configure --with-sysroot=$SYSROOT --prefix=$PREFIX --enable-static=yes --enable-shared=no
make
make install

echo "xxxbuild geos"
cd ../geos-3.9.2
./configure --with-sysroot=$SYSROOT --prefix=$PREFIX --enable-static=yes --enable-shared=no
make -j6
make install

echo "xxxbuild spatialite"
cd ../libspatialite-4.3.0
CFLAGS="$CFLAGS -ULOADABLE_EXTENSION" PKG_CONFIG_PATH="$SYSROOT/lib/pkgconfig" CPPFLAGS="$CPPFLAGS -I$SYSROOT/include" LDFLAGS="$LDFLAGS -L$SYSROOT/lib -lsqlite3 -lproj -lgeos_c -lgeos" ./configure --prefix=$PREFIX --enable-static=yes --enable-shared=no --enable-freexl=no --enable-libxml2=no  --enable-gcp=yes --enable-examples=no --with-geosconfig=$SYSROOT/bin/geos-config
make -j6
make install
