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
	TDLURLConnectionService.m TDLCURLRequestService.m TDLServiceManager.m

TEST_SRCS = tests/TDLObjectTests.m tests/TDLDownloadTests.m tests/TDLURLConnectionServiceTests.m

# Build Rules
.PHONY: all ios sim mac clean test_mac test_sim

ifeq ($(HAS_OSXCROSS), 1)
all: ios mac
else
all: ios sim mac
endif

test: test_mac test_sim

ios: $(LIB_OUT_DIR)/libBase_iOS.a
sim: $(LIB_OUT_DIR)/libBase_Sim.a
mac: $(LIB_OUT_DIR)/libBase_Mac.a

$(LIB_OUT_DIR)/libBase_iOS.a: $(SRCS)
	@mkdir -p $(LIB_OUT_DIR)
	@objs=""; for src in $(SRCS); do \
		obj=`basename $$src .m`_iOS.o; \
		$(CC) $(IOS_ARCHS) -isysroot $(IOS_SDK) -miphoneos-version-min=$(IOS_MIN) $(ARC_FLAGS) $(CLANG_WARN_FLAGS) $(CONFIG_FLAGS) -c $$src -o $$obj $(LIB_INCLUDES); \
		objs="$$objs $$obj"; \
	done; \
	$(LIBTOOL) -static -o $@ $$objs; \
	rm -f $$objs

$(LIB_OUT_DIR)/libBase_Sim.a: $(SRCS)
	@mkdir -p $(LIB_OUT_DIR)
	@objs=""; for src in $(SRCS); do \
		obj=`basename $$src .m`_Sim.o; \
		$(CC) $(SIM_ARCHS) -isysroot $(SIM_SDK) $(SIM_FLAGS) $(ARC_FLAGS) $(CLANG_WARN_FLAGS) $(CONFIG_FLAGS) -c $$src -o $$obj $(LIB_INCLUDES); \
		objs="$$objs $$obj"; \
	done; \
	$(LIBTOOL) -static -o $@ $$objs; \
	rm -f $$objs

$(LIB_OUT_DIR)/libBase_Mac.a: $(SRCS)
	@mkdir -p $(LIB_OUT_DIR)
	@objs=""; for src in $(SRCS); do \
		obj=`basename $$src .m`_Mac.o; \
		$(CC) $(MAC_ARCHS) -isysroot $(MAC_SDK) -mmacosx-version-min=$(MAC_MIN) $(ARC_FLAGS) $(CLANG_WARN_FLAGS) $(CONFIG_FLAGS) -c $$src -o $$obj $(LIB_INCLUDES); \
		objs="$$objs $$obj"; \
	done; \
	$(LIBTOOL) -static -o $@ $$objs; \
	rm -f $$objs

# Tests
test_mac: $(LIB_OUT_DIR)/libBase_Mac.a
	$(CC) $(MAC_ARCHS) -isysroot $(MAC_SDK) -mmacosx-version-min=$(MAC_MIN) $(ARC_FLAGS) $(CLANG_WARN_FLAGS) \
		-framework Foundation -framework CoreData -framework AppKit -framework XCTest \
		../../mac/tests/test_mac_main.m $(TEST_SRCS) $(LIB_OUT_DIR)/libBase_Mac.a $(LIB_OUT_DIR)/libXP_Mac.a -o test_mac_runner $(LIB_INCLUDES) \
		-F$(XCTEST_FRAMEWORK_DIR_MAC) \
		-Xlinker -rpath -Xlinker $(XCTEST_FRAMEWORK_DIR_MAC)
	./test_mac_runner

test_sim: $(LIB_OUT_DIR)/libBase_Sim.a
	$(CC) $(SIM_ARCHS) -isysroot $(SIM_SDK) $(SIM_FLAGS) $(ARC_FLAGS) $(CLANG_WARN_FLAGS) -Wl,-no_pie \
		$(SIM_FW) $(TEST_FW) $(TEST_SRCS) \
		$(LIB_OUT_DIR)/libBase_Sim.a $(LIB_OUT_DIR)/libXP_Sim.a -o test_sim_runner $(LIB_INCLUDES) \
		-F$(XCTEST_FRAMEWORK_DIR_SIM) \
		-Xlinker -rpath -Xlinker $(XCTEST_FRAMEWORK_DIR_SIM)
	xcrun simctl spawn booted ./test_sim_runner

clean:
	rm -f *.o *.a test_mac_runner test_sim_runner
