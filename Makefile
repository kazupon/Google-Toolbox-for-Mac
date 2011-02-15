# variables
IOS_DEVICE_ROOT = /Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS4.2.sdk
IOS_SIMULATOR_ROOT = /Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator4.2.sdk
IOS_DEVICE_SDK = iphoneos4.2
IOS_SIMULATOR_SDK = iphonesimulator4.2
IOS_DEVICE_CONFIGURE = ./Configures/iPhoneDeviceBuild.xcconfig
IOS_SIMULATOR_CONFIGURE = ./Configures/iPhoneSimulatorBuild.xcconfig
PROJECT_NAME = GTMiOS.xcodeproj
FRAMEWORK_NAME = GTMiOS
TARGET_NAME = $(FRAMEWORK_NAME)
TARGET = Debug
BUILD_DIR = ./build
FRAMEWORK_VERSION_NUMBER = 1.0
FRAMEWORK_BUILD_PATH = $(BUILD_DIR)/$(TARGET)-framework
FRAMEWORK_DIR = $(FRAMEWORK_BUILD_PATH)/$(TARGET_NAME).framework
FRAMEWORK_VERSION = A
PACKAGE_NAME = $(FRAMEWORK_NAME).$(FRAMEWORK_VERSION_NUMBER).tar.gz
SOURCE_BASE_PATH = .

.PHONY: build

build:
	@echo "$(FRAMEWORK_NAME) building ..."
	xcodebuild -project $(PROJECT_NAME) -parallelizeTargets -target $(TARGET_NAME) -configuration $(TARGET) \
		-sdk $(IOS_SIMULATOR_SDK) -xcconfig $(IOS_SIMULATOR_CONFIGURE)
	xcodebuild -project $(PROJECT_NAME) -parallelizeTargets -target $(TARGET_NAME) -configuration $(TARGET) \
		-sdk $(IOS_DEVICE_SDK) -xcconfig $(IOS_DEVICE_CONFIGURE)
	@echo "... build done !!"

pack:
	@echo "$(FRAMEWORK_NAME) packaging ..."
	rm -rf $(FRAMEWORK_BUILD_PATH) 
	mkdir -p $(FRAMEWORK_DIR)
	mkdir -p $(FRAMEWORK_DIR)/Versions
	mkdir -p $(FRAMEWORK_DIR)/Versions/$(FRAMEWORK_VERSION)
	mkdir -p $(FRAMEWORK_DIR)/Versions/$(FRAMEWORK_VERSION)/Resources
	mkdir -p $(FRAMEWORK_DIR)/Versions/$(FRAMEWORK_VERSION)/Headers 
	ln -s $(FRAMEWORK_VERSION) $(FRAMEWORK_DIR)/Versions/Current
	ln -s Versions/Current/Headers $(FRAMEWORK_DIR)/Headers
	ln -s Versions/Current/Resources $(FRAMEWORK_DIR)/Resources
	ln -s Versions/Current/$(FRAMEWORK_NAME) $(FRAMEWORK_DIR)/$(FRAMEWORK_NAME)
	lipo -create build/$(TARGET)-iphoneos/lib$(FRAMEWORK_NAME).a \
		build/$(TARGET)-iphonesimulator/lib$(FRAMEWORK_NAME).a \
		-output $(FRAMEWORK_DIR)/Versions/Current/$(FRAMEWORK_NAME)
	cp $(SOURCE_BASE_PATH)/GTMiOS.h $(FRAMEWORK_DIR)/Headers/
	cp $(SOURCE_BASE_PATH)/GTMDefines.h $(FRAMEWORK_DIR)/Headers/
	cp $(SOURCE_BASE_PATH)/Foundation/GTMRegex.h $(FRAMEWORK_DIR)/Headers/
	cp $(SOURCE_BASE_PATH)/Foundation/GTMObjectSingleton.h $(FRAMEWORK_DIR)/Headers/
	cp $(SOURCE_BASE_PATH)/Foundation/GTMGarbageCollection.h $(FRAMEWORK_DIR)/Headers/
	cp $(SOURCE_BASE_PATH)/Foundation/GTMNSString+HTML.h $(FRAMEWORK_DIR)/Headers/
	cp $(SOURCE_BASE_PATH)/Foundation/GTMNSString+URLArguments.h $(FRAMEWORK_DIR)/Headers/
	cp $(SOURCE_BASE_PATH)/Foundation/GTMStringEncoding.h $(FRAMEWORK_DIR)/Headers/
	cp Resources/*.* $(FRAMEWORK_DIR)/Resources/ 
	tar -cvzf $(FRAMEWORK_BUILD_PATH)/$(PACKAGE_NAME) $(FRAMEWORK_DIR)
	@echo "... packaging done !!"

dist:
	@echo "$(FRAMEWORK_NAME) deployment ..."
	rm -rf ../../framework/$(TARGET)/$(TARGET_NAME).framework
	rm -rf ../../lib/$(TARGET)-ios/lib$(FRAMEWORK_NAME).a
	rm -rf ../../lib/$(TARGET)-ios-simulator/lib$(FRAMEWORK_NAME).a
	rm -rf ../../lib/$(TARGET)-universal/lib$(FRAMEWORK_NAME).a
	cp -R $(FRAMEWORK_DIR) ../../framework/$(TARGET)/
	cp build/$(TARGET)-iphoneos/lib$(FRAMEWORK_NAME).a ../../lib/$(TARGET)-ios/lib$(FRAMEWORK_NAME).a
	cp build/$(TARGET)-iphonesimulator/lib$(FRAMEWORK_NAME).a ../../lib/$(TARGET)-ios-simulator/lib$(FRAMEWORK_NAME).a
	cp $(FRAMEWORK_DIR)/Versions/Current/$(FRAMEWORK_NAME) ../../lib/$(TARGET)-universal/lib$(FRAMEWORK_NAME).a
	@echo "... deployment done !!"

clean:
	@echo "$(FRAMEWORK_NAME) claening ..."
	xcodebuild -project $(PROJECT_NAME) -parallelizeTargets clean
	rm -Rf $(BUILD_DIR)
	@echo "... clean done !!"

rebuild: clean build

