#!/bin/bash
set -e

# This script is intended to be run on the Mavericks VM
BASE_DIR=$(pwd)
XCODE_PATH="/Applications/Xcode.app/Contents/Developer"
SDK="$XCODE_PATH/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator8.2.sdk"
MIN_VERSION="4.3"
SRC_DIR="$BASE_DIR/src"
INTERMEDIATE_DIR="$BASE_DIR/intermediate/sim"
BUILD_DIR="$BASE_DIR/build/sim"

mkdir -p "$INTERMEDIATE_DIR" "$BUILD_DIR/lib"

build_arch() {
    ARCH=$1
    echo "=== Building iOS Simulator: $ARCH ==="
    
    PREFIX="$INTERMEDIATE_DIR/$ARCH"
    mkdir -p "$PREFIX/lib" "$PREFIX/include"
    
    # native tools
    export CC="clang"
    export CXX="clang++"
    export AR="ar"
    export RANLIB="ranlib"
    
    export COMMON_FLAGS="-arch $ARCH -isysroot $SDK -mios-simulator-version-min=$MIN_VERSION"
    export CFLAGS="$COMMON_FLAGS -Os"
    export LDFLAGS="$COMMON_FLAGS"

    # 1. zlib
    echo "Building zlib..."
    cd "$SRC_DIR/zlib-1.2.13"
    make clean || true
    # Compilation
    $CC $CFLAGS -c adler32.c crc32.c deflate.c infback.c inffast.c inflate.c inftrees.c trees.c zutil.c compress.c uncompr.c gzclose.c gzlib.c gzread.c gzwrite.c
    # Archive
    $AR rc libz.a adler32.o crc32.o deflate.o infback.o inffast.o inflate.o inftrees.o trees.o zutil.o compress.o uncompr.o gzclose.o gzlib.o gzread.o gzwrite.o
    $RANLIB libz.a
    cp libz.a "$PREFIX/lib/"
    cp zlib.h zconf.h "$PREFIX/include/"
    rm -f *.o libz.a
    
    # 2. OpenSSL
    echo "Building OpenSSL..."
    cd "$SRC_DIR/openssl-1.1.1w"
    make clean || true
    
    # On Mavericks Xcode 6.2, we use these targets
    if [ "$ARCH" == "x86_64" ]; then
        CONF_TARGET="darwin64-x86_64-cc"
    else
        CONF_TARGET="darwin-i386-cc"
    fi
    
    CC="$CC $CFLAGS" ./Configure $CONF_TARGET no-shared no-tests no-unit-test no-async no-engine --prefix="$PREFIX"
    
    sed -i "" "s|^CROSS_COMPILE=.*|CROSS_COMPILE=|g" Makefile
    sed -i "" "s|-ldl||g" Makefile
    
    make -j$(sysctl -n hw.ncpu) build_libs
    make install_dev
    
    # 3. curl
    echo "Building curl..."
    cd "$SRC_DIR/curl-7.88.1"
    make clean || true
    
    ./configure --host="$ARCH-apple-darwin" --with-ssl="$PREFIX" --with-zlib="$PREFIX" \
        --disable-shared --enable-static \
        --disable-ldap --disable-ldaps --disable-rtsp --disable-proxy --disable-manual \
        --prefix="$PREFIX" \
        CC="$CC" CFLAGS="$CFLAGS" LDFLAGS="$LDFLAGS"
    
    make -j$(sysctl -n hw.ncpu) install
}

build_arch "x86_64"
build_arch "i386"

# Combine into fat binaries (using native lipo)
echo "=== Creating Fat Binaries for Simulator ==="
lipo -create "$INTERMEDIATE_DIR"/x86_64/lib/libcurl.a "$INTERMEDIATE_DIR"/i386/lib/libcurl.a -output "$BUILD_DIR/lib/libcurl.a"
lipo -create "$INTERMEDIATE_DIR"/x86_64/lib/libssl.a "$INTERMEDIATE_DIR"/i386/lib/libssl.a -output "$BUILD_DIR/lib/libssl.a"
lipo -create "$INTERMEDIATE_DIR"/x86_64/lib/libcrypto.a "$INTERMEDIATE_DIR"/i386/lib/libcrypto.a -output "$BUILD_DIR/lib/libcrypto.a"
lipo -create "$INTERMEDIATE_DIR"/x86_64/lib/libz.a "$INTERMEDIATE_DIR"/i386/lib/libz.a -output "$BUILD_DIR/lib/libz.a"

echo "Simulator Build Complete!"
