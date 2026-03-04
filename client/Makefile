# --- Toolchain & Paths ---
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

# Source Directories
PHONE_DIR = phone
MAC_DIR = mac
LIB_DIR = lib
XP_DIR = $(LIB_DIR)/CrossPlatform
BASE_DIR = $(LIB_DIR)/BaseLibrary

# Build Directories
BUILD_DIR = build
DEBUG_DIR = $(BUILD_DIR)/debug
RELEASE_DIR = $(BUILD_DIR)/release
TEST_DIR = $(BUILD_DIR)/tests

# --- Flags ---
ARC_FLAGS = -fno-objc-arc
COMMON_FW = -framework Foundation -framework CoreData
IOS_FW = $(ARC_FLAGS) $(COMMON_FW) -framework UIKit
MAC_FW = $(COMMON_FW) -framework AppKit -framework Cocoa
TEST_FW = -framework XCTest

# Universal Warning Flag
CFLAGS = -Wall

# Architectures
IOS_ARCHS = -arch armv7 -arch armv7s -arch arm64
SIM_ARCHS = -arch i386
MAC_MODERN_ARCHS = -arch x86_64 -arch i386
MAC_NEKO_ARCHS = -arch ppc -arch i386

# --- Helper for Library Inclusion ---
LIB_INCLUDES = -I$(XP_DIR) -I$(BASE_DIR)

# --- Build Rules ---

.PHONY: all debug release clean test_mac test_ios

all: debug test_mac test_ios

# --- Static Libraries (Debug) ---

$(DEBUG_DIR)/libXP_iOS.a: $(XP_DIR)/XPObject.m
	@mkdir -p $(DEBUG_DIR)
	$(CC) $(IOS_ARCHS) -isysroot $(IOS_SDK) -miphoneos-version-min=3.1 $(ARC_FLAGS) $(CFLAGS) -g -DDEBUG -c $< -o $(DEBUG_DIR)/XP_iOS.o $(LIB_INCLUDES)
	libtool -static -o $@ $(DEBUG_DIR)/XP_iOS.o

$(DEBUG_DIR)/libXP_Sim.a: $(XP_DIR)/XPObject.m
	@mkdir -p $(DEBUG_DIR)
	$(CC) $(SIM_ARCHS) -isysroot $(SIM_SDK) -mios-simulator-version-min=3.1 $(ARC_FLAGS) $(CFLAGS) -g -DDEBUG -c $< -o $(DEBUG_DIR)/XP_Sim.o $(LIB_INCLUDES)
	libtool -static -o $@ $(DEBUG_DIR)/XP_Sim.o

$(DEBUG_DIR)/libXP_Mac.a: $(XP_DIR)/XPObject.m
	@mkdir -p $(DEBUG_DIR)
	$(CC) $(MAC_MODERN_ARCHS) -isysroot $(MAC_MODERN_SDK) -mmacosx-version-min=10.7 $(ARC_FLAGS) $(CFLAGS) -g -DDEBUG -c $< -o $(DEBUG_DIR)/XP_Mac.o $(LIB_INCLUDES)
	libtool -static -o $@ $(DEBUG_DIR)/XP_Mac.o

$(DEBUG_DIR)/libXP_Neko.a: $(XP_DIR)/XPObject.m
	@mkdir -p $(DEBUG_DIR)
	$(NEKO_CC) $(MAC_NEKO_ARCHS) -isysroot $(MAC_NEKO_SDK) -mmacosx-version-min=10.4 $(CFLAGS) -g -DDEBUG -c $< -o $(DEBUG_DIR)/XP_Neko.o $(LIB_INCLUDES)
	libtool -static -o $@ $(DEBUG_DIR)/XP_Neko.o

$(DEBUG_DIR)/libBase_iOS.a: $(BASE_DIR)/TDLObject.m $(BASE_DIR)/TDLDownload.m $(BASE_DIR)/TDLDownloadList.m $(DEBUG_DIR)/libXP_iOS.a
	@mkdir -p $(DEBUG_DIR)
	$(CC) $(IOS_ARCHS) -isysroot $(IOS_SDK) -miphoneos-version-min=3.1 $(ARC_FLAGS) $(CFLAGS) -g -DDEBUG -c $(BASE_DIR)/TDLObject.m -o $(DEBUG_DIR)/Base_iOS_Obj.o $(LIB_INCLUDES)
	$(CC) $(IOS_ARCHS) -isysroot $(IOS_SDK) -miphoneos-version-min=3.1 $(ARC_FLAGS) $(CFLAGS) -g -DDEBUG -c $(BASE_DIR)/TDLDownload.m -o $(DEBUG_DIR)/Base_iOS_FW.o $(LIB_INCLUDES)
	$(CC) $(IOS_ARCHS) -isysroot $(IOS_SDK) -miphoneos-version-min=3.1 $(ARC_FLAGS) $(CFLAGS) -g -DDEBUG -c $(BASE_DIR)/TDLDownloadList.m -o $(DEBUG_DIR)/Base_iOS_List.o $(LIB_INCLUDES)
	libtool -static -o $@ $(DEBUG_DIR)/Base_iOS_Obj.o $(DEBUG_DIR)/Base_iOS_FW.o $(DEBUG_DIR)/Base_iOS_List.o

$(DEBUG_DIR)/libBase_Sim.a: $(BASE_DIR)/TDLObject.m $(BASE_DIR)/TDLDownload.m $(BASE_DIR)/TDLDownloadList.m $(DEBUG_DIR)/libXP_Sim.a
	@mkdir -p $(DEBUG_DIR)
	$(CC) $(SIM_ARCHS) -isysroot $(SIM_SDK) -mios-simulator-version-min=3.1 $(ARC_FLAGS) $(CFLAGS) -g -DDEBUG -c $(BASE_DIR)/TDLObject.m -o $(DEBUG_DIR)/Base_Sim_Obj.o $(LIB_INCLUDES)
	$(CC) $(SIM_ARCHS) -isysroot $(SIM_SDK) -mios-simulator-version-min=3.1 $(ARC_FLAGS) $(CFLAGS) -g -DDEBUG -c $(BASE_DIR)/TDLDownload.m -o $(DEBUG_DIR)/Base_Sim_FW.o $(LIB_INCLUDES)
	$(CC) $(SIM_ARCHS) -isysroot $(SIM_SDK) -mios-simulator-version-min=3.1 $(ARC_FLAGS) $(CFLAGS) -g -DDEBUG -c $(BASE_DIR)/TDLDownloadList.m -o $(DEBUG_DIR)/Base_Sim_List.o $(LIB_INCLUDES)
	libtool -static -o $@ $(DEBUG_DIR)/Base_Sim_Obj.o $(DEBUG_DIR)/Base_Sim_FW.o $(DEBUG_DIR)/Base_Sim_List.o

$(DEBUG_DIR)/libBase_Mac.a: $(BASE_DIR)/TDLObject.m $(BASE_DIR)/TDLDownload.m $(BASE_DIR)/TDLDownloadList.m $(DEBUG_DIR)/libXP_Mac.a
	@mkdir -p $(DEBUG_DIR)
	$(CC) $(MAC_MODERN_ARCHS) -isysroot $(MAC_MODERN_SDK) -mmacosx-version-min=10.7 $(ARC_FLAGS) $(CFLAGS) -g -DDEBUG -c $(BASE_DIR)/TDLObject.m -o $(DEBUG_DIR)/Base_Mac_Obj.o $(LIB_INCLUDES)
	$(CC) $(MAC_MODERN_ARCHS) -isysroot $(MAC_MODERN_SDK) -mmacosx-version-min=10.7 $(ARC_FLAGS) $(CFLAGS) -g -DDEBUG -c $(BASE_DIR)/TDLDownload.m -o $(DEBUG_DIR)/Base_Mac_FW.o $(LIB_INCLUDES)
	$(CC) $(MAC_MODERN_ARCHS) -isysroot $(MAC_MODERN_SDK) -mmacosx-version-min=10.7 $(ARC_FLAGS) $(CFLAGS) -g -DDEBUG -c $(BASE_DIR)/TDLDownloadList.m -o $(DEBUG_DIR)/Base_Mac_List.o $(LIB_INCLUDES)
	libtool -static -o $@ $(DEBUG_DIR)/Base_Mac_Obj.o $(DEBUG_DIR)/Base_Mac_FW.o $(DEBUG_DIR)/Base_Mac_List.o

$(DEBUG_DIR)/libBase_Neko.a: $(BASE_DIR)/TDLObject.m $(BASE_DIR)/TDLDownload.m $(BASE_DIR)/TDLDownloadList.m $(DEBUG_DIR)/libXP_Neko.a
	@mkdir -p $(DEBUG_DIR)
	$(NEKO_CC) $(MAC_NEKO_ARCHS) -isysroot $(MAC_NEKO_SDK) -mmacosx-version-min=10.4 $(CFLAGS) -g -DDEBUG -c $(BASE_DIR)/TDLObject.m -o $(DEBUG_DIR)/Base_Neko_Obj.o $(LIB_INCLUDES)
	$(NEKO_CC) $(MAC_NEKO_ARCHS) -isysroot $(MAC_NEKO_SDK) -mmacosx-version-min=10.4 $(CFLAGS) -g -DDEBUG -c $(BASE_DIR)/TDLDownload.m -o $(DEBUG_DIR)/Base_Neko_FW.o $(LIB_INCLUDES)
	$(NEKO_CC) $(MAC_NEKO_ARCHS) -isysroot $(MAC_NEKO_SDK) -mmacosx-version-min=10.4 $(CFLAGS) -g -DDEBUG -c $(BASE_DIR)/TDLDownloadList.m -o $(DEBUG_DIR)/Base_Neko_List.o $(LIB_INCLUDES)
	libtool -static -o $@ $(DEBUG_DIR)/Base_Neko_Obj.o $(DEBUG_DIR)/Base_Neko_FW.o $(DEBUG_DIR)/Base_Neko_List.o

# --- Static Libraries (Release) ---

$(RELEASE_DIR)/libXP_iOS.a: $(XP_DIR)/XPObject.m
	@mkdir -p $(RELEASE_DIR)
	$(CC) $(IOS_ARCHS) -isysroot $(IOS_SDK) -miphoneos-version-min=3.1 $(ARC_FLAGS) $(CFLAGS) -O3 -c $< -o $(RELEASE_DIR)/XP_iOS.o $(LIB_INCLUDES)
	libtool -static -o $@ $(RELEASE_DIR)/XP_iOS.o

$(RELEASE_DIR)/libXP_Mac.a: $(XP_DIR)/XPObject.m
	@mkdir -p $(RELEASE_DIR)
	$(CC) $(MAC_MODERN_ARCHS) -isysroot $(MAC_MODERN_SDK) -mmacosx-version-min=10.7 $(ARC_FLAGS) $(CFLAGS) -O3 -c $< -o $(RELEASE_DIR)/XP_Mac.o $(LIB_INCLUDES)
	libtool -static -o $@ $(RELEASE_DIR)/XP_Mac.o

$(RELEASE_DIR)/libXP_Neko.a: $(XP_DIR)/XPObject.m
	@mkdir -p $(RELEASE_DIR)
	$(NEKO_CC) $(MAC_NEKO_ARCHS) -isysroot $(MAC_NEKO_SDK) -mmacosx-version-min=10.4 $(CFLAGS) -O3 -c $< -o $(RELEASE_DIR)/XP_Neko.o $(LIB_INCLUDES)
	libtool -static -o $@ $(RELEASE_DIR)/XP_Neko.o

$(RELEASE_DIR)/libBase_iOS.a: $(BASE_DIR)/TDLObject.m $(BASE_DIR)/TDLDownload.m $(BASE_DIR)/TDLDownloadList.m $(RELEASE_DIR)/libXP_iOS.a
	@mkdir -p $(RELEASE_DIR)
	$(CC) $(IOS_ARCHS) -isysroot $(IOS_SDK) -miphoneos-version-min=3.1 $(ARC_FLAGS) $(CFLAGS) -O3 -c $(BASE_DIR)/TDLObject.m -o $(RELEASE_DIR)/Base_iOS_Obj.o $(LIB_INCLUDES)
	$(CC) $(IOS_ARCHS) -isysroot $(IOS_SDK) -miphoneos-version-min=3.1 $(ARC_FLAGS) $(CFLAGS) -O3 -c $(BASE_DIR)/TDLDownload.m -o $(RELEASE_DIR)/Base_iOS_FW.o $(LIB_INCLUDES)
	$(CC) $(IOS_ARCHS) -isysroot $(IOS_SDK) -miphoneos-version-min=3.1 $(ARC_FLAGS) $(CFLAGS) -O3 -c $(BASE_DIR)/TDLDownloadList.m -o $(RELEASE_DIR)/Base_iOS_List.o $(LIB_INCLUDES)
	libtool -static -o $@ $(RELEASE_DIR)/Base_iOS_Obj.o $(RELEASE_DIR)/Base_iOS_FW.o $(RELEASE_DIR)/Base_iOS_List.o

$(RELEASE_DIR)/libBase_Mac.a: $(BASE_DIR)/TDLObject.m $(BASE_DIR)/TDLDownload.m $(BASE_DIR)/TDLDownloadList.m $(RELEASE_DIR)/libXP_Mac.a
	@mkdir -p $(RELEASE_DIR)
	$(CC) $(MAC_MODERN_ARCHS) -isysroot $(MAC_MODERN_SDK) -mmacosx-version-min=10.7 $(ARC_FLAGS) $(CFLAGS) -O3 -c $(BASE_DIR)/TDLObject.m -o $(RELEASE_DIR)/Base_Mac_Obj.o $(LIB_INCLUDES)
	$(CC) $(MAC_MODERN_ARCHS) -isysroot $(MAC_MODERN_SDK) -mmacosx-version-min=10.7 $(ARC_FLAGS) $(CFLAGS) -O3 -c $(BASE_DIR)/TDLDownload.m -o $(RELEASE_DIR)/Base_Mac_FW.o $(LIB_INCLUDES)
	$(CC) $(MAC_MODERN_ARCHS) -isysroot $(MAC_MODERN_SDK) -mmacosx-version-min=10.7 $(ARC_FLAGS) $(CFLAGS) -O3 -c $(BASE_DIR)/TDLDownloadList.m -o $(RELEASE_DIR)/Base_Mac_List.o $(LIB_INCLUDES)
	libtool -static -o $@ $(RELEASE_DIR)/Base_Mac_Obj.o $(RELEASE_DIR)/Base_Mac_FW.o $(RELEASE_DIR)/Base_Mac_List.o

$(RELEASE_DIR)/libBase_Neko.a: $(BASE_DIR)/TDLObject.m $(BASE_DIR)/TDLDownload.m $(BASE_DIR)/TDLDownloadList.m $(RELEASE_DIR)/libXP_Neko.a
	@mkdir -p $(RELEASE_DIR)
	$(NEKO_CC) $(MAC_NEKO_ARCHS) -isysroot $(MAC_NEKO_SDK) -mmacosx-version-min=10.4 $(CFLAGS) -O3 -c $(BASE_DIR)/TDLObject.m -o $(RELEASE_DIR)/Base_Neko_Obj.o $(LIB_INCLUDES)
	$(NEKO_CC) $(MAC_NEKO_ARCHS) -isysroot $(MAC_NEKO_SDK) -mmacosx-version-min=10.4 $(CFLAGS) -O3 -c $(BASE_DIR)/TDLDownload.m -o $(RELEASE_DIR)/Base_Neko_FW.o $(LIB_INCLUDES)
	$(NEKO_CC) $(MAC_NEKO_ARCHS) -isysroot $(MAC_NEKO_SDK) -mmacosx-version-min=10.4 $(CFLAGS) -O3 -c $(BASE_DIR)/TDLDownloadList.m -o $(RELEASE_DIR)/Base_Neko_List.o $(LIB_INCLUDES)
	libtool -static -o $@ $(RELEASE_DIR)/Base_Neko_Obj.o $(RELEASE_DIR)/Base_Neko_FW.o $(RELEASE_DIR)/Base_Neko_List.o

# --- Debug Build ---
debug: clean_debug $(DEBUG_DIR)/libXP_Mac.a $(DEBUG_DIR)/libXP_Neko.a $(DEBUG_DIR)/libXP_iOS.a $(DEBUG_DIR)/libXP_Sim.a $(DEBUG_DIR)/libBase_Mac.a $(DEBUG_DIR)/libBase_Neko.a $(DEBUG_DIR)/libBase_iOS.a $(DEBUG_DIR)/libBase_Sim.a
	@echo "Building Debug Targets..."
	$(CC) $(MAC_MODERN_ARCHS) -isysroot $(MAC_MODERN_SDK) -mmacosx-version-min=10.7 $(ARC_FLAGS) $(CFLAGS) -g -DDEBUG \
		$(MAC_FW) $(MAC_DIR)/mac_main.m $(MAC_DIR)/AppDelegate.m \
		$(DEBUG_DIR)/libXP_Mac.a $(DEBUG_DIR)/libBase_Mac.a -o $(DEBUG_DIR)/hello_mac $(LIB_INCLUDES)
	mkdir -p "$(DEBUG_DIR)/TheDL-Mac.app/Contents/MacOS"
	cp $(DEBUG_DIR)/hello_mac "$(DEBUG_DIR)/TheDL-Mac.app/Contents/MacOS/TheDL"
	cp $(MAC_DIR)/Info_Mac.plist "$(DEBUG_DIR)/TheDL-Mac.app/Contents/Info.plist"
	$(NEKO_CC) $(MAC_NEKO_ARCHS) -isysroot $(MAC_NEKO_SDK) -mmacosx-version-min=10.4 $(CFLAGS) -g -DDEBUG \
		$(MAC_FW) $(MAC_DIR)/mac_main.m $(MAC_DIR)/AppDelegate.m \
		$(DEBUG_DIR)/libXP_Neko.a $(DEBUG_DIR)/libBase_Neko.a -o $(DEBUG_DIR)/hello_neko $(LIB_INCLUDES)
	mkdir -p "$(DEBUG_DIR)/TheDL-Neko.app/Contents/MacOS"
	cp $(DEBUG_DIR)/hello_neko "$(DEBUG_DIR)/TheDL-Neko.app/Contents/MacOS/TheDL Neko"
	cp $(MAC_DIR)/Info_Neko.plist "$(DEBUG_DIR)/TheDL-Neko.app/Contents/Info.plist"
	$(CC) $(IOS_ARCHS) -isysroot $(IOS_SDK) -miphoneos-version-min=3.1 $(ARC_FLAGS) $(CFLAGS) -g -DDEBUG \
		$(IOS_FW) $(PHONE_DIR)/ios_main.m $(PHONE_DIR)/AppDelegate.m $(PHONE_DIR)/RootViewController.m $(PHONE_DIR)/DownloadsTableViewController.m \
		$(DEBUG_DIR)/libXP_iOS.a $(DEBUG_DIR)/libBase_iOS.a -o $(DEBUG_DIR)/hello_phone $(LIB_INCLUDES)
	mkdir -p "$(DEBUG_DIR)/TheDL-Phone.app"
	cp $(DEBUG_DIR)/hello_phone "$(DEBUG_DIR)/TheDL-Phone.app/TheDL"
	cp $(PHONE_DIR)/Info_iOS.plist "$(DEBUG_DIR)/TheDL-Phone.app/Info.plist"
	$(CC) $(SIM_ARCHS) -isysroot $(SIM_SDK) -mios-simulator-version-min=3.1 $(ARC_FLAGS) $(CFLAGS) -Wl,-no_pie -g -DDEBUG \
		$(IOS_FW) $(PHONE_DIR)/ios_main.m $(PHONE_DIR)/AppDelegate.m $(PHONE_DIR)/RootViewController.m $(PHONE_DIR)/DownloadsTableViewController.m \
		$(DEBUG_DIR)/libXP_Sim.a $(DEBUG_DIR)/libBase_Sim.a -o $(DEBUG_DIR)/hello_sim $(LIB_INCLUDES)
	mkdir -p "$(DEBUG_DIR)/TheDL-Sim.app"
	cp $(DEBUG_DIR)/hello_sim "$(DEBUG_DIR)/TheDL-Sim.app/TheDL"
	cp $(PHONE_DIR)/Info_iOS.plist "$(DEBUG_DIR)/TheDL-Sim.app/Info.plist"

# --- Release Build ---
release: clean_release $(RELEASE_DIR)/libXP_Mac.a $(RELEASE_DIR)/libXP_Neko.a $(RELEASE_DIR)/libXP_iOS.a $(RELEASE_DIR)/libBase_Mac.a $(RELEASE_DIR)/libBase_Neko.a $(RELEASE_DIR)/libBase_iOS.a
	@echo "Building Release Targets..."
	$(CC) $(MAC_MODERN_ARCHS) -isysroot $(MAC_MODERN_SDK) -mmacosx-version-min=10.7 $(ARC_FLAGS) $(CFLAGS) -O3 \
		-Werror $(MAC_FW) $(MAC_DIR)/mac_main.m $(MAC_DIR)/AppDelegate.m \
		$(RELEASE_DIR)/libXP_Mac.a $(RELEASE_DIR)/libBase_Mac.a -o $(RELEASE_DIR)/hello_mac $(LIB_INCLUDES)
	mkdir -p "$(RELEASE_DIR)/TheDL.app/Contents/MacOS"
	cp $(RELEASE_DIR)/hello_mac "$(RELEASE_DIR)/TheDL.app/Contents/MacOS/TheDL"
	cp $(MAC_DIR)/Info_Mac.plist "$(RELEASE_DIR)/TheDL.app/Contents/Info.plist"
	$(NEKO_CC) $(MAC_NEKO_ARCHS) -isysroot $(MAC_NEKO_SDK) -mmacosx-version-min=10.4 $(CFLAGS) -O3 \
		$(MAC_FW) $(MAC_DIR)/mac_main.m $(MAC_DIR)/AppDelegate.m \
		$(RELEASE_DIR)/libXP_Neko.a $(RELEASE_DIR)/libBase_Neko.a -o $(RELEASE_DIR)/hello_neko $(LIB_INCLUDES)
	mkdir -p "$(RELEASE_DIR)/TheDL Neko.app/Contents/MacOS"
	cp $(RELEASE_DIR)/hello_neko "$(RELEASE_DIR)/TheDL Neko.app/Contents/MacOS/TheDL Neko"
	cp $(MAC_DIR)/Info_Neko.plist "$(RELEASE_DIR)/TheDL Neko.app/Contents/Info.plist"
	$(CC) $(IOS_ARCHS) -isysroot $(IOS_SDK) -miphoneos-version-min=3.1 $(IOS_FW) $(CFLAGS) -O3 \
		$(PHONE_DIR)/ios_main.m $(PHONE_DIR)/AppDelegate.m $(PHONE_DIR)/RootViewController.m $(PHONE_DIR)/DownloadsTableViewController.m \
		$(RELEASE_DIR)/libXP_iOS.a $(RELEASE_DIR)/libBase_iOS.a -o $(RELEASE_DIR)/hello_ios $(LIB_INCLUDES)
	mkdir -p "$(RELEASE_DIR)/TheDL_iOS.app"
	cp $(RELEASE_DIR)/hello_ios "$(RELEASE_DIR)/TheDL_iOS.app/TheDL"
	cp $(PHONE_DIR)/Info_iOS.plist "$(RELEASE_DIR)/TheDL_iOS.app/Info.plist"
	cd $(RELEASE_DIR) && mkdir -p Payload && cp -R TheDL_iOS.app Payload/ && zip -qr TheDL.ipa Payload && rm -rf Payload TheDL_iOS.app

# --- Testing ---

test_mac: $(DEBUG_DIR)/libXP_Mac.a $(DEBUG_DIR)/libBase_Mac.a
	@mkdir -p $(TEST_DIR)
	$(CC) -arch x86_64 -isysroot $(MAC_MODERN_SDK) -mmacosx-version-min=10.7 $(ARC_FLAGS) $(CFLAGS) \
		$(MAC_FW) $(TEST_FW) tests/test_mac_main.m \
		$(DEBUG_DIR)/libXP_Mac.a $(DEBUG_DIR)/libBase_Mac.a -o $(TEST_DIR)/test_runner $(LIB_INCLUDES) \
		-F$(XCODE_PATH)/Platforms/MacOSX.platform/Developer/Library/Frameworks \
		-Xlinker -rpath -Xlinker $(XCODE_PATH)/Platforms/MacOSX.platform/Developer/Library/Frameworks
	@echo "Running Mac Tests..."
	$(TEST_DIR)/test_runner

test_ios: $(DEBUG_DIR)/libXP_Sim.a $(DEBUG_DIR)/libBase_Sim.a
	@mkdir -p $(TEST_DIR)
	$(CC) $(SIM_ARCHS) -isysroot $(SIM_SDK) -mios-simulator-version-min=3.1 $(ARC_FLAGS) $(CFLAGS) \
		$(IOS_FW) $(TEST_FW) -Wl,-no_pie tests/test_iphone_main.m \
		$(DEBUG_DIR)/libXP_Sim.a $(DEBUG_DIR)/libBase_Sim.a -o $(TEST_DIR)/test_sim_runner $(LIB_INCLUDES) \
		-F$(XCODE_PATH)/Platforms/iPhoneSimulator.platform/Developer/Library/Frameworks \
		-Xlinker -rpath -Xlinker $(XCODE_PATH)/Platforms/iPhoneSimulator.platform/Developer/Library/Frameworks
	@echo "Running iOS Simulator Tests..."
	xcrun simctl spawn booted $(TEST_DIR)/test_sim_runner

clean:
	rm -rf $(BUILD_DIR)

clean_debug:
	rm -rf $(DEBUG_DIR)

clean_release:
	rm -rf $(RELEASE_DIR)
