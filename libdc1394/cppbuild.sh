#!/bin/bash
# This file is meant to be included by the parent cppbuild.sh script
if [[ -z "$PLATFORM" ]]; then
    pushd ..
    bash cppbuild.sh "$@" libdc1394
    popd
    exit
fi

LIBDC1394_VERSION=2.2.5
download http://downloads.sourceforge.net/project/libdc1394/libdc1394-2/$LIBDC1394_VERSION/libdc1394-$LIBDC1394_VERSION.tar.gz libdc1394-$LIBDC1394_VERSION.tar.gz

mkdir -p $PLATFORM
cd $PLATFORM
INSTALL_PATH=`pwd`
echo "Decompressing archives..."
tar --totals -xzf ../libdc1394-$LIBDC1394_VERSION.tar.gz
cd libdc1394-$LIBDC1394_VERSION

case $PLATFORM in
    linux-x86)
        CC="$OLDCC -m32" ./configure --prefix=$INSTALL_PATH --disable-sdltest
        make -j4
        make install-strip
        ;;
    linux-x86_64)
        CC="$OLDCC -m64" ./configure --prefix=$INSTALL_PATH --disable-sdltest
        make -j4
        make install-strip
        ;;
    linux-armhf)
        CC=arm-linux-gnueabihf-gcc CXX=arm-linux-gnueabihf-g++ ./configure --prefix=$INSTALL_PATH --host=arm-linux-gnueabihf --disable-sdltest
        make -j4
        make install-strip
        ;;
    linux-ppc64le)
        MACHINE_TYPE=$( uname -m )
        sed -i s/elf64ppc/elf64lppc/ configure
        if [[ "$MACHINE_TYPE" =~ ppc64 ]]; then
          CC="$OLDCC -m64" ./configure --prefix=$INSTALL_PATH --disable-sdltest
        else
          CC="powerpc64le-linux-gnu-gcc -m64" ./configure --host=powerpc64le-linux-gnu --build=ppc64le-linux --prefix=$INSTALL_PATH --disable-sdltest
        fi
        make -j4
        make install-strip
        ;;
    macosx-*)
        patch -Np1 < ../../../libdc1394-$LIBDC1394_VERSION-macosx.patch
        LIBUSB_CFLAGS=-I/usr/local/include/libusb-1.0/ LIBUSB_LIBS="-L/usr/local/lib/ -lusb-1.0" ./configure --prefix=$INSTALL_PATH --disable-sdltest
        make -j4
        make install-strip
        ;;
    windows-x86)
        export C_INCLUDE_PATH="/c/Program Files (x86)/CMU/1394Camera/include/"
        mkdir -p "$INSTALL_PATH/bin"
        cp "/c/Program Files (x86)/CMU/1394Camera/lib/1394camera.dll" "$INSTALL_PATH/bin/lib1394camera.dll"
        export LIBRARY_PATH="$INSTALL_PATH/bin/"
        CC="gcc -m32 -Duint=int -static-libgcc" ./configure --prefix=$INSTALL_PATH --enable-shared --disable-static --disable-sdltest
        make -j4
        make install-strip
        ;;
    windows-x86_64)
        export C_INCLUDE_PATH="/c/Program Files (x86)/CMU/1394Camera/include/"
        mkdir -p "$INSTALL_PATH/bin"
        cp "/c/Program Files (x86)/CMU/1394Camera/lib64/x64/1394camera.dll" "$INSTALL_PATH/bin/lib1394camera.dll"
        export LIBRARY_PATH="$INSTALL_PATH/bin/"
        CC="gcc -m64 -Duint=int -static-libgcc" ./configure --prefix=$INSTALL_PATH --enable-shared --disable-static --disable-sdltest
        make -j4
        make install-strip
        ;;
    *)
        echo "Error: Platform \"$PLATFORM\" is not supported"
        ;;
esac

cd ../..
