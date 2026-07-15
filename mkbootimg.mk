LOCAL_PATH := $(call my-dir)

INSTALLED_KERNEL_TARGET := $(TARGET_PREBUILT_KERNEL)

# Override recovery ramdisk to NOT depend on system root
recovery_ramdisk := $(PRODUCT_OUT)/ramdisk-recovery.img
recovery_ramdisk_source := $(TARGET_RECOVERY_ROOT_OUT)

$(recovery_ramdisk): $(INTERNAL_RECOVERY_FILES)
	@echo "----- Building recovery ramdisk from $(recovery_ramdisk_source) -----"
	$(hide) $(MKBOOTIMG) --kernel $(INSTALLED_KERNEL_TARGET) --ramdisk "" --cmdline "" --base $(BOARD_KERNEL_BASE) --pagesize $(BOARD_KERNEL_PAGESIZE) -o /dev/null 2>/dev/null || true
	$(hide) cd $(recovery_ramdisk_source) && find . | cpio --create --format=newc | gzip -9 > $@

$(INSTALLED_BOOTIMAGE_TARGET): $(MKBOOTIMG) $(INTERNAL_BOOTIMAGE_FILES)
	$(call pretty,"Target boot image: $@")
	$(hide) $(MKBOOTIMG) $(INTERNAL_BOOTIMAGE_ARGS) $(INTERNAL_MKBOOTIMG_VERSION_ARGS) $(BOARD_MKBOOTIMG_ARGS) --output $@
	$(hide) echo -n "SEANDROIDENFORCE" >> $@
	$(hide) $(call assert-max-image-size,$@,$(BOARD_BOOTIMAGE_PARTITION_SIZE),raw)

FLASH_IMAGE_TARGET ?= $(PRODUCT_OUT)/recovery.tar

$(INSTALLED_RECOVERYIMAGE_TARGET): $(MKBOOTIMG) $(recovery_ramdisk)
	@echo "----- Making recovery image ------"
	$(hide) $(MKBOOTIMG) $(INTERNAL_RECOVERYIMAGE_ARGS) $(INTERNAL_MKBOOTIMG_VERSION_ARGS) $(BOARD_MKBOOTIMG_ARGS) --output $@ --id > $(RECOVERYIMAGE_ID_FILE)
	$(hide) echo -n "SEANDROIDENFORCE" >> $@
	$(hide) $(call assert-max-image-size,$@,$(BOARD_RECOVERYIMAGE_PARTITION_SIZE),raw)
	@echo "Made recovery image: $@"
	$(hide) tar -C $(PRODUCT_OUT) -H ustar -c recovery.img > $(FLASH_IMAGE_TARGET)
	@echo "Made Odin flashable recovery tar: $(FLASH_IMAGE_TARGET)"
