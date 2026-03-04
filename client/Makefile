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
TESTS_DIR = tests

# Build Directories
BUILD_DIR = build
DEBUG_DIR = $(BUILD_DIR)/debug
RELEASE_DIR = $(BUILD_DIR)/release
TEST_BIN_DIR = $(BUILD_DIR)/tests

# --- Source Lists ---
XP_SRCS = $(XP_DIR)/XPObject.m
BASE_SRCS = $(BASE_DIR)/TDLObject.m $(BASE_DIR)/TDLDownload.m $(BASE_DIR)/TDLDownloadList.m \
            $(BASE_DIR)/TDLService.m $(BASE_DIR)/TDLDownloadTask.m \
            $(BASE_DIR)/TDLURLConnectionService.m $(BASE_DIR)/TDLServiceManager.m

PHONE_APP_SRCS = $(PHONE_DIR)/ios_main.m $(PHONE_DIR)/AppDelegate.m $(PHONE_DIR)/RootViewController.m \
                 $(PHONE_DIR)/TDLDownloadTableViewController.m $(PHONE_DIR)/TDLServiceListViewController.m \
                 $(PHONE_DIR)/TDLURLConnectionServiceTableViewController.m

MAC_APP_SRCS = $(MAC_DIR)/mac_main.m $(MAC_DIR)/AppDelegate.m

TEST_SRCS = tests/TDLObjectTests.m tests/TDLDownloadTests.m tests/TDLURLConnectionServiceTests.m

# --- Flags ---
ARC_FLAGS = -fno-objc-arc
WARN_FLAGS = -Wall -Werror
COMMON_FW = -framework Foundation -framework CoreData
IOS_FW = $(ARC_FLAGS) $(WARN_FLAGS) $(COMMON_FW) -framework UIKit
MAC_FW = $(ARC_FLAGS) $(WARN_FLAGS) $(COMMON_FW) -framework AppKit -framework Cocoa
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

# --- Helper for Library Inclusion ---
LIB_INCLUDES = -I$(XP_DIR) -I$(BASE_DIR) -I$(PHONE_DIR) -I$(MAC_DIR)

# --- Build Rules ---

.PHONY: all debug release clean test_mac test_ios neko

all: debug test_mac test_ios

# --- Static Libraries (Debug) ---

$(DEBUG_DIR)/libXP_iOS.a: $(XP_SRCS)
	@mkdir -p $(DEBUG_DIR)
	$(CC) $(IOS_ARCHS) -isysroot $(IOS_SDK) -miphoneos-version-min=$(IOS_MIN) $(ARC_FLAGS) $(WARN_FLAGS) -g -DDEBUG -c $< -o $(DEBUG_DIR)/XP_iOS.o $(LIB_INCLUDES)
	libtool -static -o $@ $(DEBUG_DIR)/XP_iOS.o

$(DEBUG_DIR)/libXP_Sim.a: $(XP_SRCS)
	@mkdir -p $(DEBUG_DIR)
	$(CC) $(SIM_ARCHS) -isysroot $(SIM_SDK) -mios-simulator-version-min=$(IOS_MIN) $(ARC_FLAGS) $(WARN_FLAGS) -g -DDEBUG -c $< -o $(DEBUG_DIR)/XP_Sim.o $(LIB_INCLUDES)
	libtool -static -o $@ $(DEBUG_DIR)/XP_Sim.o

$(DEBUG_DIR)/libXP_Mac.a: $(XP_SRCS)
	@mkdir -p $(DEBUG_DIR)
	$(CC) $(MAC_MODERN_ARCHS) -isysroot $(MAC_MODERN_SDK) -mmacosx-version-min=$(MAC_MODERN_MIN) $(ARC_FLAGS) $(WARN_FLAGS) -g -DDEBUG -c $< -o $(DEBUG_DIR)/XP_Mac.o $(LIB_INCLUDES)
	libtool -static -o $@ $(DEBUG_DIR)/XP_Mac.o

$(DEBUG_DIR)/libXP_Neko.a: $(XP_SRCS)
	@mkdir -p $(DEBUG_DIR)
	$(NEKO_CC) $(MAC_NEKO_ARCHS) -isysroot $(MAC_NEKO_SDK) -mmacosx-version-min=$(MAC_NEKO_MIN) $(NEKO_FLAGS) -g -DDEBUG -c $< -o $(DEBUG_DIR)/XP_Neko.o $(LIB_INCLUDES)
	libtool -static -o $@ $(DEBUG_DIR)/XP_Neko.o

$(DEBUG_DIR)/libBase_iOS.a: $(BASE_SRCS) $(DEBUG_DIR)/libXP_iOS.a
	@mkdir -p $(DEBUG_DIR)
	@objs=""; for src in $(BASE_SRCS); do \
		obj=$(DEBUG_DIR)/`basename $$src .m`_iOS.o; \
		$(CC) $(IOS_ARCHS) -isysroot $(IOS_SDK) -miphoneos-version-min=$(IOS_MIN) $(ARC_FLAGS) $(WARN_FLAGS) -g -DDEBUG -c $$src -o $$obj $(LIB_INCLUDES); \
		objs="$$objs $$obj"; \
	done; \
	libtool -static -o $@ $$objs

$(DEBUG_DIR)/libBase_Sim.a: $(BASE_SRCS) $(DEBUG_DIR)/libXP_Sim.a
	@mkdir -p $(DEBUG_DIR)
	@objs=""; for src in $(BASE_SRCS); do \
		obj=$(DEBUG_DIR)/`basename $$src .m`_Sim.o; \
		$(CC) $(SIM_ARCHS) -isysroot $(SIM_SDK) -mios-simulator-version-min=$(IOS_MIN) $(ARC_FLAGS) $(WARN_FLAGS) -g -DDEBUG -c $$src -o $$obj $(LIB_INCLUDES); \
		objs="$$objs $$obj"; \
	done; \
	libtool -static -o $@ $$objs

$(DEBUG_DIR)/libBase_Mac.a: $(BASE_SRCS) $(DEBUG_DIR)/libXP_Mac.a
	@mkdir -p $(DEBUG_DIR)
	@objs=""; for src in $(BASE_SRCS); do \
		obj=$(DEBUG_DIR)/`basename $$src .m`_Mac.o; \
		$(CC) $(MAC_MODERN_ARCHS) -isysroot $(MAC_MODERN_SDK) -mmacosx-version-min=$(MAC_MODERN_MIN) $(ARC_FLAGS) $(WARN_FLAGS) -g -DDEBUG -c $$src -o $$obj $(LIB_INCLUDES); \
		objs="$$objs $$obj"; \
	done; \
	libtool -static -o $@ $$objs

$(DEBUG_DIR)/libBase_Neko.a: $(BASE_SRCS) $(DEBUG_DIR)/libXP_Neko.a
	@mkdir -p $(DEBUG_DIR)
	@objs=""; for src in $(BASE_SRCS); do \
		obj=$(DEBUG_DIR)/`basename $$src .m`_Neko.o; \
		$(NEKO_CC) $(MAC_NEKO_ARCHS) -isysroot $(MAC_NEKO_SDK) -mmacosx-version-min=$(MAC_NEKO_MIN) $(NEKO_FLAGS) -g -DDEBUG -c $$src -o $$obj $(LIB_INCLUDES); \
		objs="$$objs $$obj"; \
	done; \
	libtool -static -o $@ $$objs

# --- Debug Build Targets ---
debug: clean_debug $(DEBUG_DIR)/libXP_Mac.a $(DEBUG_DIR)/libXP_iOS.a $(DEBUG_DIR)/libXP_Sim.a $(DEBUG_DIR)/libBase_Mac.a $(DEBUG_DIR)/libBase_iOS.a $(DEBUG_DIR)/libBase_Sim.a
	@echo "Building Debug Targets..."
	$(CC) $(MAC_MODERN_ARCHS) -isysroot $(MAC_MODERN_SDK) -mmacosx-version-min=$(MAC_MODERN_MIN) $(ARC_FLAGS) $(WARN_FLAGS) $(MAC_FW) -g -DDEBUG \
		$(MAC_APP_SRCS) $(DEBUG_DIR)/libXP_Mac.a $(DEBUG_DIR)/libBase_Mac.a -o $(DEBUG_DIR)/hello_mac $(LIB_INCLUDES)
	mkdir -p "$(DEBUG_DIR)/TheDL-Mac.app/Contents/MacOS"
	cp $(DEBUG_DIR)/hello_mac "$(DEBUG_DIR)/TheDL-Mac.app/Contents/MacOS/TheDL"
	cp $(MAC_DIR)/Info_Mac.plist "$(DEBUG_DIR)/TheDL-Mac.app/Contents/Info.plist"
	$(CC) $(IOS_ARCHS) -isysroot $(IOS_SDK) -miphoneos-version-min=$(IOS_MIN) $(ARC_FLAGS) $(WARN_FLAGS) $(IOS_FW) -g -DDEBUG \
		$(PHONE_APP_SRCS) $(DEBUG_DIR)/libXP_iOS.a $(DEBUG_DIR)/libBase_iOS.a -o $(DEBUG_DIR)/hello_phone $(LIB_INCLUDES)
	mkdir -p "$(DEBUG_DIR)/TheDL-Phone.app"
	cp $(DEBUG_DIR)/hello_phone "$(DEBUG_DIR)/TheDL-Phone.app/TheDL"
	cp $(PHONE_DIR)/Info_iOS.plist "$(DEBUG_DIR)/TheDL-Phone.app/Info.plist"
	$(CC) $(SIM_ARCHS) -isysroot $(SIM_SDK) -mios-simulator-version-min=$(IOS_MIN) -Wl,-no_pie $(ARC_FLAGS) $(WARN_FLAGS) $(IOS_FW) -g -DDEBUG \
		$(PHONE_APP_SRCS) $(DEBUG_DIR)/libXP_Sim.a $(DEBUG_DIR)/libBase_Sim.a -o $(DEBUG_DIR)/hello_sim $(LIB_INCLUDES)
	mkdir -p "$(DEBUG_DIR)/TheDL-Sim.app"
	cp $(DEBUG_DIR)/hello_sim "$(DEBUG_DIR)/TheDL-Sim.app/TheDL"
	cp $(PHONE_DIR)/Info_iOS.plist "$(DEBUG_DIR)/TheDL-Sim.app/Info.plist"

# Optional Neko Target
neko: $(DEBUG_DIR)/libXP_Neko.a $(DEBUG_DIR)/libBase_Neko.a
	$(NEKO_CC) $(MAC_NEKO_ARCHS) -isysroot $(MAC_NEKO_SDK) -mmacosx-version-min=$(MAC_NEKO_MIN) $(NEKO_FLAGS) $(MAC_FW) -g -DDEBUG \
		$(MAC_APP_SRCS) $(DEBUG_DIR)/libXP_Neko.a $(DEBUG_DIR)/libBase_Neko.a -o $(DEBUG_DIR)/hello_neko $(LIB_INCLUDES)
	mkdir -p "$(DEBUG_DIR)/TheDL-Neko.app/Contents/MacOS"
	cp $(DEBUG_DIR)/hello_neko "$(DEBUG_DIR)/TheDL-Neko.app/Contents/MacOS/TheDL Neko"
	cp $(MAC_DIR)/Info_Neko.plist "$(DEBUG_DIR)/TheDL-Neko.app/Contents/Info.plist"

# --- Testing ---
test_mac: $(DEBUG_DIR)/libXP_Mac.a $(DEBUG_DIR)/libBase_Mac.a
	@mkdir -p $(TEST_BIN_DIR)
	$(CC) -arch x86_64 -isysroot $(MAC_MODERN_SDK) -mmacosx-version-min=$(MAC_MODERN_MIN) $(ARC_FLAGS) $(WARN_FLAGS) $(MAC_FW) $(TEST_FW) \
		tests/test_mac_main.m $(TEST_SRCS) \
		$(DEBUG_DIR)/libXP_Mac.a $(DEBUG_DIR)/libBase_Mac.a -o $(TEST_BIN_DIR)/test_runner $(LIB_INCLUDES) \
		-F$(XCODE_PATH)/Platforms/MacOSX.platform/Developer/Library/Frameworks \
		-Xlinker -rpath -Xlinker $(XCODE_PATH)/Platforms/MacOSX.platform/Developer/Library/Frameworks
	@echo "Running Mac Tests..."
	$(TEST_BIN_DIR)/test_runner

test_ios: $(DEBUG_DIR)/libXP_Sim.a $(DEBUG_DIR)/libBase_Sim.a
	@mkdir -p $(TEST_BIN_DIR)
	$(CC) $(SIM_ARCHS) -isysroot $(SIM_SDK) -mios-simulator-min=$(IOS_MIN) $(ARC_FLAGS) $(WARN_FLAGS) -Wl,-no_pie $(IOS_FW) $(TEST_FW) \
		tests/test_iphone_main.m $(TEST_SRCS) \
		$(DEBUG_DIR)/libXP_Sim.a $(DEBUG_DIR)/libBase_Sim.a -o $(TEST_BIN_DIR)/test_sim_runner $(LIB_INCLUDES) \
		-F$(XCODE_PATH)/Platforms/iPhoneSimulator.platform/Developer/Library/Frameworks \
		-Xlinker -rpath -Xlinker $(XCODE_PATH)/Platforms/iPhoneSimulator.platform/Developer/Library/Frameworks
	@echo "Running iOS Simulator Tests..."
	xcrun simctl spawn booted $(TEST_BIN_DIR)/test_sim_runner

clean:
	rm -rf $(BUILD_DIR)

clean_debug:
	rm -rf $(DEBUG_DIR)

clean_release:
	rm -rf $(RELEASE_DIR)
