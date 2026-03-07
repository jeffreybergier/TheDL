# --- Environment Detection ---
HAS_OSXCROSS = $(shell [ -d /osxcross ] && echo 1 || echo 0)
# Get the absolute path to the directory containing common.mk (the client/ directory)
ROOT_DIR := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))

# --- Default Versions ---
IOS_MIN = 4.3
MAC_MIN = 10.6

# --- Toolchain & SDK Configuration ---
ifeq ($(HAS_OSXCROSS), 1)
  # Docker Cross-Compile Environment
  OSXCROSS_PATH = /osxcross/target
  XCODE_PATH = $(OSXCROSS_PATH)
  
  # SDKs
  IOS_SDK = $(OSXCROSS_PATH)/SDKs/iPhoneOS.sdk
  SIM_SDK = $(OSXCROSS_PATH)/SDKs/iPhoneSimulator.sdk
  MAC_SDK = $(OSXCROSS_PATH)/SDK/MacOSX10.10.sdk
  
  # Tools
  LD_PATH = $(OSXCROSS_PATH)/bin/x86_64-apple-darwin14-ld
  CC = clang -fuse-ld=$(LD_PATH)
  CXX = clang++ -fuse-ld=$(LD_PATH)
  AR = $(OSXCROSS_PATH)/bin/x86_64-apple-darwin14-ar
  AS = $(OSXCROSS_PATH)/bin/x86_64-apple-darwin14-as
  LIBTOOL = $(OSXCROSS_PATH)/bin/x86_64-apple-darwin14-libtool
  LIPO = $(OSXCROSS_PATH)/bin/lipo
  STRIP = $(OSXCROSS_PATH)/bin/x86_64-apple-darwin14-strip
  NM = $(OSXCROSS_PATH)/bin/x86_64-apple-darwin14-nm
  RANLIB = $(OSXCROSS_PATH)/bin/x86_64-apple-darwin14-ranlib
  
  # Architectures & Flags
  IOS_ARCHS = -target apple-ios$(IOS_MIN) -arch armv7 -arch armv7s -arch arm64
  SIM_ARCHS = -target i386-apple-ios8.0-simulator
  MAC_ARCHS = -target apple-macosx$(MAC_MIN) -arch x86_64 -arch i386
  SIM_FLAGS = -miphoneos-version-min=$(IOS_MIN)

  # Framework Paths for tests
  XCTEST_FRAMEWORK_DIR_MAC = $(MAC_SDK)/System/Library/Frameworks
  XCTEST_FRAMEWORK_DIR_SIM = $(SIM_SDK)/System/Library/Frameworks

else
  # Mavericks VM Environment
  XCODE_PATH = /Applications/Xcode.app/Contents/Developer
  
  # SDKs
  IOS_SDK = $(XCODE_PATH)/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS8.2.sdk
  SIM_SDK = $(XCODE_PATH)/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator8.2.sdk
  MAC_SDK = $(XCODE_PATH)/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.10.sdk
  
  # Tools
  CC = clang
  CXX = clang++
  AR = ar
  AS = as
  LIBTOOL = libtool
  LIPO = lipo
  STRIP = strip
  NM = nm
  RANLIB = ranlib

  # Architectures & Flags
  IOS_ARCHS = -arch armv7 -arch armv7s -arch arm64
  SIM_ARCHS = -arch i386
  MAC_ARCHS = -arch x86_64 -arch i386
  SIM_FLAGS = -mios-simulator-version-min=$(IOS_MIN)
  
  # Framework Paths for tests
  XCTEST_FRAMEWORK_DIR_MAC = $(XCODE_PATH)/Platforms/MacOSX.platform/Developer/Library/Frameworks
  XCTEST_FRAMEWORK_DIR_SIM = $(XCODE_PATH)/Platforms/iPhoneSimulator.platform/Developer/Library/Frameworks
endif

# --- Build Configuration ---
BUILD_CONFIG ?= debug
ROOT_BUILD_DIR = $(ROOT_DIR)/build
OUT_DIR = $(ROOT_BUILD_DIR)/$(BUILD_CONFIG)
LIB_OUT_DIR = $(OUT_DIR)/lib

ifeq ($(BUILD_CONFIG), release)
  CONFIG_FLAGS = -Os -DRELEASE
else
  CONFIG_FLAGS = -g -DDEBUG
endif

# --- Shared Flags ---

ARC_FLAGS = -fno-objc-arc
WARN_FLAGS = -Wall
CLANG_WARN_FLAGS = $(WARN_FLAGS) -Wno-error=deprecated-declarations -Wno-unused-command-line-argument

COMMON_FW = -ObjC -framework Foundation -framework CoreData
# Defaults: Enabled for iOS device, Disabled for Mac/Sim (due to linker/platform constraints)
IOS_FW = $(ARC_FLAGS) $(CLANG_WARN_FLAGS) $(COMMON_FW) -framework UIKit -framework MediaPlayer -framework AVFoundation -framework QuartzCore -DTHEDL_CURL_ENABLED=1
MAC_FW = $(ARC_FLAGS) $(CLANG_WARN_FLAGS) $(COMMON_FW) -framework AppKit -framework Cocoa -framework AVFoundation -framework QuartzCore -DTHEDL_CURL_ENABLED=0
SIM_FW = $(ARC_FLAGS) $(CLANG_WARN_FLAGS) $(COMMON_FW) -framework UIKit -framework MediaPlayer -framework AVFoundation -framework QuartzCore -DTHEDL_CURL_ENABLED=0
TEST_FW = -framework XCTest

# Standard CFLAGS
CFLAGS = $(CLANG_WARN_FLAGS)

# --- Library Paths (Pre-built) ---
CURL_DIR_IOS = $(ROOT_DIR)/lib/CURL/ios
