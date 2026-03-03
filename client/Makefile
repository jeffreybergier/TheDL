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
	$(CC) $(IOS_ARCHS) -isysroot $(IOS_SDK) -miphoneos-version-min=3.1 $(ARC_FLAGS) -g -DDEBUG -c $< -o $(DEBUG_DIR)/XP_iOS.o $(LIB_INCLUDES)
	$(AR) rcs $@ $(DEBUG_DIR)/XP_iOS.o

$(DEBUG_DIR)/libXP_Sim.a: $(XP_DIR)/XPObject.m
	@mkdir -p $(DEBUG_DIR)
	$(CC) $(SIM_ARCHS) -isysroot $(SIM_SDK) -mios-simulator-version-min=3.1 $(ARC_FLAGS) -g -DDEBUG -c $< -o $(DEBUG_DIR)/XP_Sim.o $(LIB_INCLUDES)
	$(AR) rcs $@ $(DEBUG_DIR)/XP_Sim.o

$(DEBUG_DIR)/libXP_Mac.a: $(XP_DIR)/XPObject.m
	@mkdir -p $(DEBUG_DIR)
	$(CC) $(MAC_MODERN_ARCHS) -isysroot $(MAC_MODERN_SDK) -mmacosx-version-min=10.7 $(ARC_FLAGS) -g -DDEBUG -c $< -o $(DEBUG_DIR)/XP_Mac.o $(LIB_INCLUDES)
	$(AR) rcs $@ $(DEBUG_DIR)/XP_Mac.o

$(DEBUG_DIR)/libXP_Neko.a: $(XP_DIR)/XPObject.m
	@mkdir -p $(DEBUG_DIR)
	$(NEKO_CC) $(MAC_NEKO_ARCHS) -isysroot $(MAC_NEKO_SDK) -mmacosx-version-min=10.4 -g -DDEBUG -c $< -o $(DEBUG_DIR)/XP_Neko.o $(LIB_INCLUDES)
	$(NEKO_AR) rcs $@ $(DEBUG_DIR)/XP_Neko.o

$(DEBUG_DIR)/libBase_iOS.a: $(BASE_DIR)/TDLObject.m $(DEBUG_DIR)/libXP_iOS.a
	@mkdir -p $(DEBUG_DIR)
	$(CC) $(IOS_ARCHS) -isysroot $(IOS_SDK) -miphoneos-version-min=3.1 $(ARC_FLAGS) -g -DDEBUG -c $< -o $(DEBUG_DIR)/Base_iOS.o $(LIB_INCLUDES)
	$(AR) rcs $@ $(DEBUG_DIR)/Base_iOS.o

$(DEBUG_DIR)/libBase_Sim.a: $(BASE_DIR)/TDLObject.m $(DEBUG_DIR)/libXP_Sim.a
	@mkdir -p $(DEBUG_DIR)
	$(CC) $(SIM_ARCHS) -isysroot $(SIM_SDK) -mios-simulator-version-min=3.1 $(ARC_FLAGS) -g -DDEBUG -c $< -o $(DEBUG_DIR)/Base_Sim.o $(LIB_INCLUDES)
	$(AR) rcs $@ $(DEBUG_DIR)/Base_Sim.o

$(DEBUG_DIR)/libBase_Mac.a: $(BASE_DIR)/TDLObject.m $(DEBUG_DIR)/libXP_Mac.a
	@mkdir -p $(DEBUG_DIR)
	$(CC) $(MAC_MODERN_ARCHS) -isysroot $(MAC_MODERN_SDK) -mmacosx-version-min=10.7 $(ARC_FLAGS) -g -DDEBUG -c $< -o $(DEBUG_DIR)/Base_Mac.o $(LIB_INCLUDES)
	$(AR) rcs $@ $(DEBUG_DIR)/Base_Mac.o

$(DEBUG_DIR)/libBase_Neko.a: $(BASE_DIR)/TDLObject.m $(DEBUG_DIR)/libXP_Neko.a
	@mkdir -p $(DEBUG_DIR)
	$(NEKO_CC) $(MAC_NEKO_ARCHS) -isysroot $(MAC_NEKO_SDK) -mmacosx-version-min=10.4 -g -DDEBUG -c $< -o $(DEBUG_DIR)/Base_Neko.o $(LIB_INCLUDES)
	$(NEKO_AR) rcs $@ $(DEBUG_DIR)/Base_Neko.o

# --- Static Libraries (Release) ---

$(RELEASE_DIR)/libXP_iOS.a: $(XP_DIR)/XPObject.m
	@mkdir -p $(RELEASE_DIR)
	$(CC) $(IOS_ARCHS) -isysroot $(IOS_SDK) -miphoneos-version-min=3.1 $(ARC_FLAGS) -O3 -c $< -o $(RELEASE_DIR)/XP_iOS.o $(LIB_INCLUDES)
	$(AR) rcs $@ $(RELEASE_DIR)/XP_iOS.o

$(RELEASE_DIR)/libXP_Mac.a: $(XP_DIR)/XPObject.m
	@mkdir -p $(RELEASE_DIR)
	$(CC) $(MAC_MODERN_ARCHS) -isysroot $(MAC_MODERN_SDK) -mmacosx-version-min=10.7 $(ARC_FLAGS) -O3 -c $< -o $(RELEASE_DIR)/XP_Mac.o $(LIB_INCLUDES)
	$(AR) rcs $@ $(RELEASE_DIR)/XP_Mac.o

$(RELEASE_DIR)/libXP_Neko.a: $(XP_DIR)/XPObject.m
	@mkdir -p $(RELEASE_DIR)
	$(NEKO_CC) $(MAC_NEKO_ARCHS) -isysroot $(MAC_NEKO_SDK) -mmacosx-version-min=10.4 -O3 -c $< -o $(RELEASE_DIR)/XP_Neko.o $(LIB_INCLUDES)
	$(NEKO_AR) rcs $@ $(RELEASE_DIR)/XP_Neko.o

$(RELEASE_DIR)/libBase_iOS.a: $(BASE_DIR)/TDLObject.m $(RELEASE_DIR)/libXP_iOS.a
	@mkdir -p $(RELEASE_DIR)
	$(CC) $(IOS_ARCHS) -isysroot $(IOS_SDK) -miphoneos-version-min=3.1 $(ARC_FLAGS) -O3 -c $< -o $(RELEASE_DIR)/Base_iOS.o $(LIB_INCLUDES)
	$(AR) rcs $@ $(RELEASE_DIR)/Base_iOS.o

$(RELEASE_DIR)/libBase_Mac.a: $(BASE_DIR)/TDLObject.m $(RELEASE_DIR)/libXP_Mac.a
	@mkdir -p $(RELEASE_DIR)
	$(CC) $(MAC_MODERN_ARCHS) -isysroot $(MAC_MODERN_SDK) -mmacosx-version-min=10.7 $(ARC_FLAGS) -O3 -c $< -o $(RELEASE_DIR)/Base_Mac.o $(LIB_INCLUDES)
	$(AR) rcs $@ $(RELEASE_DIR)/Base_Mac.o

$(RELEASE_DIR)/libBase_Neko.a: $(BASE_DIR)/TDLObject.m $(RELEASE_DIR)/libXP_Neko.a
	@mkdir -p $(RELEASE_DIR)
	$(NEKO_CC) $(MAC_NEKO_ARCHS) -isysroot $(MAC_NEKO_SDK) -mmacosx-version-min=10.4 -O3 -c $< -o $(RELEASE_DIR)/Base_Neko.o $(LIB_INCLUDES)
	$(NEKO_AR) rcs $@ $(RELEASE_DIR)/Base_Neko.o

# --- Debug Build ---
debug: clean_debug $(DEBUG_DIR)/libXP_Mac.a $(DEBUG_DIR)/libXP_Neko.a $(DEBUG_DIR)/libXP_iOS.a $(DEBUG_DIR)/libXP_Sim.a $(DEBUG_DIR)/libBase_Mac.a $(DEBUG_DIR)/libBase_Neko.a $(DEBUG_DIR)/libBase_iOS.a $(DEBUG_DIR)/libBase_Sim.a
	@echo "Building Debug Targets..."
	
	# Modern Mac (Debug)
	$(CC) $(MAC_MODERN_ARCHS) -isysroot $(MAC_MODERN_SDK) -mmacosx-version-min=10.7 $(ARC_FLAGS) -g -DDEBUG \
		-Wall $(MAC_FW) $(MAC_DIR)/mac_main.m $(MAC_DIR)/GTMAppDelegate.m \
		$(DEBUG_DIR)/libXP_Mac.a $(DEBUG_DIR)/libBase_Mac.a -o $(DEBUG_DIR)/hello_mac $(LIB_INCLUDES)
	mkdir -p "$(DEBUG_DIR)/TheDL-Mac.app/Contents/MacOS"
	cp $(DEBUG_DIR)/hello_mac "$(DEBUG_DIR)/TheDL-Mac.app/Contents/MacOS/TheDL"
	cp $(MAC_DIR)/Info_Mac.plist "$(DEBUG_DIR)/TheDL-Mac.app/Contents/Info.plist"
	
	# Neko Mac (Debug)
	$(NEKO_CC) $(MAC_NEKO_ARCHS) -isysroot $(MAC_NEKO_SDK) -mmacosx-version-min=10.4 -g -DDEBUG \
		-Wall $(MAC_FW) $(MAC_DIR)/mac_main.m $(MAC_DIR)/GTMAppDelegate.m \
		$(DEBUG_DIR)/libXP_Neko.a $(DEBUG_DIR)/libBase_Neko.a -o $(DEBUG_DIR)/hello_neko $(LIB_INCLUDES)
	mkdir -p "$(DEBUG_DIR)/TheDL-Neko.app/Contents/MacOS"
	cp $(DEBUG_DIR)/hello_neko "$(DEBUG_DIR)/TheDL-Neko.app/Contents/MacOS/TheDL Neko"
	cp $(MAC_DIR)/Info_Neko.plist "$(DEBUG_DIR)/TheDL-Neko.app/Contents/Info.plist"
	
	# iOS Phone Device (Debug)
	$(CC) $(IOS_ARCHS) -isysroot $(IOS_SDK) -miphoneos-version-min=3.1 $(ARC_FLAGS) -g -DDEBUG \
		$(IOS_FW) $(PHONE_DIR)/ios_main.m $(PHONE_DIR)/GTMiOSAppDelegate.m $(PHONE_DIR)/RootViewController.m \
		$(DEBUG_DIR)/libXP_iOS.a $(DEBUG_DIR)/libBase_iOS.a -o $(DEBUG_DIR)/hello_phone $(LIB_INCLUDES)
	mkdir -p "$(DEBUG_DIR)/TheDL-Phone.app"
	cp $(DEBUG_DIR)/hello_phone "$(DEBUG_DIR)/TheDL-Phone.app/TheDL"
	cp $(PHONE_DIR)/Info_iOS.plist "$(DEBUG_DIR)/TheDL-Phone.app/Info.plist"

	# iOS Simulator (Debug)
	$(CC) $(SIM_ARCHS) -isysroot $(SIM_SDK) -mios-simulator-version-min=3.1 -Wl,-no_pie -g -DDEBUG \
		$(IOS_FW) $(PHONE_DIR)/ios_main.m $(PHONE_DIR)/GTMiOSAppDelegate.m $(PHONE_DIR)/RootViewController.m \
		$(DEBUG_DIR)/libXP_Sim.a $(DEBUG_DIR)/libBase_Sim.a -o $(DEBUG_DIR)/hello_sim $(LIB_INCLUDES)

	mkdir -p "$(DEBUG_DIR)/TheDL-Sim.app"
	cp $(DEBUG_DIR)/hello_sim "$(DEBUG_DIR)/TheDL-Sim.app/TheDL"
	cp $(PHONE_DIR)/Info_iOS.plist "$(DEBUG_DIR)/TheDL-Sim.app/Info.plist"

# --- Release Build ---
release: clean_release $(RELEASE_DIR)/libXP_Mac.a $(RELEASE_DIR)/libXP_Neko.a $(RELEASE_DIR)/libXP_iOS.a $(RELEASE_DIR)/libBase_Mac.a $(RELEASE_DIR)/libBase_Neko.a $(RELEASE_DIR)/libBase_iOS.a
	@echo "Building Release Targets..."
	
	# Modern Mac (Release)
	$(CC) $(MAC_MODERN_ARCHS) -isysroot $(MAC_MODERN_SDK) -mmacosx-version-min=10.7 $(ARC_FLAGS) -O3 \
		-Wall -Werror $(MAC_FW) $(MAC_DIR)/mac_main.m $(MAC_DIR)/GTMAppDelegate.m \
		$(RELEASE_DIR)/libXP_Mac.a $(RELEASE_DIR)/libBase_Mac.a -o $(RELEASE_DIR)/hello_mac $(LIB_INCLUDES)
	mkdir -p "$(RELEASE_DIR)/TheDL.app/Contents/MacOS"
	cp $(RELEASE_DIR)/hello_mac "$(RELEASE_DIR)/TheDL.app/Contents/MacOS/TheDL"
	cp $(MAC_DIR)/Info_Mac.plist "$(RELEASE_DIR)/TheDL.app/Contents/Info.plist"
	
	# Neko Mac (Release)
	$(NEKO_CC) $(MAC_NEKO_ARCHS) -isysroot $(MAC_NEKO_SDK) -mmacosx-version-min=10.4 -O3 \
		-Wall $(MAC_FW) $(MAC_DIR)/mac_main.m $(MAC_DIR)/GTMAppDelegate.m \
		$(RELEASE_DIR)/libXP_Neko.a $(RELEASE_DIR)/libBase_Neko.a -o $(RELEASE_DIR)/hello_neko $(LIB_INCLUDES)
	mkdir -p "$(RELEASE_DIR)/TheDL Neko.app/Contents/MacOS"
	cp $(RELEASE_DIR)/hello_neko "$(RELEASE_DIR)/TheDL Neko.app/Contents/MacOS/TheDL Neko"
	cp $(MAC_DIR)/Info_Neko.plist "$(RELEASE_DIR)/TheDL Neko.app/Contents/Info.plist"
	
	# iOS Phone (IPA Release)
	$(CC) $(IOS_ARCHS) -isysroot $(IOS_SDK) -miphoneos-version-min=3.1 $(IOS_FW) -O3 \
		$(PHONE_DIR)/ios_main.m $(PHONE_DIR)/GTMiOSAppDelegate.m $(PHONE_DIR)/RootViewController.m \
		$(RELEASE_DIR)/libXP_iOS.a $(RELEASE_DIR)/libBase_iOS.a -o $(RELEASE_DIR)/hello_ios $(LIB_INCLUDES)
	mkdir -p "$(RELEASE_DIR)/TheDL_iOS.app"
	cp $(RELEASE_DIR)/hello_ios "$(RELEASE_DIR)/TheDL_iOS.app/TheDL"
	cp $(PHONE_DIR)/Info_iOS.plist "$(RELEASE_DIR)/TheDL_iOS.app/Info.plist"
	cd $(RELEASE_DIR) && mkdir -p Payload && cp -R TheDL_iOS.app Payload/ && zip -qr TheDL.ipa Payload && rm -rf Payload TheDL_iOS.app

# --- Testing ---

test_mac: $(DEBUG_DIR)/libXP_Mac.a $(DEBUG_DIR)/libBase_Mac.a
	@mkdir -p $(TEST_DIR)
	$(CC) -arch x86_64 -isysroot $(MAC_MODERN_SDK) -mmacosx-version-min=10.7 $(ARC_FLAGS) \
		$(MAC_FW) $(TEST_FW) tests/test_mac_main.m \
		$(DEBUG_DIR)/libXP_Mac.a $(DEBUG_DIR)/libBase_Mac.a -o $(TEST_DIR)/test_runner $(LIB_INCLUDES) \
		-F$(XCODE_PATH)/Platforms/MacOSX.platform/Developer/Library/Frameworks \
		-Xlinker -rpath -Xlinker $(XCODE_PATH)/Platforms/MacOSX.platform/Developer/Library/Frameworks
	@echo "Running Mac Tests..."
	$(TEST_DIR)/test_runner

test_ios: $(DEBUG_DIR)/libXP_Sim.a $(DEBUG_DIR)/libBase_Sim.a
	@mkdir -p $(TEST_DIR)
	$(CC) $(SIM_ARCHS) -isysroot $(SIM_SDK) -mios-simulator-version-min=3.1 $(ARC_FLAGS) \
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
