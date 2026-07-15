LOCAL_PATH := $(call my-dir)

my_recovery_ramdisk := $(PRODUCT_OUT)/my-ramdisk-recovery.img

# Copy TWRP resource files to recovery root
my_res_stamp := $(TARGET_RECOVERY_ROOT_OUT)/res/.res_copied
$(my_res_stamp):
	mkdir -p $(TARGET_RECOVERY_ROOT_OUT)/res
	cp -fr bootable/recovery/gui/devices/common/res/* $(TARGET_RECOVERY_ROOT_OUT)/res/ 2>/dev/null || true
	cp -fr bootable/recovery/gui/devices/1080x1920/res/* $(TARGET_RECOVERY_ROOT_OUT)/res/ 2>/dev/null || true
	touch $@

$(my_recovery_ramdisk): $(my_res_stamp)
	mkdir -p $(dir $@)
	cd $(TARGET_RECOVERY_ROOT_OUT) && find . | cpio -o -H newc | gzip -9 > $(abspath $@)

$(INSTALLED_BOOTIMAGE_TARGET): $(MKBOOTIMG) $(INTERNAL_BOOTIMAGE_FILES)
	$(call pretty,"Target boot image: $@")
	$(hide) $(MKBOOTIMG) $(INTERNAL_BOOTIMAGE_ARGS) $(INTERNAL_MKBOOTIMG_VERSION_ARGS) $(BOARD_MKBOOTIMG_ARGS) --output $@
	$(hide) echo -n "SEANDROIDENFORCE" >> $@
	$(hide) $(call assert-max-image-size,$@,$(BOARD_BOOTIMAGE_PARTITION_SIZE),raw)

FLASH_IMAGE_TARGET ?= $(PRODUCT_OUT)/recovery.tar

$(INSTALLED_RECOVERYIMAGE_TARGET): $(MKBOOTIMG) $(INSTALLED_KERNEL_TARGET) $(my_recovery_ramdisk)
	@echo "----- Making recovery image ------"
	$(hide) $(MKBOOTIMG) --kernel $(INSTALLED_KERNEL_TARGET) --ramdisk $(my_recovery_ramdisk) --base $(BOARD_KERNEL_BASE) --pagesize $(BOARD_KERNEL_PAGESIZE) $(INTERNAL_MKBOOTIMG_VERSION_ARGS) $(BOARD_MKBOOTIMG_ARGS) --output $@
	$(hide) echo -n "SEANDROIDENFORCE" >> $@
	$(hide) $(call assert-max-image-size,$@,$(BOARD_RECOVERYIMAGE_PARTITION_SIZE),raw)
	@echo "Made recovery image: $@"
	$(hide) tar -C $(PRODUCT_OUT) -cf $(FLASH_IMAGE_TARGET) recovery.img
	@echo "Made Odin flashable recovery tar: $(FLASH_IMAGE_TARGET)"
