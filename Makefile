# --- Toolchain & Paths ---
CC = clang
XCODE_PATH = /Applications/Xcode.app/Contents/Developer
NEKO_CC = /Developer/usr/bin/gcc-4.0

# SDKs
IOS_SDK = $(XCODE_PATH)/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS8.2.sdk
SIM_SDK = $(XCODE_PATH)/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator8.2.sdk
MAC_MODERN_SDK = $(XCODE_PATH)/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.10.sdk
MAC_NEKO_SDK = /Developer/SDKs/MacOSX10.4u.sdk

# --- Memory Management ---
# Clang supports ARC, GCC 4.0 doesn't.
# Using manual retain/release as requested in GEMINI.md
ARC_FLAGS = -fno-objc-arc

# --- Warning Flags ---
CFLAGS = -Wall -Werror

# --- Architecture & SDK Flags ---
COMMON_FW = -framework Foundation -framework CoreData
IOS_FW = $(ARC_FLAGS) $(COMMON_FW) -framework UIKit
MAC_FW = $(COMMON_FW) -framework AppKit -framework Cocoa

# iOS: armv7, armv7s, arm64 (Min 3.1)
IOS_ARCHS = -arch armv7 -arch armv7s -arch arm64
IOS_FLAGS = $(IOS_ARCHS) -isysroot $(IOS_SDK) -miphoneos-version-min=3.1

# iOS Simulator: i386 (Min 3.1)
SIM_ARCHS = -arch i386
SIM_FLAGS = $(SIM_ARCHS) -isysroot $(SIM_SDK) -mios-simulator-version-min=3.1 -Wl,-no_pie

# macOS Modern: x86_64, i386 (Min 10.7)
MAC_MODERN_ARCHS = -arch x86_64 -arch i386
MAC_MODERN_FLAGS = $(MAC_MODERN_ARCHS) -isysroot $(MAC_MODERN_SDK) -mmacosx-version-min=10.7 $(ARC_FLAGS)

# macOS Neko: ppc, i386 (Min 10.4)
MAC_NEKO_ARCHS = -arch ppc -arch i386
MAC_NEKO_FLAGS = $(MAC_NEKO_ARCHS) -isysroot $(MAC_NEKO_SDK) -mmacosx-version-min=10.4

# --- Build Targets ---
all: ios_bundle mac_bundle neko_bundle

# 1. macOS Modern Bundle (.app)
mac_bundle: 
	@echo "Building macOS Modern Bundle (10.10)..."
	$(CC) $(MAC_MODERN_FLAGS) $(CFLAGS) $(MAC_FW) mac_main.m GTMAppDelegate.m -o hello_mac
	mkdir -p "TheDL_Mac.app/Contents/MacOS"
	mkdir -p "TheDL_Mac.app/Contents/Resources"
	cp hello_mac "TheDL_Mac.app/Contents/MacOS/TheDL"
	cp Info_Mac.plist "TheDL_Mac.app/Contents/Info.plist"

# 1.5 macOS Neko Bundle (.app)
neko_bundle: 
	@echo "Building macOS Neko Bundle (10.4)..."
	$(NEKO_CC) $(MAC_NEKO_FLAGS) -Wall $(MAC_FW) mac_main.m GTMAppDelegate.m -o hello_neko
	mkdir -p "TheDL_Neko.app/Contents/MacOS"
	mkdir -p "TheDL_Neko.app/Contents/Resources"
	cp hello_neko "TheDL_Neko.app/Contents/MacOS/TheDL Neko"
	cp Info_Neko.plist "TheDL_Neko.app/Contents/Info.plist"

# 2. iOS Bundle (.app)
ios_bundle:
	@echo "Building iOS Bundle (armv7, armv7s, arm64)..."
	$(CC) $(IOS_FLAGS) $(IOS_FW) ios_main.m GTMiOSAppDelegate.m -o hello_ios
	mkdir -p "TheDL_iOS.app"
	cp hello_ios "TheDL_iOS.app/TheDL"
	cp Info_iOS.plist "TheDL_iOS.app/Info.plist"

# 2.5 iOS Simulator Bundle (.app)
ios_sim:
	@echo "Building iOS Simulator Bundle (i386)..."
	$(CC) $(SIM_FLAGS) $(IOS_FW) ios_main.m GTMiOSAppDelegate.m -o hello_sim
	mkdir -p "TheDL_Sim.app"
	cp hello_sim "TheDL_Sim.app/TheDL"
	cp Info_iOS.plist "TheDL_Sim.app/Info.plist"

# 3. iOS Package (.ipa)
ipa: ios_bundle
	@echo "Packaging IPA..."
	mkdir -p Payload
	cp -R "TheDL_iOS.app" Payload/
	zip -qr TheDL.ipa Payload
	rm -rf Payload

clean:
	rm -rf *.app *.ipa hello_ios hello_mac hello_neko hello_sim Payload
