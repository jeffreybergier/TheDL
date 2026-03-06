# Include centralized configuration
include ../../common.mk

# Paths
CURL_DIR = ../CURL/ios
CURL_INC = -I$(CURL_DIR)/include
CURL_LIBS = $(CURL_DIR)/lib/libcurl.a $(CURL_DIR)/lib/libssl.a $(CURL_DIR)/lib/libcrypto.a $(CURL_DIR)/lib/libssh.a $(CURL_DIR)/lib/libz.a

# Source
SRCS = XPObject.m CrossPlatform.m
TEST_SRCS = tests/XPObjectTests.m

# Build Rules
.PHONY: all ios sim mac clean test_mac test_sim

all: ios sim mac

test: test_mac test_sim

ios: libXP_iOS.a
sim: libXP_Sim.a
mac: libXP_Mac.a

libXP_iOS.a: $(SRCS)
	@objs=""; for src in $(SRCS); do \
		obj=`basename $$src .m`_iOS.o; \
		$(CC) $(IOS_ARCHS) -isysroot $(IOS_SDK) -miphoneos-version-min=$(IOS_MIN) $(ARC_FLAGS) $(CLANG_WARN_FLAGS) $(CURL_INC) -g -DDEBUG -c $$src -o $$obj; \
		objs="$$objs $$obj"; \
	done; \
	libtool -static -o $@ $$objs

libXP_Sim.a: $(SRCS)
	@objs=""; for src in $(SRCS); do \
		obj=`basename $$src .m`_Sim.o; \
		$(CC) $(SIM_ARCHS) -isysroot $(SIM_SDK) -mios-simulator-version-min=$(IOS_MIN) $(ARC_FLAGS) $(CLANG_WARN_FLAGS) $(CURL_INC) -g -DDEBUG -c $$src -o $$obj; \
		objs="$$objs $$obj"; \
	done; \
	libtool -static -o $@ $$objs

libXP_Mac.a: $(SRCS)
	@objs=""; for src in $(SRCS); do \
		obj=`basename $$src .m`_Mac.o; \
		$(CC) $(MAC_ARCHS) -isysroot $(MAC_SDK) -mmacosx-version-min=$(MAC_MIN) $(ARC_FLAGS) $(CLANG_WARN_FLAGS) -g -DDEBUG -c $$src -o $$obj; \
		objs="$$objs $$obj"; \
	done; \
	libtool -static -o $@ $$objs

# Tests
test_mac: libXP_Mac.a
	$(CC) $(MAC_ARCHS) -isysroot $(MAC_SDK) -mmacosx-version-min=$(MAC_MIN) $(ARC_FLAGS) $(CLANG_WARN_FLAGS) \
		-framework Foundation -framework XCTest \
		../../mac/tests/test_mac_main.m $(TEST_SRCS) libXP_Mac.a -o test_mac_runner -I. \
		-F$(XCODE_PATH)/Platforms/MacOSX.platform/Developer/Library/Frameworks \
		-Xlinker -rpath -Xlinker $(XCODE_PATH)/Platforms/MacOSX.platform/Developer/Library/Frameworks
	./test_mac_runner

test_sim: libXP_Sim.a
	$(CC) $(SIM_ARCHS) -isysroot $(SIM_SDK) -mios-simulator-version-min=$(IOS_MIN) $(ARC_FLAGS) $(CLANG_WARN_FLAGS) -Wl,-no_pie \
		-framework Foundation -framework XCTest \
		../../phone/tests/test_iphone_main.m $(TEST_SRCS) libXP_Sim.a $(CURL_LIBS) -o test_sim_runner -I. $(CURL_INC) \
		-F$(XCODE_PATH)/Platforms/iPhoneSimulator.platform/Developer/Library/Frameworks \
		-Xlinker -rpath -Xlinker $(XCODE_PATH)/Platforms/iPhoneSimulator.platform/Developer/Library/Frameworks
	xcrun simctl spawn booted ./test_sim_runner


clean:
	rm -f *.o *.a test_mac_runner test_sim_runner
