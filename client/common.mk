# --- Centralized Toolchain & Paths ---
CC = clang
AR = ar
XCODE_PATH = /Applications/Xcode.app/Contents/Developer
NEKO_CC = /Developer/usr/bin/gcc-4.0
NEKO_AR = /Developer/usr/bin/ar

# SDKs
IOS_SDK = $(XCODE_PATH)/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS8.2.sdk
SIM_SDK = $(XCODE_PATH)/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator8.2.sdk
MAC_MODERN_SDK = $(XCODE_PATH)/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.10.sdk
MAC_NEKO_SDK = /Developer/SDKs/MacOSX10.4u.sdk

# --- Shared Flags ---
ARC_FLAGS = -fno-objc-arc
WARN_FLAGS = -Wall
# GCC 4.0 (Neko) doesn't support -Wno-error=deprecated-declarations
CLANG_WARN_FLAGS = $(WARN_FLAGS) -Wno-error=deprecated-declarations

COMMON_FW = -ObjC -framework Foundation -framework CoreData
IOS_FW = $(ARC_FLAGS) $(CLANG_WARN_FLAGS) $(COMMON_FW) -framework UIKit
MAC_FW = $(ARC_FLAGS) $(CLANG_WARN_FLAGS) $(COMMON_FW) -framework AppKit -framework Cocoa
TEST_FW = -framework XCTest

# NEKO Flags (No ARC support in GCC 4.0)
NEKO_FLAGS = $(WARN_FLAGS) $(COMMON_FW) -framework AppKit -framework Cocoa

# Architectures & Min Versions
IOS_MIN = 3.1
MAC_MODERN_MIN = 10.7
MAC_NEKO_MIN = 10.4

IOS_ARCHS = -arch armv7 -arch armv7s -arch arm64
SIM_ARCHS = -arch i386
MAC_MODERN_ARCHS = -arch x86_64 -arch i386
MAC_NEKO_ARCHS = -arch ppc -arch i386

# Standard CFLAGS (Using clang flags by default, but Makefiles can override for Neko)
CFLAGS = $(CLANG_WARN_FLAGS)
