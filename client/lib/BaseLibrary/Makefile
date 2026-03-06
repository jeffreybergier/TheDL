# Include centralized configuration
include ../../common.mk

# Source Directories
XP_DIR = ../CrossPlatform
CURL_DIR = ../CURL/ios
CURL_INC = -I$(CURL_DIR)/include
CURL_LIBS = $(CURL_DIR)/lib/libcurl.a $(CURL_DIR)/lib/libssl.a $(CURL_DIR)/lib/libcrypto.a $(CURL_DIR)/lib/libssh.a $(CURL_DIR)/lib/libz.a

# Helper for Library Inclusion
LIB_INCLUDES = -I. -I$(XP_DIR)

# Source
SRCS = TDLObject.m TDLDownload.m TDLDownloadList.m \
	TDLService.m TDLDownloadTask.m \
	TDLURLConnectionService.m TDLServiceManager.m

TEST_SRCS = tests/TDLObjectTests.m tests/TDLDownloadTests.m tests/TDLURLConnectionServiceTests.m

# Build Rules
.PHONY: all ios sim mac clean test_mac test_sim

all: ios sim mac

test: test_mac test_sim

ios: libBase_iOS.a
sim: libBase_Sim.a
mac: libBase_Mac.a

libBase_iOS.a: $(SRCS)
	@objs=""; for src in $(SRCS); do \
		obj=`basename $$src .m`_iOS.o; \
		$(CC) $(IOS_ARCHS) -isysroot $(IOS_SDK) -miphoneos-version-min=$(IOS_MIN) $(ARC_FLAGS) $(CLANG_WARN_FLAGS) -g -DDEBUG -c $$src -o $$obj $(LIB_INCLUDES); \
		objs="$$objs $$obj"; \
	done; \
	libtool -static -o $@ $$objs

libBase_Sim.a: $(SRCS)
	@objs=""; for src in $(SRCS); do \
		obj=`basename $$src .m`_Sim.o; \
		$(CC) $(SIM_ARCHS) -isysroot $(SIM_SDK) -mios-simulator-version-min=$(IOS_MIN) $(ARC_FLAGS) $(CLANG_WARN_FLAGS) -g -DDEBUG -c $$src -o $$obj $(LIB_INCLUDES); \
		objs="$$objs $$obj"; \
	done; \
	libtool -static -o $@ $$objs

libBase_Mac.a: $(SRCS)
	@objs=""; for src in $(SRCS); do \
		obj=`basename $$src .m`_Mac.o; \
		$(CC) $(MAC_ARCHS) -isysroot $(MAC_SDK) -mmacosx-version-min=$(MAC_MIN) $(ARC_FLAGS) $(CLANG_WARN_FLAGS) -g -DDEBUG -c $$src -o $$obj $(LIB_INCLUDES); \
		objs="$$objs $$obj"; \
	done; \
	libtool -static -o $@ $$objs

# Tests
test_mac: libBase_Mac.a
	$(CC) $(MAC_ARCHS) -isysroot $(MAC_SDK) -mmacosx-version-min=$(MAC_MIN) $(ARC_FLAGS) $(CLANG_WARN_FLAGS) \
		-framework Foundation -framework CoreData -framework AppKit -framework XCTest \
		../../mac/tests/test_mac_main.m $(TEST_SRCS) libBase_Mac.a $(XP_DIR)/libXP_Mac.a -o test_mac_runner $(LIB_INCLUDES) \
		-F$(XCODE_PATH)/Platforms/MacOSX.platform/Developer/Library/Frameworks \
		-Xlinker -rpath -Xlinker $(XCODE_PATH)/Platforms/MacOSX.platform/Developer/Library/Frameworks
	./test_mac_runner

test_sim: libBase_Sim.a
	$(CC) $(SIM_ARCHS) -isysroot $(SIM_SDK) -mios-simulator-version-min=$(IOS_MIN) $(ARC_FLAGS) $(CLANG_WARN_FLAGS) -Wl,-no_pie \
		-framework Foundation -framework CoreData -framework UIKit -framework XCTest \
		../../phone/tests/test_iphone_main.m $(TEST_SRCS) libBase_Sim.a $(XP_DIR)/libXP_Sim.a $(CURL_LIBS) -o test_sim_runner $(LIB_INCLUDES) $(CURL_INC) \
		-F$(XCODE_PATH)/Platforms/iPhoneSimulator.platform/Developer/Library/Frameworks \
		-Xlinker -rpath -Xlinker $(XCODE_PATH)/Platforms/iPhoneSimulator.platform/Developer/Library/Frameworks
	xcrun simctl spawn booted ./test_sim_runner

clean:
	rm -f *.o *.a test_mac_runner test_sim_runner
