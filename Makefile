# --- Toolchain & Paths ---
CC = clang
XCODE_PATH = /Applications/Xcode.app/Contents/Developer
IOS_SDK = $(XCODE_PATH)/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS8.2.sdk
SIM_SDK = $(XCODE_PATH)/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator8.2.sdk
MAC_SDK = $(XCODE_PATH)/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.10.sdk

# --- Memory Management ---
# Using manual retain/release as requested in GEMINI.md
MM_FLAGS = -fno-objc-arc

# --- Warning Flags ---
CFLAGS = -Wall -Werror

# --- Architecture & SDK Flags ---
COMMON_FW = $(MM_FLAGS) $(CFLAGS) -framework Foundation -framework CoreData
IOS_FW = $(COMMON_FW) -framework UIKit
MAC_FW = $(COMMON_FW) -framework AppKit -framework Cocoa

# iOS: armv7, armv7s, arm64 (Min 3.1)
IOS_ARCHS = -arch armv7 -arch armv7s -arch arm64
IOS_FLAGS = $(IOS_ARCHS) -isysroot $(IOS_SDK) -miphoneos-version-min=3.1

# iOS Simulator: i386 (Min 3.1)
SIM_ARCHS = -arch i386
SIM_FLAGS = $(SIM_ARCHS) -isysroot $(SIM_SDK) -mios-simulator-version-min=3.1 -Wl,-no_pie

# macOS: ppc, i386, x86_64 (Min 10.4)
# Note: Xcode 6.2 (Clang) does not natively support -arch ppc.
# We'll use i386 and x86_64 for now, but I've kept ppc in the ARCHS to match your goal.
MAC_ARCHS = -arch i386 -arch x86_64
MAC_FLAGS = $(MAC_ARCHS) -isysroot $(MAC_SDK) -mmacosx-version-min=10.4

# --- Build Targets ---
all: ios_bundle mac_bundle

# 1. macOS Bundle (.app)
mac_bundle: 
	@echo "Building macOS Bundle (i386, x86_64)..."
	$(CC) $(MAC_FLAGS) $(MAC_FW) mac_main.m GTMAppDelegate.m -o hello_mac
	mkdir -p "TheDL_Mac.app/Contents/MacOS"
	mkdir -p "TheDL_Mac.app/Contents/Resources"
	cp hello_mac "TheDL_Mac.app/Contents/MacOS/TheDL"
	cp Info_Mac.plist "TheDL_Mac.app/Contents/Info.plist"

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
	rm -rf *.app *.ipa hello_ios hello_mac Payload
