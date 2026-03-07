#!/bin/bash
set -e

BASE_DIR=$(pwd)
OSXCROSS_BIN="/osxcross/target/bin"
IOS_SDK="/osxcross/target/SDKs/iPhoneOS.sdk"
MIN_VERSION="4.3"
SRC_DIR="$BASE_DIR/src"
INTERMEDIATE_DIR="$BASE_DIR/intermediate/ios"
BUILD_DIR="$BASE_DIR/build/ios"

mkdir -p "$INTERMEDIATE_DIR" "$BUILD_DIR/lib" "$BUILD_DIR/include"

# Use the absolute path to the osxcross linker
LD_PATH="$OSXCROSS_BIN/x86_64-apple-darwin14-ld"

build_arch() {
    ARCH=$1
    echo "=== Building iOS Device: $ARCH ==="
    
    PREFIX="$INTERMEDIATE_DIR/$ARCH"
    mkdir -p "$PREFIX/lib" "$PREFIX/include"
    
    # Toolchain
    export CC="clang -fuse-ld=$LD_PATH"
    export CXX="clang++ -fuse-ld=$LD_PATH"
    export AR="$OSXCROSS_BIN/x86_64-apple-darwin14-ar"
    export RANLIB="$OSXCROSS_BIN/x86_64-apple-darwin14-ranlib"
    
    export COMMON_FLAGS="-target apple-ios$MIN_VERSION -arch $ARCH -isysroot $IOS_SDK -miphoneos-version-min=$MIN_VERSION"
    export CFLAGS="$COMMON_FLAGS -Os"
    export LDFLAGS="$COMMON_FLAGS"

    # 1. zlib
    echo "Building zlib..."
    cd "$SRC_DIR/zlib-1.2.13"
    make clean || true
    $CC $CFLAGS -c adler32.c crc32.c deflate.c infback.c inffast.c inflate.c inftrees.c trees.c zutil.c compress.c uncompr.c gzclose.c gzlib.c gzread.c gzwrite.c
    $AR rc libz.a adler32.o crc32.o deflate.o infback.o inffast.o inflate.o inftrees.o trees.o zutil.o compress.o uncompr.o gzclose.o gzlib.o gzread.o gzwrite.o
    $RANLIB libz.a
    cp libz.a "$PREFIX/lib/"
    cp zlib.h zconf.h "$PREFIX/include/"
    rm -f *.o libz.a
    
    # 2. OpenSSL
    echo "Building OpenSSL..."
    cd "$SRC_DIR/openssl-1.1.1w"
    make clean || true
    
    if [ "$ARCH" == "arm64" ]; then
        CONF_TARGET="ios64-cross"
    else
        CONF_TARGET="iphoneos-cross"
    fi
    
    # Set necessary env vars for OpenSSL cross-compile
    export CROSS_TOP="/osxcross/target/SDKs/iPhoneOS.sdk/../.."
    export CROSS_SDK="iPhoneOS.sdk"
    # We pass the full CC string to Configure via the CC env var
    # And we must use --prefix
    CC="$CC $CFLAGS" ./Configure $CONF_TARGET no-shared no-tests no-unit-test no-async no-engine --prefix="$PREFIX"
    
    # Fix Makefile to use our AR and avoid shared lib issues
    sed -i "s|^CROSS_COMPILE=.*|CROSS_COMPILE=|g" Makefile
    sed -i "s|^AR=.*|AR=$AR|g" Makefile
    sed -i "s|^RANLIB=.*|RANLIB=$RANLIB|g" Makefile
    sed -i "s|-ldl||g" Makefile
    
    make -j$(nproc) build_libs
    make install_dev
    
    # 3. curl
    echo "Building curl..."
    cd "$SRC_DIR/curl-7.88.1"
    make clean || true
    
    ./configure --host=arm-apple-darwin --with-ssl="$PREFIX" --with-zlib="$PREFIX" \
        --disable-shared --enable-static \
        --disable-ldap --disable-ldaps --disable-rtsp --disable-proxy \
        --prefix="$PREFIX" \
        CC="$CC -fuse-ld=$LD_PATH" CFLAGS="$CFLAGS" LDFLAGS="$LDFLAGS"
    
    make -j$(nproc) install
}

build_arch "armv7"
build_arch "armv7s"
build_arch "arm64"

# Combine into fat binaries
echo "=== Creating Fat Binaries for iOS Device ==="
LIPO="$OSXCROSS_BIN/lipo"
$LIPO -create "$INTERMEDIATE_DIR"/armv7/lib/libcurl.a "$INTERMEDIATE_DIR"/armv7s/lib/libcurl.a "$INTERMEDIATE_DIR"/arm64/lib/libcurl.a -output "$BUILD_DIR/lib/libcurl.a"
$LIPO -create "$INTERMEDIATE_DIR"/armv7/lib/libssl.a "$INTERMEDIATE_DIR"/armv7s/lib/libssl.a "$INTERMEDIATE_DIR"/arm64/lib/libssl.a -output "$BUILD_DIR/lib/libssl.a"
$LIPO -create "$INTERMEDIATE_DIR"/armv7/lib/libcrypto.a "$INTERMEDIATE_DIR"/armv7s/lib/libcrypto.a "$INTERMEDIATE_DIR"/arm64/lib/libcrypto.a -output "$BUILD_DIR/lib/libcrypto.a"
$LIPO -create "$INTERMEDIATE_DIR"/armv7/lib/libz.a "$INTERMEDIATE_DIR"/armv7s/lib/libz.a "$INTERMEDIATE_DIR"/arm64/lib/libz.a -output "$BUILD_DIR/lib/libz.a"

# Consolidate Headers
mkdir -p "$BASE_DIR/build/include"
cp -R "$INTERMEDIATE_DIR/arm64/include/curl" "$BASE_DIR/build/include/"
cp -R "$INTERMEDIATE_DIR/arm64/include/openssl" "$BASE_DIR/build/include/"
cp "$INTERMEDIATE_DIR/arm64/include/zlib.h" "$BASE_DIR/build/include/"
cp "$INTERMEDIATE_DIR/arm64/include/zconf.h" "$BASE_DIR/build/include/"

echo "iOS Device Build Complete!"
