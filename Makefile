ARCHS = arm64
TARGET := iphone:clang:latest:15.0
INSTALL_TARGET_PROCESSES = WeChat

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = WeChatNoAds74

WeChatNoAds74_FILES = Tweak.x
WeChatNoAds74_CFLAGS = -fobjc-arc -Wno-unused-variable -Wno-deprecated-declarations
WeChatNoAds74_FRAMEWORKS = UIKit Foundation

include $(THEOS_MAKE_PATH)/tweak.mk
