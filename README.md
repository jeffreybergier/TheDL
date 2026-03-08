# TheDL: Retro Media Downloader

**TheDL** is a specialized media downloader and viewer designed for legacy Apple platforms. It targets **iPhoneOS 4.3+** and **Mac OS X 10.6+**, bringing modern capabilities like **TLS 1.2** and high-performance asynchronous networking to vintage hardware.

## 🚀 Key Features

- **Modern TLS Support**: Integrated custom-compiled `libcurl` 7.88.1 and `OpenSSL` 1.1.1w to allow legacy devices to connect to modern HTTPS/TLS 1.2 servers.
- **HFS+ Resource Fork Storage**: Uses native HFS+ "Named Forks" (`/..namedfork/rsrc`) to store download metadata (PLISTs) directly inside the downloaded files, unifying data and attributes into a single disk entry.
- **Cross-Platform Architecture**: Shared core logic across iOS and macOS via `BaseLibrary` and `CrossPlatform` modules.
- **Optimized Performance**: Utilizes bulk directory enumeration (`contentsOfDirectoryAtURL:...`) with pre-fetched resource keys for smooth scrolling on older CPUs.
- **Universal Binaries**: Compiles for `armv7`, `armv7s`, `arm64`, `i386`, and `x86_64`.

---

## 🛠 The Build System

The project uses a sophisticated **Dual-Environment Build System** managed entirely by Makefiles. It avoids Xcode project files to enable headless, high-speed automated builds.

### 1. Docker Development Environment
The project includes a pre-configured Docker environment with all cross-compilation tools and SDKs.

- **Launch Gemini Agent**:
  ```bash
  docker compose run --rm xcompile-gemini
  ```
- **Enter Headless Shell**:
  ```bash
  docker compose run --rm xcompile-shell
  ```
- **Full Release Build**:
  ```bash
  docker compose run --rm xcompile-shell make -C client release
  ```

### 2. Dual-Environment Setup
- **Docker (osxcross)**: Primary environment for cross-compiling iOS Device (`armv7/s/64`) and Mac (`i386/x86_64`) binaries using the iPhoneOS 8.2 and MacOSX 10.10 SDKs.
- **Mavericks VM**: Native OS X 10.9 environment used specifically for building the **iOS Simulator** (`i386`) target, ensuring compatibility with the legacy simulator linker.
- **Enhanced Tooling**: The Docker environment includes `rsync`, `ripgrep`, `jq`, `fd-find`, and `tree` for advanced debugging and codebase exploration.

### 2. Makefile Hierarchy
- **`client/common.mk`**: The brain of the build system. Detects the environment (`HAS_OSXCROSS`), manages paths, defines compiler flags (`-fno-objc-arc`, `-mmacosx-version-min=10.6`), and handles conditional compilation via `THEDL_CURL_ENABLED`.
- **`client/Makefile`**: Orchestrates the build across sub-libraries and applications.
- **Sub-module Makefiles**: Located in `lib/CrossPlatform`, `lib/BaseLibrary`, `phone`, and `mac`. They handle specific compilation and linking rules for each component.

### 3. Core Commands
Run these commands from the `client/` directory:

| Command | Description |
| :--- | :--- |
| `make debug` | Builds all targets with `-g -DDEBUG` and centralized symbols. |
| `make release` | Builds all targets with `-Os -DRELEASE` for production. |
| `make clean` | Wipes the `build/` directory and all intermediate `.o` and `.a` files. |
| `make sim` | (On Mavericks VM) Builds only the iOS Simulator library and app. |
| `make ios` | (In Docker) Builds only the iOS Device static libraries. |
| `make mac` | (In Docker) Builds only the macOS applications. |

---

## 📦 Deployment

### iOS Device (Jailbroken)
To install the IPA on a device (e.g., `ios-six`):
```bash
# 1. Sync the IPA
scp -F .ssh/config client/build/debug/TheDL.ipa ios-six:/tmp/

# 2. Install via ipainstaller
ssh -F .ssh/config ios-six "ipainstaller /tmp/TheDL.ipa"
```

### iOS Simulator
To run on the Mavericks VM:
```bash
# 1. Install
xcrun simctl install booted client/build/debug/TheDL-Sim.app

# 2. Launch
xcrun simctl launch booted com.kumasan.thedl.ios
```

---

## 🏛 Engineering Standards (Legacy Hardening)

To ensure stability on systems as old as Tiger (10.4) and iPhoneOS 3.1, the codebase adheres to strict legacy constraints:

- **Manual Reference Counting (MRC)**: No ARC. All memory is managed via `retain`, `release`, and `autorelease`.
- **Objective-C 1.0 Syntax**: 
    - No `@property` or `@synthesize`.
    - No Dot Syntax (`object.property`).
    - All method calls use square brackets `[object message]`.
- **NSEnumerator**: Uses `NSEnumerator` for collection iteration instead of "Fast Enumeration" (`for...in`) to support Objective-C 1.0 runtimes.
- **Cross-Platform Wrappers**: Uses the `XP_` category pattern (e.g., `XP_createDirectoryAtPath:...`) to bridge API differences between iOS 4 and iOS 8+ / macOS 10.6 and 10.10.

---

## 📁 Project Structure

- `client/lib/CURL`: Custom build scripts and artifacts for OpenSSL/CURL.
- `client/lib/CrossPlatform`: Low-level OS abstraction layer.
- `client/lib/BaseLibrary`: Core application logic, download services, and `TDLDownload` models.
- `client/phone`: iOS-specific UI (UITableViewControllers, Media Players).
- `client/mac`: macOS-specific UI and AppDelegate.
