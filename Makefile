TARGET := iphone:clang:latest:7.0
INSTALL_TARGET_PROCESSES = SpringBoard

ARCHS = arm64

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = HanPlug

HanPlug_FILES = Tweak.x
HanPlug_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
