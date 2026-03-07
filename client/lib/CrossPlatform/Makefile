# Include centralized configuration
include ../../common.mk

# Helper for Library Inclusion
LIB_INCLUDES = -I. $(CURL_INC)

# Source
SRCS = XPObject.m CrossPlatform.m XPCURLRequest.m
TEST_SRCS = tests/XPObjectTests.m

# Build Rules
.PHONY: all ios sim mac clean test_mac test_sim

ifeq ($(HAS_OSXCROSS), 1)
all: ios mac
else
all: ios sim mac
endif

test: test_mac test_sim

ios: $(LIB_OUT_DIR)/libXP_iOS.a
sim:
ifeq ($(HAS_OSXCROSS), 1)
	@echo "Skipping sim in Docker"
else
	$(MAKE) $(LIB_OUT_DIR)/libXP_Sim.a
endif

mac: $(LIB_OUT_DIR)/libXP_Mac.a

$(LIB_OUT_DIR)/libXP_iOS.a: $(SRCS)
	@mkdir -p $(LIB_OUT_DIR)
	@objs=""; for src in $(SRCS); do \
		obj=`basename $$src .m`_iOS.o; \
		$(CC) $(IOS_ARCHS) -isysroot $(IOS_SDK) -miphoneos-version-min=$(IOS_MIN) $(ARC_FLAGS) $(CLANG_WARN_FLAGS) $(LIB_INCLUDES) $(CONFIG_FLAGS) -c $$src -o $$obj; \
		objs="$$objs $$obj"; \
	done; \
	$(LIBTOOL) -static -o $@ $$objs; \
	rm -f $$objs

$(LIB_OUT_DIR)/libXP_Sim.a: $(SRCS)
	@mkdir -p $(LIB_OUT_DIR)
	@objs=""; for src in $(SRCS); do \
		obj=`basename $$src .m`_Sim.o; \
		$(CC) $(SIM_ARCHS) -isysroot $(SIM_SDK) $(SIM_FLAGS) $(ARC_FLAGS) $(CLANG_WARN_FLAGS) $(LIB_INCLUDES) $(CONFIG_FLAGS) -c $$src -o $$obj; \
		objs="$$objs $$obj"; \
	done; \
	$(LIBTOOL) -static -o $@ $$objs; \
	rm -f $$objs

$(LIB_OUT_DIR)/libXP_Mac.a: $(SRCS)
	@mkdir -p $(LIB_OUT_DIR)
	@objs=""; for src in $(SRCS); do \
		obj=`basename $$src .m`_Mac.o; \
		$(CC) $(MAC_ARCHS) -isysroot $(MAC_SDK) -mmacosx-version-min=$(MAC_MIN) $(ARC_FLAGS) $(CLANG_WARN_FLAGS) $(LIB_INCLUDES) $(CONFIG_FLAGS) -c $$src -o $$obj; \
		objs="$$objs $$obj"; \
	done; \
	$(LIBTOOL) -static -o $@ $$objs; \
	rm -f $$objs

# Tests
test_mac: $(LIB_OUT_DIR)/libXP_Mac.a
	$(CC) $(MAC_ARCHS) -isysroot $(MAC_SDK) -mmacosx-version-min=$(MAC_MIN) $(ARC_FLAGS) $(CLANG_WARN_FLAGS) \
		-framework Foundation -framework XCTest \
		../../mac/tests/test_mac_main.m $(TEST_SRCS) $(LIB_OUT_DIR)/libXP_Mac.a $(CURL_LIBS_MAC) -o test_mac_runner -I. \
		-F$(XCTEST_FRAMEWORK_DIR_MAC) \
		-Xlinker -rpath -Xlinker $(XCTEST_FRAMEWORK_DIR_MAC)
	./test_mac_runner

test_sim: $(LIB_OUT_DIR)/libXP_Sim.a
	$(CC) $(SIM_ARCHS) -isysroot $(SIM_SDK) $(SIM_FLAGS) $(ARC_FLAGS) $(CLANG_WARN_FLAGS) -Wl,-no_pie \
		$(SIM_FW) $(TEST_FW) $(TEST_SRCS) \
		$(LIB_OUT_DIR)/libXP_Sim.a $(CURL_LIBS_SIM) -o test_sim_runner -I. \
		-F$(XCTEST_FRAMEWORK_DIR_SIM) \
		-Xlinker -rpath -Xlinker $(XCTEST_FRAMEWORK_DIR_SIM)
	xcrun simctl spawn booted ./test_sim_runner



clean:
	rm -f *.o *.a test_mac_runner test_sim_runner
