# Pre-built CURL Stack for TheDL

This directory contains the source-based build system for `libcurl` (7.88.1), `OpenSSL` (1.1.1w), and `zlib` (1.2.13) targeting legacy iOS and macOS platforms.

## Architectural Rules

To ensure stability and performance, the following rules apply:

1. **Pre-build Requirement**: These libraries are **NOT** built as part of the standard application `Makefile`. They are heavy dependencies that take significant time to compile. They must be pre-built once and the artifacts stored in the `build/` directory.
2. **Environment Separation**:
   - **iOS Device & macOS**: Must be built in the **Docker Cross-Compile Environment** using the provided `osxcross` toolchain.
   - **iOS Simulator**: Must be built on **Native Apple Hardware** (e.g., Mavericks VM with Xcode 6.2). This is required to bypass circular re-export bugs in the legacy `iPhoneSimulator.sdk` that cause symbol collisions in cross-linkers.
3. **Artifact Persistence**: Final fat binaries are stored in `build/<platform>/lib/` and headers in `build/include/`. The `src/` and `intermediate/` directories should be cleaned up after successful builds.

## Build Instructions

### 1. iOS Device (armv7, armv7s, arm64)
Run this inside the **Docker** container:
```bash
cd client/lib/CURL
./build_ios.sh
```

### 2. macOS (x86_64, i386)
Run this inside the **Docker** container:
```bash
cd client/lib/CURL
./build_mac.sh
```

### 3. iOS Simulator (x86_64, i386)
Run this inside the **Mavericks VM**:
```bash
cd client/lib/CURL
./build_sim.sh
```

## Troubleshooting

- **Linker Assertion Failures**: If you encounter `ld: Assertion failed: (name != NULL)` on Mavericks, ensure you are using the native `clang` and that the static libraries were built with compatible flags.
- **Header Missing**: All headers are consolidated into `build/include`. Ensure the main app Makefiles use `-I$(CURL_BASE_DIR)/include`.
- **CURL Features**: The current configuration disables LDAP, RTSP, and Proxy support to keep the legacy footprint small and stable.
