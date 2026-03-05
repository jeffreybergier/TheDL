# Include centralized configuration
include ../../common.mk

# Source
SRCS = XPObject.m
TEST_SRCS = tests/XPObjectTests.m

# Build Rules
.PHONY: all ios sim mac neko clean test_mac test_sim

all: ios sim mac neko

test: test_mac test_sim

ios: libXP_iOS.a
sim: libXP_Sim.a
mac: libXP_Mac.a
neko: libXP_Neko.a

libXP_iOS.a: $(SRCS)
	$(CC) $(IOS_ARCHS) -isysroot $(IOS_SDK) -miphoneos-version-min=$(IOS_MIN) $(ARC_FLAGS) $(CLANG_WARN_FLAGS) -g -DDEBUG -c $< -o XP_iOS.o
	libtool -static -o $@ XP_iOS.o

libXP_Sim.a: $(SRCS)
	$(CC) $(SIM_ARCHS) -isysroot $(SIM_SDK) -mios-simulator-version-min=$(IOS_MIN) $(ARC_FLAGS) $(CLANG_WARN_FLAGS) -g -DDEBUG -c $< -o XP_Sim.o
	libtool -static -o $@ XP_Sim.o

libXP_Mac.a: $(SRCS)
	$(CC) $(MAC_MODERN_ARCHS) -isysroot $(MAC_MODERN_SDK) -mmacosx-version-min=$(MAC_MODERN_MIN) $(ARC_FLAGS) $(CLANG_WARN_FLAGS) -g -DDEBUG -c $< -o XP_Mac.o
	libtool -static -o $@ XP_Mac.o

libXP_Neko.a: $(SRCS)
	$(NEKO_CC) $(MAC_NEKO_ARCHS) -isysroot $(MAC_NEKO_SDK) -mmacosx-version-min=$(MAC_NEKO_MIN) $(NEKO_FLAGS) -g -DDEBUG -c $< -o XP_Neko.o
	libtool -static -o $@ XP_Neko.o

# Tests
test_mac: libXP_Mac.a
	$(CC) $(MAC_MODERN_ARCHS) -isysroot $(MAC_MODERN_SDK) -mmacosx-version-min=$(MAC_MODERN_MIN) $(ARC_FLAGS) $(CLANG_WARN_FLAGS) \
		-framework Foundation -framework XCTest \
		../../tests/test_mac_main.m $(TEST_SRCS) libXP_Mac.a -o test_mac_runner -I. \
		-F$(XCODE_PATH)/Platforms/MacOSX.platform/Developer/Library/Frameworks \
		-Xlinker -rpath -Xlinker $(XCODE_PATH)/Platforms/MacOSX.platform/Developer/Library/Frameworks
	./test_mac_runner

test_sim: libXP_Sim.a
	$(CC) $(SIM_ARCHS) -isysroot $(SIM_SDK) -mios-simulator-version-min=$(IOS_MIN) $(ARC_FLAGS) $(CLANG_WARN_FLAGS) -Wl,-no_pie \
		-framework Foundation -framework UIKit -framework XCTest \
		../../tests/test_iphone_main.m $(TEST_SRCS) libXP_Sim.a -o test_sim_runner -I. \
		-F$(XCODE_PATH)/Platforms/iPhoneSimulator.platform/Developer/Library/Frameworks \
		-Xlinker -rpath -Xlinker $(XCODE_PATH)/Platforms/iPhoneSimulator.platform/Developer/Library/Frameworks
	xcrun simctl spawn booted ./test_sim_runner

clean:
	rm -f *.o *.a test_mac_runner test_sim_runner
