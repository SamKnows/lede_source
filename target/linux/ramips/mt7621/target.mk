#
# Copyright (C) 2009 OpenWrt.org
#

SUBTARGET:=mt7621
BOARDNAME:=MT7621 based boards
DEVICE_TYPE:=samknows
FEATURES+=nand ramdisk rtc usb
CPU_TYPE:=1004kc

DEFAULT_PACKAGES += kmod-mt76

KERNEL_PATCHVER:=4.4

define Target/Description
	Build firmware images for Ralink MT7621 based boards.
endef

