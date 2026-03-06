# --- Centralized Toolchain & Paths ---
CC = clang
AR = ar
XCODE_PATH = /Applications/Xcode.app/Contents/Developer

# SDKs
IOS_SDK = $(XCODE_PATH)/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS8.2.sdk
SIM_SDK = $(XCODE_PATH)/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator8.2.sdk
MAC_SDK = $(XCODE_PATH)/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.10.sdk

# --- Shared Flags ---
ARC_FLAGS = -fno-objc-arc
WARN_FLAGS = -Wall
CLANG_WARN_FLAGS = $(WARN_FLAGS) -Wno-error=deprecated-declarations

COMMON_FW = -ObjC -framework Foundation -framework CoreData
IOS_FW = $(ARC_FLAGS) $(CLANG_WARN_FLAGS) $(COMMON_FW) -framework UIKit -framework MediaPlayer -framework AVFoundation -framework QuartzCore
MAC_FW = $(ARC_FLAGS) $(CLANG_WARN_FLAGS) $(COMMON_FW) -framework AppKit -framework Cocoa -framework AVFoundation -framework QuartzCore
TEST_FW = -framework XCTest

# Architectures & Min Versions
IOS_MIN = 3.1
MAC_MIN = 10.6

IOS_ARCHS = -arch armv7 -arch armv7s -arch arm64
SIM_ARCHS = -arch i386
MAC_ARCHS = -arch x86_64 -arch i386

# Standard CFLAGS
CFLAGS = $(CLANG_WARN_FLAGS)

# --- Library Paths (Pre-built) ---
CURL_DIR_IOS = $(shell pwd | sed 's/\/mac\|\/phone\|\/lib\/.*//')/lib/CURL/ios
# This is tricky because common.mk is included from different depths.
# Let's use a relative path trick or just pass it in.
# Actually, it's better to define it in each Makefile that needs it, or use a predictable path.
