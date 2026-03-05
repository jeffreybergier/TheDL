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
MAC_APP_SRCS = $(MAC_DIR)/mac_main.m $(MAC_DIR)/AppDelegate.m

# --- Helper for Library Inclusion ---
LIB_INCLUDES = -I$(XP_DIR) -I$(BASE_DIR) -I$(PHONE_DIR) -I$(MAC_DIR)

# --- Build Rules ---

.PHONY: all debug release clean test_mac test_ios neko xp_libs base_libs phone_apps

all: debug test_mac test_ios

# --- Delegate Library Builds ---
xp_libs:
	@echo "Building CrossPlatform libraries..."
	$(MAKE) -C $(XP_DIR) all
	@mkdir -p $(DEBUG_DIR)
	cp $(XP_DIR)/libXP_iOS.a $(DEBUG_DIR)/
	cp $(XP_DIR)/libXP_Sim.a $(DEBUG_DIR)/
	cp $(XP_DIR)/libXP_Mac.a $(DEBUG_DIR)/
	cp $(XP_DIR)/libXP_Neko.a $(DEBUG_DIR)/

base_libs: xp_libs
	@echo "Building BaseLibrary libraries..."
	$(MAKE) -C $(BASE_DIR) all
	@mkdir -p $(DEBUG_DIR)
	cp $(BASE_DIR)/libBase_iOS.a $(DEBUG_DIR)/
	cp $(BASE_DIR)/libBase_Sim.a $(DEBUG_DIR)/
	cp $(BASE_DIR)/libBase_Mac.a $(DEBUG_DIR)/
	cp $(BASE_DIR)/libBase_Neko.a $(DEBUG_DIR)/

# --- Delegate Phone App Build ---
phone_apps: base_libs
	@echo "Building Phone applications..."
	$(MAKE) -C $(PHONE_DIR) all
	@mkdir -p $(DEBUG_DIR)
	cp -R $(PHONE_DIR)/TheDL-Phone.app $(DEBUG_DIR)/
	cp -R $(PHONE_DIR)/TheDL-Sim.app $(DEBUG_DIR)/

# --- Debug Build Targets ---
debug: clean_debug base_libs phone_apps
	@echo "Building Mac Debug Targets..."
	$(CC) $(MAC_MODERN_ARCHS) -isysroot $(MAC_MODERN_SDK) -mmacosx-version-min=$(MAC_MODERN_MIN) $(ARC_FLAGS) $(CLANG_WARN_FLAGS) $(MAC_FW) -g -DDEBUG \
		$(MAC_APP_SRCS) $(DEBUG_DIR)/libXP_Mac.a $(DEBUG_DIR)/libBase_Mac.a -o $(DEBUG_DIR)/hello_mac $(LIB_INCLUDES)
	mkdir -p "$(DEBUG_DIR)/TheDL-Mac.app/Contents/MacOS"
	cp $(DEBUG_DIR)/hello_mac "$(DEBUG_DIR)/TheDL-Mac.app/Contents/MacOS/TheDL"
	cp $(MAC_DIR)/Info_Mac.plist "$(DEBUG_DIR)/TheDL-Mac.app/Contents/Info.plist"

# Optional Neko Target
neko: base_libs
	$(NEKO_CC) $(MAC_NEKO_ARCHS) -isysroot $(MAC_NEKO_SDK) -mmacosx-version-min=$(MAC_NEKO_MIN) $(NEKO_FLAGS) $(MAC_FW) -g -DDEBUG \
		$(MAC_APP_SRCS) $(DEBUG_DIR)/libXP_Neko.a $(DEBUG_DIR)/libBase_Neko.a -o $(DEBUG_DIR)/hello_neko $(LIB_INCLUDES)
	mkdir -p "$(DEBUG_DIR)/TheDL-Neko.app/Contents/MacOS"
	cp $(DEBUG_DIR)/hello_neko "$(DEBUG_DIR)/TheDL-Neko.app/Contents/MacOS/TheDL Neko"
	cp $(MAC_DIR)/Info_Neko.plist "$(DEBUG_DIR)/TheDL-Neko.app/Contents/Info.plist"

# --- Testing ---
test_mac: base_libs
	$(MAKE) -C $(XP_DIR) test_mac
	$(MAKE) -C $(BASE_DIR) test_mac

test_ios: base_libs
	$(MAKE) -C $(XP_DIR) test_sim
	$(MAKE) -C $(BASE_DIR) test_sim

clean:
	rm -rf $(BUILD_DIR)
	$(MAKE) -C $(XP_DIR) clean
	$(MAKE) -C $(BASE_DIR) clean
	$(MAKE) -C $(PHONE_DIR) clean

clean_debug:
	rm -rf $(DEBUG_DIR)
	$(MAKE) -C $(XP_DIR) clean
	$(MAKE) -C $(BASE_DIR) clean
	$(MAKE) -C $(PHONE_DIR) clean

clean_release:
	rm -rf $(RELEASE_DIR)
	$(MAKE) -C $(XP_DIR) clean
	$(MAKE) -C $(BASE_DIR) clean
	$(MAKE) -C $(PHONE_DIR) clean
