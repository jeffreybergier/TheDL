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

# --- Build Rules ---

.PHONY: all debug release clean test_mac test_ios xp_libs base_libs phone_apps mac_apps

all: debug test_mac test_ios

# --- Delegate Library Builds ---
xp_libs:
	@echo "Building CrossPlatform libraries..."
	$(MAKE) -C $(XP_DIR) all

base_libs: xp_libs
	@echo "Building BaseLibrary libraries..."
	$(MAKE) -C $(BASE_DIR) all

# --- Delegate Phone App Build ---
phone_apps: base_libs
	@echo "Building Phone applications..."
	$(MAKE) -C $(PHONE_DIR) all

# --- Delegate Mac App Build ---
mac_apps: base_libs
	@echo "Building Mac applications..."
	$(MAKE) -C $(MAC_DIR) all

# --- Build Targets ---
debug: clean_debug
	$(MAKE) BUILD_CONFIG=debug base_libs phone_apps mac_apps
	@echo "Debug Build Complete. See $(BUILD_DIR)/debug"

release: clean_release
	$(MAKE) BUILD_CONFIG=release base_libs phone_apps mac_apps
	@echo "Release Build Complete. See $(BUILD_DIR)/release"

# --- Testing ---
test_mac: base_libs
	$(MAKE) -C $(XP_DIR) test_mac
	$(MAKE) -C $(BASE_DIR) test_mac
	$(MAKE) -C $(MAC_DIR) test_mac

test_ios: base_libs
	$(MAKE) -C $(XP_DIR) test_sim
	$(MAKE) -C $(BASE_DIR) test_sim
	$(MAKE) -C $(PHONE_DIR) test_sim

clean:
	rm -rf $(BUILD_DIR)
	$(MAKE) -C $(XP_DIR) clean
	$(MAKE) -C $(BASE_DIR) clean
	$(MAKE) -C $(PHONE_DIR) clean
	$(MAKE) -C $(MAC_DIR) clean

clean_debug:
	rm -rf $(DEBUG_DIR)
	$(MAKE) -C $(XP_DIR) clean
	$(MAKE) -C $(BASE_DIR) clean
	$(MAKE) -C $(PHONE_DIR) clean
	$(MAKE) -C $(MAC_DIR) clean

clean_release:
	rm -rf $(RELEASE_DIR)
	$(MAKE) -C $(XP_DIR) clean
	$(MAKE) -C $(BASE_DIR) clean
	$(MAKE) -C $(PHONE_DIR) clean
	$(MAKE) -C $(MAC_DIR) clean
