#!/bin/bash
set -e

BASE_DIR=$(pwd)
OSXCROSS_BIN="/osxcross/target/bin"
MAC_SDK="/osxcross/target/SDK/MacOSX10.10.sdk"
MIN_VERSION="10.6"
SRC_DIR="$BASE_DIR/src"
INTERMEDIATE_DIR="$BASE_DIR/intermediate/mac"
BUILD_DIR="$BASE_DIR/build/mac"

mkdir -p "$INTERMEDIATE_DIR" "$BUILD_DIR/lib"

# Use the absolute path to the osxcross linker
LD_PATH="$OSXCROSS_BIN/x86_64-apple-darwin14-ld"

build_arch() {
    ARCH=$1
    echo "=== Building Mac: $ARCH ==="
    
    PREFIX="$INTERMEDIATE_DIR/$ARCH"
    mkdir -p "$PREFIX/lib" "$PREFIX/include"
    
    # Toolchain
    export CC="clang -fuse-ld=$LD_PATH"
    export CXX="clang++ -fuse-ld=$LD_PATH"
    export AR="$OSXCROSS_BIN/x86_64-apple-darwin14-ar"
    export RANLIB="$OSXCROSS_BIN/x86_64-apple-darwin14-ranlib"
    
    export COMMON_FLAGS="-target apple-macosx$MIN_VERSION -arch $ARCH -isysroot $MAC_SDK -mmacosx-version-min=$MIN_VERSION"
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
    
    if [ "$ARCH" == "x86_64" ]; then
        CONF_TARGET="darwin64-x86_64-cc"
    else
        CONF_TARGET="darwin-i386-cc"
    fi
    
    # Pass CC and flags
    CC="$CC $CFLAGS" ./Configure $CONF_TARGET no-shared no-tests no-unit-test no-async no-engine --prefix="$PREFIX"
    
    sed -i "s|^CROSS_COMPILE=.*|CROSS_COMPILE=|g" Makefile
    sed -i "s|^AR=.*|AR=$AR|g" Makefile
    sed -i "s|^RANLIB=.*|RANLIB=$RANLIB|g" Makefile
    
    make -j$(nproc) build_libs
    make install_dev
    
    # 3. curl
    echo "Building curl..."
    cd "$SRC_DIR/curl-7.88.1"
    make clean || true
    
    ./configure --host=x86_64-apple-darwin --with-ssl="$PREFIX" --with-zlib="$PREFIX" \
        --disable-shared --enable-static \
        --disable-ldap --disable-ldaps --disable-rtsp --disable-proxy \
        --prefix="$PREFIX" \
        CC="$CC" CFLAGS="$CFLAGS" LDFLAGS="$LDFLAGS"
    
    make -j$(nproc) install
}

build_arch "x86_64"
build_arch "i386"

# Combine into fat binaries
echo "=== Creating Fat Binaries for Mac ==="
LIPO="$OSXCROSS_BIN/lipo"
$LIPO -create "$INTERMEDIATE_DIR"/x86_64/lib/libcurl.a "$INTERMEDIATE_DIR"/i386/lib/libcurl.a -output "$BUILD_DIR/lib/libcurl.a"
$LIPO -create "$INTERMEDIATE_DIR"/x86_64/lib/libssl.a "$INTERMEDIATE_DIR"/i386/lib/libssl.a -output "$BUILD_DIR/lib/libssl.a"
$LIPO -create "$INTERMEDIATE_DIR"/x86_64/lib/libcrypto.a "$INTERMEDIATE_DIR"/i386/lib/libcrypto.a -output "$BUILD_DIR/lib/libcrypto.a"
$LIPO -create "$INTERMEDIATE_DIR"/x86_64/lib/libz.a "$INTERMEDIATE_DIR"/i386/lib/libz.a -output "$BUILD_DIR/lib/libz.a"

echo "Mac Build Complete!"
