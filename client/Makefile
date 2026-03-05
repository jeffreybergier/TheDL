# Include centralized configuration
include common.mk

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
BASE_SRCS = $(BASE_DIR)/TDLObject.m $(BASE_DIR)/TDLDownload.m $(BASE_DIR)/TDLDownloadList.m \
            $(BASE_DIR)/TDLService.m $(BASE_DIR)/TDLDownloadTask.m \
            $(BASE_DIR)/TDLURLConnectionService.m $(BASE_DIR)/TDLServiceManager.m

PHONE_APP_SRCS = $(PHONE_DIR)/ios_main.m $(PHONE_DIR)/AppDelegate.m $(PHONE_DIR)/RootViewController.m \
                 $(PHONE_DIR)/TDLDownloadTableViewController.m $(PHONE_DIR)/TDLServiceListViewController.m \
                 $(PHONE_DIR)/TDLURLConnectionServiceTableViewController.m

MAC_APP_SRCS = $(MAC_DIR)/mac_main.m $(MAC_DIR)/AppDelegate.m

TEST_SRCS = tests/TDLObjectTests.m tests/TDLDownloadTests.m tests/TDLURLConnectionServiceTests.m

# --- Helper for Library Inclusion ---
LIB_INCLUDES = -I$(XP_DIR) -I$(BASE_DIR) -I$(PHONE_DIR) -I$(MAC_DIR)

# --- Build Rules ---

.PHONY: all debug release clean test_mac test_ios neko xp_libs

all: debug test_mac test_ios

# --- Delegate CrossPlatform build to its own Makefile ---
xp_libs:
	@echo "Building CrossPlatform libraries..."
	$(MAKE) -C $(XP_DIR) all
	@mkdir -p $(DEBUG_DIR)
	cp $(XP_DIR)/libXP_iOS.a $(DEBUG_DIR)/
	cp $(XP_DIR)/libXP_Sim.a $(DEBUG_DIR)/
	cp $(XP_DIR)/libXP_Mac.a $(DEBUG_DIR)/
	cp $(XP_DIR)/libXP_Neko.a $(DEBUG_DIR)/

# --- Static Libraries (Debug) ---

$(DEBUG_DIR)/libXP_iOS.a $(DEBUG_DIR)/libXP_Sim.a $(DEBUG_DIR)/libXP_Mac.a $(DEBUG_DIR)/libXP_Neko.a: xp_libs

$(DEBUG_DIR)/libBase_iOS.a: $(BASE_SRCS) $(DEBUG_DIR)/libXP_iOS.a
	@mkdir -p $(DEBUG_DIR)
	@objs=""; for src in $(BASE_SRCS); do \
		obj=$(DEBUG_DIR)/`basename $$src .m`_iOS.o; \
		$(CC) $(IOS_ARCHS) -isysroot $(IOS_SDK) -miphoneos-version-min=$(IOS_MIN) $(ARC_FLAGS) $(CLANG_WARN_FLAGS) -g -DDEBUG -c $$src -o $$obj $(LIB_INCLUDES); \
		objs="$$objs $$obj"; \
	done; \
	libtool -static -o $@ $$objs

$(DEBUG_DIR)/libBase_Sim.a: $(BASE_SRCS) $(DEBUG_DIR)/libXP_Sim.a
	@mkdir -p $(DEBUG_DIR)
	@objs=""; for src in $(BASE_SRCS); do \
		obj=$(DEBUG_DIR)/`basename $$src .m`_Sim.o; \
		$(CC) $(SIM_ARCHS) -isysroot $(SIM_SDK) -mios-simulator-version-min=$(IOS_MIN) $(ARC_FLAGS) $(CLANG_WARN_FLAGS) -g -DDEBUG -c $$src -o $$obj $(LIB_INCLUDES); \
		objs="$$objs $$obj"; \
	done; \
	libtool -static -o $@ $$objs

$(DEBUG_DIR)/libBase_Mac.a: $(BASE_SRCS) $(DEBUG_DIR)/libXP_Mac.a
	@mkdir -p $(DEBUG_DIR)
	@objs=""; for src in $(BASE_SRCS); do \
		obj=$(DEBUG_DIR)/`basename $$src .m`_Mac.o; \
		$(CC) $(MAC_MODERN_ARCHS) -isysroot $(MAC_MODERN_SDK) -mmacosx-version-min=$(MAC_MODERN_MIN) $(ARC_FLAGS) $(CLANG_WARN_FLAGS) -g -DDEBUG -c $$src -o $$obj $(LIB_INCLUDES); \
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
debug: clean_debug xp_libs $(DEBUG_DIR)/libBase_Mac.a $(DEBUG_DIR)/libBase_iOS.a $(DEBUG_DIR)/libBase_Sim.a
	@echo "Building Debug Targets..."
	$(CC) $(MAC_MODERN_ARCHS) -isysroot $(MAC_MODERN_SDK) -mmacosx-version-min=$(MAC_MODERN_MIN) $(ARC_FLAGS) $(CLANG_WARN_FLAGS) $(MAC_FW) -g -DDEBUG \
		$(MAC_APP_SRCS) $(DEBUG_DIR)/libXP_Mac.a $(DEBUG_DIR)/libBase_Mac.a -o $(DEBUG_DIR)/hello_mac $(LIB_INCLUDES)
	mkdir -p "$(DEBUG_DIR)/TheDL-Mac.app/Contents/MacOS"
	cp $(DEBUG_DIR)/hello_mac "$(DEBUG_DIR)/TheDL-Mac.app/Contents/MacOS/TheDL"
	cp $(MAC_DIR)/Info_Mac.plist "$(DEBUG_DIR)/TheDL-Mac.app/Contents/Info.plist"
	$(CC) $(IOS_ARCHS) -isysroot $(IOS_SDK) -miphoneos-version-min=$(IOS_MIN) $(ARC_FLAGS) $(CLANG_WARN_FLAGS) $(IOS_FW) -g -DDEBUG \
		$(PHONE_APP_SRCS) $(DEBUG_DIR)/libXP_iOS.a $(DEBUG_DIR)/libBase_iOS.a -o $(DEBUG_DIR)/hello_phone $(LIB_INCLUDES)
	mkdir -p "$(DEBUG_DIR)/TheDL-Phone.app"
	cp $(DEBUG_DIR)/hello_phone "$(DEBUG_DIR)/TheDL-Phone.app/TheDL"
	cp $(PHONE_DIR)/Info_iOS.plist "$(DEBUG_DIR)/TheDL-Phone.app/Info.plist"
	$(CC) $(SIM_ARCHS) -isysroot $(SIM_SDK) -mios-simulator-version-min=$(IOS_MIN) -Wl,-no_pie $(ARC_FLAGS) $(CLANG_WARN_FLAGS) $(IOS_FW) -g -DDEBUG \
		$(PHONE_APP_SRCS) $(DEBUG_DIR)/libXP_Sim.a $(DEBUG_DIR)/libBase_Sim.a -o $(DEBUG_DIR)/hello_sim $(LIB_INCLUDES)
	mkdir -p "$(DEBUG_DIR)/TheDL-Sim.app"
	cp $(DEBUG_DIR)/hello_sim "$(DEBUG_DIR)/TheDL-Sim.app/TheDL"
	cp $(PHONE_DIR)/Info_iOS.plist "$(DEBUG_DIR)/TheDL-Sim.app/Info.plist"

# Optional Neko Target
neko: xp_libs $(DEBUG_DIR)/libBase_Neko.a
	$(NEKO_CC) $(MAC_NEKO_ARCHS) -isysroot $(MAC_NEKO_SDK) -mmacosx-version-min=$(MAC_NEKO_MIN) $(NEKO_FLAGS) $(MAC_FW) -g -DDEBUG \
		$(MAC_APP_SRCS) $(DEBUG_DIR)/libXP_Neko.a $(DEBUG_DIR)/libBase_Neko.a -o $(DEBUG_DIR)/hello_neko $(LIB_INCLUDES)
	mkdir -p "$(DEBUG_DIR)/TheDL-Neko.app/Contents/MacOS"
	cp $(DEBUG_DIR)/hello_neko "$(DEBUG_DIR)/TheDL-Neko.app/Contents/MacOS/TheDL Neko"
	cp $(MAC_DIR)/Info_Neko.plist "$(DEBUG_DIR)/TheDL-Neko.app/Contents/Info.plist"

# --- Testing ---
test_mac: xp_libs $(DEBUG_DIR)/libBase_Mac.a
	@mkdir -p $(TEST_BIN_DIR)
	$(CC) -arch x86_64 -isysroot $(MAC_MODERN_SDK) -mmacosx-version-min=$(MAC_MODERN_MIN) $(ARC_FLAGS) $(CLANG_WARN_FLAGS) $(MAC_FW) $(TEST_FW) \
		tests/test_mac_main.m $(TEST_SRCS) \
		$(DEBUG_DIR)/libXP_Mac.a $(DEBUG_DIR)/libBase_Mac.a -o $(TEST_BIN_DIR)/test_runner $(LIB_INCLUDES) \
		-F$(XCODE_PATH)/Platforms/MacOSX.platform/Developer/Library/Frameworks \
		-Xlinker -rpath -Xlinker $(XCODE_PATH)/Platforms/MacOSX.platform/Developer/Library/Frameworks
	@echo "Running Mac Tests..."
	$(TEST_BIN_DIR)/test_runner

test_ios: xp_libs $(DEBUG_DIR)/libBase_Sim.a
	@mkdir -p $(TEST_BIN_DIR)
	$(CC) $(SIM_ARCHS) -isysroot $(SIM_SDK) -mios-simulator-version-min=$(IOS_MIN) $(ARC_FLAGS) $(CLANG_WARN_FLAGS) -Wl,-no_pie $(IOS_FW) $(TEST_FW) \
		tests/test_iphone_main.m $(TEST_SRCS) \
		$(DEBUG_DIR)/libXP_Sim.a $(DEBUG_DIR)/libBase_Sim.a -o $(TEST_BIN_DIR)/test_sim_runner $(LIB_INCLUDES) \
		-F$(XCODE_PATH)/Platforms/iPhoneSimulator.platform/Developer/Library/Frameworks \
		-Xlinker -rpath -Xlinker $(XCODE_PATH)/Platforms/iPhoneSimulator.platform/Developer/Library/Frameworks
	@echo "Running iOS Simulator Tests..."
	xcrun simctl spawn booted $(TEST_BIN_DIR)/test_sim_runner

clean:
	rm -rf $(BUILD_DIR)
	$(MAKE) -C $(XP_DIR) clean

clean_debug:
	rm -rf $(DEBUG_DIR)
	$(MAKE) -C $(XP_DIR) clean

clean_release:
	rm -rf $(RELEASE_DIR)
	$(MAKE) -C $(XP_DIR) clean
