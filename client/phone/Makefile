# Include centralized configuration
include ../common.mk

# Paths
XP_DIR = ../lib/CrossPlatform
BASE_DIR = ../lib/BaseLibrary

# Helper for Library Inclusion
LIB_INCLUDES = -I. -I$(XP_DIR) -I$(BASE_DIR) $(CURL_INC)

# Source
SRCS = ios_main.m AppDelegate.m \
        TDLDownloadTableViewController.m TDLServiceListViewController.m \
        TDLURLConnectionServiceTableViewController.m \
        TDLCURLRequestServiceTableViewController.m \
        TDLImageViewController.m \
        TDLDownloadInfoViewController.m TDLTextViewController.m
TEST_SRCS = tests/test_iphone_main.m

# Resources
RESOURCES = $(wildcard Default*.png)

# Build Rules
.PHONY: all phone sim clean test_sim ipa

ifeq ($(HAS_OSXCROSS), 1)
all: phone ipa
else
all: phone sim ipa
endif

# Build for Physical Device
phone: TheDL-Phone.app
	@mkdir -p $(OUT_DIR)
	rm -rf $(OUT_DIR)/TheDL-Phone.app
	mv TheDL-Phone.app $(OUT_DIR)/

TheDL-Phone.app: $(SRCS) $(RESOURCES)
	@mkdir -p $@
	$(CC) $(IOS_ARCHS) -isysroot $(IOS_SDK) -miphoneos-version-min=$(IOS_MIN) -Wl,-no_pie $(ARC_FLAGS) $(CLANG_WARN_FLAGS) $(IOS_FW) $(CONFIG_FLAGS) \
		$(SRCS) $(LIB_OUT_DIR)/libXP_iOS.a $(LIB_OUT_DIR)/libBase_iOS.a $(CURL_LIBS_IOS) -o $@/TheDL $(LIB_INCLUDES)
	cp Info_iOS.plist $@/Info.plist
	@for res in $(RESOURCES); do \
		echo "Copying $$res..."; \
		cp $$res $@/; \
	done

# Packaging for Physical Device
ipa: phone
	rm -rf Payload
	mkdir -p Payload
	cp -R $(OUT_DIR)/TheDL-Phone.app Payload/
	zip -r TheDL.ipa Payload
	rm -rf Payload
	@mkdir -p $(OUT_DIR)
	mv TheDL.ipa $(OUT_DIR)/

# Build for Simulator
sim:
ifeq ($(HAS_OSXCROSS), 1)
	@echo "Warning: iOS Simulator build is not supported in Docker environment. Skipping."
else
	$(MAKE) TheDL-Sim.app
	@mkdir -p $(OUT_DIR)
	rm -rf $(OUT_DIR)/TheDL-Sim.app
	mv TheDL-Sim.app $(OUT_DIR)/
endif

TheDL-Sim.app: $(SRCS) $(RESOURCES)
	@mkdir -p $@
	$(CC) $(SIM_ARCHS) -isysroot $(SIM_SDK) $(SIM_FLAGS) -Wl,-no_pie $(ARC_FLAGS) $(CLANG_WARN_FLAGS) $(SIM_FW) $(CONFIG_FLAGS) \
		$(SRCS) $(LIB_OUT_DIR)/libXP_Sim.a $(LIB_OUT_DIR)/libBase_Sim.a $(CURL_LIBS_SIM) -o $@/TheDL $(LIB_INCLUDES)
	cp Info_iOS.plist $@/Info.plist
	@for res in $(RESOURCES); do \
		echo "Copying $$res..."; \
		cp $$res $@/; \
	done

# Unit Tests for Simulator
test_sim:
	$(CC) $(SIM_ARCHS) -isysroot $(SIM_SDK) $(SIM_FLAGS) $(ARC_FLAGS) $(CLANG_WARN_FLAGS) -Wl,-no_pie \
		$(SIM_FW) $(TEST_FW) $(TEST_SRCS) \
		$(LIB_OUT_DIR)/libXP_Sim.a $(LIB_OUT_DIR)/libBase_Sim.a $(CURL_LIBS_SIM) -o test_sim_runner $(LIB_INCLUDES) \
		-F$(XCTEST_FRAMEWORK_DIR_SIM) \
		-Xlinker -rpath -Xlinker $(XCTEST_FRAMEWORK_DIR_SIM)
	@echo "Running iOS Simulator App Tests..."
	xcrun simctl spawn booted ./test_sim_runner

clean:
	rm -rf *.app test_sim_runner *.o *.ipa
