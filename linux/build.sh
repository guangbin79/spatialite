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
