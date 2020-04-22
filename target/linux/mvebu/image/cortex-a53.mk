ifeq ($(SUBTARGET),cortexa53)

define Device/globalscale_espressobin
  $(call Device/Default-arm64)
  DEVICE_TITLE := ESPRESSObin (Marvell Armada 3700 Community Board)
  DEVICE_DTS := armada-3720-espressobin
  BOOT_SCRIPT := espressobin
endef
TARGET_DEVICES += globalscale_espressobin

define Device/globalscale_espressobin-emmc
  $(call Device/Default-arm64)
  DEVICE_TITLE := ESPRESSObin eMMC (Marvell Armada 3700 Community Board)
  DEVICE_DTS := armada-3720-espressobin-emmc
  BOOT_SCRIPT := espressobin
endef
TARGET_DEVICES += globalscale_espressobin-emmc

define Device/globalscale_espressobin-v7
  $(call Device/Default-arm64)
  DEVICE_TITLE := ESPRESSObin V7 (Marvell Armada 3700 Community Board)
  DEVICE_DTS := armada-3720-espressobin-v7
  BOOT_SCRIPT := espressobin
endef
TARGET_DEVICES += globalscale_espressobin-v7

define Device/globalscale_espressobin-v7-emmc
  $(call Device/Default-arm64)
  DEVICE_TITLE := ESPRESSObin V7 eMMC (Marvell Armada 3700 Community Board)
  DEVICE_DTS := armada-3720-espressobin-v7-emmc
  BOOT_SCRIPT := espressobin
endef
TARGET_DEVICES += globalscale_espressobin-v7-emmc

define Device/cznic-mox
  KERNEL_NAME := Image dtbs
  KERNEL := kernel-bin
  DEVICE_TITLE := MOX (CZ.NICs Marvell Armada 3720 Based Board)
  DEVICE_PACKAGES := kmod-usb2 kmod-gpio-button-hotplug
  DEVICE_DTS := armada-3720-turris-mox
  DTS_DIR := $(DTS_DIR)/marvell
  SUPPORTED_DEVICES := cznic,mox
endef
TARGET_DEVICES += cznic-mox

define Device/marvell_armada-3720-db
  $(call Device/Default-arm64)
  DEVICE_TITLE := Marvell Armada 3720 Development Board DB-88F3720-DDR3
  DEVICE_DTS := armada-3720-db
endef
TARGET_DEVICES += marvell_armada-3720-db

endif
