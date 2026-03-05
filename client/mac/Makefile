# Include centralized configuration
include ../common.mk

# Paths
XP_DIR = ../lib/CrossPlatform
BASE_DIR = ../lib/BaseLibrary

# Helper for Library Inclusion
LIB_INCLUDES = -I. -I$(XP_DIR) -I$(BASE_DIR)

# Source
SRCS = mac_main.m AppDelegate.m
TEST_SRCS = tests/test_mac_main.m

# Build Rules
.PHONY: all mac classic clean test_mac

all: mac classic

# Modern Mac Build (10.7+)
mac: TheDL-Mac.app
TheDL-Mac.app: $(SRCS)
	@mkdir -p $@/Contents/MacOS
	$(CC) $(MAC_MODERN_ARCHS) -isysroot $(MAC_MODERN_SDK) -mmacosx-version-min=$(MAC_MODERN_MIN) $(ARC_FLAGS) $(CLANG_WARN_FLAGS) $(MAC_FW) -g -DDEBUG \
		$(SRCS) ../build/debug/libXP_Mac.a ../build/debug/libBase_Mac.a -o $@/Contents/MacOS/TheDL $(LIB_INCLUDES)
	cp Info_Mac.plist $@/Contents/Info.plist

# Classic Mac Build (10.4-10.6)
classic: TheDL-Classic.app
TheDL-Classic.app: $(SRCS)
	@mkdir -p $@/Contents/MacOS
	$(NEKO_CC) $(MAC_NEKO_ARCHS) -isysroot $(MAC_NEKO_SDK) -mmacosx-version-min=$(MAC_NEKO_MIN) $(NEKO_FLAGS) -g -DDEBUG \
		$(SRCS) ../build/debug/libXP_Neko.a ../build/debug/libBase_Neko.a -o "$@/Contents/MacOS/TheDL Classic" $(LIB_INCLUDES)
	cp Info_Classic.plist $@/Contents/Info.plist

# Unit Tests for Mac
test_mac:
	$(CC) $(MAC_MODERN_ARCHS) -isysroot $(MAC_MODERN_SDK) -mmacosx-version-min=$(MAC_MODERN_MIN) $(ARC_FLAGS) $(CLANG_WARN_FLAGS) \
		$(MAC_FW) $(TEST_FW) $(TEST_SRCS) \
		../build/debug/libXP_Mac.a ../build/debug/libBase_Mac.a -o test_runner $(LIB_INCLUDES) \
		-F$(XCODE_PATH)/Platforms/MacOSX.platform/Developer/Library/Frameworks \
		-Xlinker -rpath -Xlinker $(XCODE_PATH)/Platforms/MacOSX.platform/Developer/Library/Frameworks
	@echo "Running Mac App Tests..."
	./test_runner

clean:
	rm -rf *.app test_runner
