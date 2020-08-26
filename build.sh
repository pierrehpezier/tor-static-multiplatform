#!/bin/bash -xe
#TOR_VERSION=tor-0.3.5.7
TOR_VERSION=tor-0.4.3.6
ARM_EABI=arm-linux-gnueabihf
OPENSSL_VERSION=openssl-1.0.2p
LIBEVENT_VERSION=libevent-2.1.12-stable
ZLIB_VERSION=zlib-1.2.11

wget --no-check-certificate https://dist.torproject.org/${TOR_VERSION}.tar.gz
wget --no-check-certificate https://ftp.openssl.org/source/old/1.0.2/${OPENSSL_VERSION}.tar.gz

tar xzf ${OPENSSL_VERSION}.tar.gz
tar xzf ${TOR_VERSION}.tar.gz
tar xzf ${LIBEVENT_VERSION}.tar.gz
tar xzf ${ZLIB_VERSION}.tar.gz

cd ${OPENSSL_VERSION}

chmod +x Configure
CC=x86_64-w64-mingw32-gcc ./Configure  mingw64 --prefix=$(pwd)/../openssl_win64 no-asm no-shared
make install clean
rm -f ../openssl_win64/lib/libcrypto.dll.a ../openssl_win64/lib/libssl.dll.a
CC=i686-w64-mingw32-gcc ./Configure  mingw --prefix=$(pwd)/../openssl_win32 no-asm no-shared
make install clean
rm -f ../openssl_win32/lib/libcrypto.dll.a ../openssl_win32/lib/libssl.dll.a
CC=${ARM_EABI}-gcc ./Configure linux-armv4 --prefix=$(pwd)/../openssl_raspberry no-asm no-shared
make install clean
./Configure linux-generic64 --prefix=$(pwd)/../openssl_linux64 no-asm no-shared
make install clean
cd ..

cd ${LIBEVENT_VERSION}
CPPFLAGS=-I$(pwd)/../openssl_win64/include/ CFLAGS=-I$(pwd)/../openssl_win64/include/ LDFLAGS=-L$(pwd)/../openssl_win64/lib/ ./configure --disable-openssl --enable-static --host=x86_64-w64-mingw32 --prefix=$(pwd)/../libevent_win64 --disable-samples --disable-debug-mode
make install clean
CPPFLAGS=-I$(pwd)/../openssl_win32/include/ CFLAGS=-I$(pwd)/../openssl_win32/include/ LDFLAGS=-L$(pwd)/../openssl_win32/lib/ ./configure --disable-openssl --enable-static --host=i686-w64-mingw32 --prefix=$(pwd)/../libevent_win32 --disable-samples --disable-debug-mode
make install clean
CPPFLAGS=-I$(pwd)/../openssl_raspberry/include/ CFLAGS=-I$(pwd)/../openssl_raspberry/include/ LDFLAGS=-L$(pwd)/../openssl_raspberry/lib/ ./configure --disable-openssl --disable-shared --enable-static --host=${ARM_EABI} --prefix=$(pwd)/../libevent_raspberry
make install clean
CPPFLAGS=-I$(pwd)/../openssl_linux64/include/ CFLAGS=-I$(pwd)/../openssl_linux64/include/ LDFLAGS=-L$(pwd)/../openssl_linux64/lib/ ./configure --disable-openssl --disable-shared --enable-static --prefix=$(pwd)/../libevent_linux64
make install clean
cd ..

cd ${ZLIB_VERSION}
CC=x86_64-w64-mingw32-gcc ./configure --const --static --64 --prefix=$(pwd)/../zlib_win64
make install clean
CC=i686-w64-mingw32-gcc ./configure --const --static --prefix=$(pwd)/../zlib_win32
make install clean
CC=${ARM_EABI}-gcc ./configure --const --static --prefix=$(pwd)/../zlib_raspberry
make install clean
./configure --const --static --64 --prefix=$(pwd)/../zlib_linux64
make install clean
cd ..

cd ${TOR_VERSION}

sed -i 's/TOR_LIB_WS32=-lws2_32/TOR_LIB_WS32="-lws2_32 -lcrypt32 -liphlpapi"/g' configure
LDFLAGS="-L$(pwd)/../libevent_win64/lib" LIBS="-lcrypt32" ./configure --host=x86_64-w64-mingw32 --prefix=$(pwd)/../tor_win64 --enable-static-libevent --enable-static-zlib --with-openssl-dir=$(pwd)/../openssl_win64 --with-zlib-dir=$(pwd)/../zlib_win64 --disable-lzma   --libdir=$(pwd)/../build/tor_win64/lib --with-libevent-dir=$(pwd)/../libevent_win64 --disable-asciidoc --enable-static-openssl  --enable-static-tor --enable-static-zlib
make install clean
LDFLAGS="-L$(pwd)/../libevent_win32/lib" LIBS="-lcrypt32" ./configure --host=i686-w64-mingw32 --prefix=$(pwd)/../tor_win32 --enable-static-libevent --enable-static-zlib --with-openssl-dir=$(pwd)/../openssl_win32 --with-zlib-dir=$(pwd)/../zlib_win32 --disable-lzma   --libdir=$(pwd)/../build/tor_win32/lib --with-libevent-dir=$(pwd)/../libevent_win32 --disable-asciidoc --enable-static-openssl  --enable-static-tor --enable-static-zlib
make install clean
sed -i  's/lssl -lcrypto \$TOR_LIB_GDI \$TOR_LIB_WS32/lssl -lcrypto \$TOR_LIB_GDI \$TOR_LIB_WS32 -ldl/g' configure
LDFAGS="-L$(pwd)/../libevent_raspberry/lib" CFLAGS="-L$(pwd)/../libevent_raspberry/lib -L$(pwd)/../openssl_raspberry/lib -I$(pwd)/../libevent_raspberry/include" ./configure --host=${ARM_EABI} --prefix=$(pwd)/../tor_raspberry --enable-static-tor --with-libevent-dir=$(pwd)/../libevent_raspberry --enable-static-openssl --enable-static-libevent --enable-static-zlib --with-openssl-dir=$(pwd)/../openssl_raspberry --with-zlib-dir=$(pwd)/../zlib_raspberry --disable-lzma --libdir=$(pwd)/../build/tor_raspberry/lib  --disable-asciidoc --enable-static-openssl  --enable-static-tor --enable-static-zlib
make install clean
./configure --prefix=$(pwd)/../tor_linux64 --enable-static-tor --with-libevent-dir=$(pwd)/../libevent_linux64 --enable-static-openssl --enable-static-libevent --enable-static-zlib --with-openssl-dir=$(pwd)/../openssl_linux64 --with-zlib-dir=$(pwd)/../zlib_linux64 --disable-lzma --libdir=$(pwd)/../build/tor_linux64/lib
make install clean
cd ..

strip -s tor_win64/bin/tor.exe
strip -s tor_win32/bin/tor.exe
${ARM_EABI}-strip -s tor_raspberry/bin/tor
strip -s tor_linux64/bin/tor

upx -9 tor_win64/bin/tor.exe
upx -9 tor_win32/bin/tor.exe
upx -9 tor_raspberry/bin/tor
upx -9 tor_linux64/bin/tor

mkdir -p build

cp tor_win64/bin/tor.exe build/tor_win64.exe
cp tor_win32/bin/tor.exe build/tor_win32.exe
cp tor_raspberry/bin/tor build/tor_raspberry.elf
cp tor_linux64/bin/tor build/tor_linux64.elf

