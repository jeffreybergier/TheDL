# Include centralized configuration
include ../common.mk

# Paths
XP_DIR = ../lib/CrossPlatform
BASE_DIR = ../lib/BaseLibrary
CURL_DIR = ../lib/CURL/ios

# Helper for Library Inclusion
LIB_INCLUDES = -I. -I$(XP_DIR) -I$(BASE_DIR) -I$(CURL_DIR)/include
CURL_LIBS = $(CURL_DIR)/lib/libcurl.a $(CURL_DIR)/lib/libssl.a $(CURL_DIR)/lib/libcrypto.a $(CURL_DIR)/lib/libssh.a $(CURL_DIR)/lib/libz.a

# Source
SRCS = ios_main.m AppDelegate.m RootViewController.m \
        TDLDownloadTableViewController.m TDLServiceListViewController.m \
        TDLURLConnectionServiceTableViewController.m TDLImageViewController.m
TEST_SRCS = tests/test_iphone_main.m

# Build Rules
.PHONY: all phone sim clean test_sim

all: phone sim

# Build for Physical Device
phone: TheDL-Phone.app
TheDL-Phone.app: $(SRCS)
	@mkdir -p $@
	$(CC) $(IOS_ARCHS) -isysroot $(IOS_SDK) -miphoneos-version-min=$(IOS_MIN) $(ARC_FLAGS) $(CLANG_WARN_FLAGS) $(IOS_FW) -g -DDEBUG \
		$(SRCS) ../build/debug/libXP_iOS.a ../build/debug/libBase_iOS.a $(CURL_LIBS) -o $@/TheDL $(LIB_INCLUDES)
	cp Info_iOS.plist $@/Info.plist

# Build for Simulator
sim: TheDL-Sim.app
TheDL-Sim.app: $(SRCS)
	@mkdir -p $@
	$(CC) $(SIM_ARCHS) -isysroot $(SIM_SDK) -mios-simulator-version-min=$(IOS_MIN) -Wl,-no_pie $(ARC_FLAGS) $(CLANG_WARN_FLAGS) $(IOS_FW) -g -DDEBUG \
		$(SRCS) ../build/debug/libXP_Sim.a ../build/debug/libBase_Sim.a $(CURL_LIBS) -o $@/TheDL $(LIB_INCLUDES)
	cp Info_iOS.plist $@/Info.plist

# Unit Tests for Simulator
test_sim:
	$(CC) $(SIM_ARCHS) -isysroot $(SIM_SDK) -mios-simulator-version-min=$(IOS_MIN) $(ARC_FLAGS) $(CLANG_WARN_FLAGS) -Wl,-no_pie \
		$(IOS_FW) $(TEST_FW) $(TEST_SRCS) \
		../build/debug/libXP_Sim.a ../build/debug/libBase_Sim.a -o test_sim_runner $(LIB_INCLUDES) \
		-F$(XCODE_PATH)/Platforms/iPhoneSimulator.platform/Developer/Library/Frameworks \
		-Xlinker -rpath -Xlinker $(XCODE_PATH)/Platforms/iPhoneSimulator.platform/Developer/Library/Frameworks
	@echo "Running iOS Simulator App Tests..."
	xcrun simctl spawn booted ./test_sim_runner

clean:
	rm -rf *.app test_sim_runner
