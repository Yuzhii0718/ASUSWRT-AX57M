#*
# GPL-2.0-OR-LATER
#
# Yuzhii0718 <admin@yuzhii0718.eu.org>
#
# Partition layout: 1024k(bl2), 512k(u-boot-env), 2048k(Factory), 2048k(fip), -(ubi)
#

# O:	/PATH/TO/OUTPUT_DIRECTORY
# FW_FN:	Firmware filename

ifeq ($(SRCBASE),)
	export SRCBASE := $(shell (cd ../../ && pwd))
endif

-include ../../.config
-include ../../../src/router/common.mak

ifeq ($(and $(O),$(FW_FN)),)
$(error O or FW_FN is not defined)
endif

ifeq ($(BUILD_NAME),RT-8103AX)
UBOOT_VER = 3000
UBOOT_IMG = u-boot_nand_YYYYMMDD_v$(UBOOT_VER)_rt-8103ax_ddr3.img
HW_ID = A
HW_VER = 1.0
FLASH_SIZE = 0x8000000
else
$(error Define your model!!)
endif

FW_FILE = $(O)/$(FW_FN)
BOOT_FILE = $(BUILD_NAME)_$(UBOOT_VER).U-BOOT.bin
BIN_FILE = $(addsuffix .FLASH,$(basename $(FW_FN)))
UBI_FILE = $(addsuffix .UBI_DEV.bin,$(basename $(FW_FN)))

$(info FW $(FW_FILE))
$(info BOOT $(BOOT_FILE))
$(info BIN $(BIN_FILE).bin)
$(info UBI $(UBI_FILE))

# Tools
MD		= ../modifyData
MK_FAC		= ../mk_factory_image
DUMPIMAGE	= ../dumpimage

# Flash partition layout
# offset	length		name
# ==========================================================
# 0x00000000	0x00100000	bl2         (1024K)
# 0x00100000	0x00080000	u-boot-env  (512K, hidden)
# 0x00180000	0x00200000	Factory     (2048K, raw MTD)
# 0x00380000	0x00200000	fip         (2048K)
# 0x00580000	-		ubi

BOOTLOADER	= $(BUILD_NAME).U-BOOT
BOOTLOADER_BASE	= 0x00000000
FACTORY_BIN	= $(BUILD_NAME).FACTORY
FACTORY_BASE	= 0x00180000
UBI_DEV		= UBI_DEV
UBI_DEV_BASE	= 0x00580000
UBI_START	= $(shell echo "$$(($(UBI_DEV_BASE))) /(128 * 1024)"|bc) # Start of UBI_DEV (block in flash)
FLASH_SIZE_DEC	= $(shell echo "ibase=16;$(shell echo $(FLASH_SIZE)|sed -e s,0x,,)"|bc)	# Flash size in decimal.
BL2		= bl2.img
FIP		= fip.bin

$(info BOOTLOADER $(BOOTLOADER))
$(info FACTORY $(FACTORY_BIN))

LEB_SIZE		= 124
NVRAM_SIZE_IN_LEBS	= 1
FACTORY_SIZE_IN_BYTES	= 0x200000

NVRAM_SIZE_KB	= $(shell expr $(NVRAM_SIZE_IN_LEBS) \* $(LEB_SIZE))
# FIT_SIZE_KB is computed dynamically from the FW image
UBI_SIZE_KB	= $(shell expr \( $(FLASH_SIZE_DEC) - $(UBI_DEV_BASE) \) / 1024)
# JFFS_SIZE_KB: remaining UBI space after FIT + NVRAM, minus ~5% overhead for UBI metadata & bad blocks
JFFS_SIZE_KB	= $(shell expr $(UBI_SIZE_KB) - $(FIT_SIZE_KB) - $(NVRAM_SIZE_KB) - $(shell expr $(UBI_SIZE_KB) / 20))

# Dummy Factory (raw binary, placed in separate MTD partition)
FACTORY			= $(FACTORY_BIN)
FACTORY_POSTFIX		= $(addsuffix .postfix,$(FACTORY))

# Print difference between file1 and file2
# $(1): file1
# $(2): file2
define compare_binary_file
	echo "$(1) v.s. $(2)"; \
	cmp -l $(1) $(2) | awk '{printf "%08X %02X %02X\n", $$1 - 1, strtonum(0$$2), strtonum(0$$3)}';
endef

all: tools clean image $(BUILD_NAME)_PartitionTable.mbn $(BUILD_NAME)_PartitionTable.def

tools:
	$(MAKE) -C ..

# Data I/O NAND Flash programmer (Minato M416, .mbn format)
$(BUILD_NAME)_PartitionTable.mbn: UDLEN=$(shell echo "(`stat -c %s $(UBI_DEV)` + 131072 - 1)/131072"|bc)
$(BUILD_NAME)_PartitionTable.mbn: LAST_BLK=$(shell echo "($(FLASH_SIZE_DEC) + 131072 - 1)/131072 - 1"|bc)
$(BUILD_NAME)_PartitionTable.mbn: BL2_LEN=$(shell echo "(`stat -c %s $(BL2)` + 131072 - 1)/131072"|bc)
$(BUILD_NAME)_PartitionTable.mbn: FIP_LEN=$(shell echo "(`stat -c %s $(FIP)` + 131072 - 1)/131072"|bc)
$(BUILD_NAME)_PartitionTable.mbn: image
	@dd if=/dev/zero bs=256 count=1 | sed -e "s,\x0,\xff,g" > $@
	@## BL2, offset 0x000000, max length 0x100000
	@$(MD) $@  0 hex 00:00:00:00
	@$(MD) $@  4 hex 07:00:00:00
	@$(MD) $@  8 hex $(shell printf "%02X" `echo "$(BL2_LEN) % 256"|bc`):$(shell printf "%02X" `echo "$(BL2_LEN) / 256"|bc`):00:00
	@$(MD) $@ 12 hex 00:00:00:00
	@## empty u-boot-env, skip 0x100000 - 0x180000 (08-0b), max length 0x80000
	@## Factory, offset 0x180000, max length 0x200000 (16 blocks)
	@$(MD) $@ 16 hex 0c:00:00:00
	@$(MD) $@ 20 hex 1b:00:00:00
	@$(MD) $@ 24 hex 10:00:00:00
	@$(MD) $@ 28 hex 00:00:00:00
	@## FIP, offset 0x380000, max length 0x200000
	@$(MD) $@ 32 hex 1c:00:00:00
	@$(MD) $@ 36 hex 2b:00:00:00
	@$(MD) $@ 40 hex $(shell printf "%02X" `echo "$(FIP_LEN) % 256"|bc`):$(shell printf "%02X" `echo "$(FIP_LEN) / 256"|bc`):00:00
	@$(MD) $@ 44 hex 00:00:00:00
	@# Start block: (0x2C=44), first block of UBI_DEV partition,
	@# End block:   (128MB: 0x3FF, 256MB: 0x7FF), last block of UBI_DEV partition,
	@# Length:      UBI_DEV partition length (unit: block),
	@# attribute:   skip-bad-block (1), up to 20 (0x14 << 16) bad-block accepted
	@$(MD) $@ 48 hex $(shell printf "%02X" `echo "$(UBI_START) % 256"|bc`):$(shell printf "%02X" `echo "$(UBI_START) / 256"|bc`):00:00
	@$(MD) $@ 52 hex $(shell printf "%02X" `echo "$(LAST_BLK) % 256"|bc`):$(shell printf "%02X" `echo "$(LAST_BLK) / 256"|bc`):00:00
	@$(MD) $@ 56 hex $(shell printf "%02X" `echo "$(UDLEN) % 256"|bc`):$(shell printf "%02X" `echo "$(UDLEN) / 256"|bc`):00:00
	@$(MD) $@ 60 hex 01:00:14:00
	@cp -f $@ $(O)/$@

# Leap Electronic NAND Flash programmer (.def format)
$(BUILD_NAME)_PartitionTable.def: UDLEN=$(shell echo "(`stat -c %s $(UBI_DEV)` + 131072 - 1)/131072"|bc)
$(BUILD_NAME)_PartitionTable.def: LAST_BLK=$(shell echo "($(FLASH_SIZE_DEC) + 131072 - 1)/131072 - 1"|bc)
$(BUILD_NAME)_PartitionTable.def: BL2_LEN=$(shell echo "(`stat -c %s $(BL2)` + 131072 - 1)/131072"|bc)
$(BUILD_NAME)_PartitionTable.def: FIP_LEN=$(shell echo "(`stat -c %s $(FIP)` + 131072 - 1)/131072"|bc)
$(BUILD_NAME)_PartitionTable.def: image
	@dd if=/dev/zero bs=272 count=1 | sed -e "s,\x0,\xff,g" > $@
	@$(MD) $@  0 "GROUP DEFINE2"
	@$(MD) $@ 13 hex 00:00:00
	@## BL2, offset 0, max length 0x100000 (block 0-7)
	@$(MD) $@ 16 hex 01:00:00:00
	@$(MD) $@ 20 hex 00:00:00:00
	@$(MD) $@ 24 hex 07:00:00:00
	@$(MD) $@ 28 hex $(shell printf "%02X" `echo "$(BL2_LEN) % 256"|bc`):$(shell printf "%02X" `echo "$(BL2_LEN) / 256"|bc`):00:00
	@## empty u-boot-env, skip 0x100000 - 0x180000 (08-0b), max length 0x80000
	@## Factory, offset 0x180000, max length 0x200000 (block 0xC-0x1B)
	@$(MD) $@ 32 hex 01:00:00:00
	@$(MD) $@ 36 hex 0c:00:00:00
	@$(MD) $@ 40 hex 1b:00:00:00
	@$(MD) $@ 44 hex 10:00:00:00
	@## FIP, offset 0x380000, max length 0x200000 (block 0x1C-0x2B)
	@$(MD) $@ 48 hex 01:00:00:00
	@$(MD) $@ 52 hex 1c:00:00:00
	@$(MD) $@ 56 hex 2b:00:00:00
	@$(MD) $@ 60 hex $(shell printf "%02X" `echo "$(FIP_LEN) % 256"|bc`):$(shell printf "%02X" `echo "$(FIP_LEN) / 256"|bc`):00:00
	@# UBI, start block 0x2C=44
	@$(MD) $@ 64 hex 01:00:00:00
	@$(MD) $@ 68 hex $(shell printf "%02X" `echo "$(UBI_START) % 256"|bc`):$(shell printf "%02X" `echo "$(UBI_START) / 256"|bc`):00:00
	@$(MD) $@ 72 hex $(shell printf "%02X" `echo "$(LAST_BLK) % 256"|bc`):$(shell printf "%02X" `echo "$(LAST_BLK) / 256"|bc`):00:00
	@$(MD) $@ 76 hex $(shell printf "%02X" `echo "$(UDLEN) % 256"|bc`):$(shell printf "%02X" `echo "$(UDLEN) / 256"|bc`):00:00
	@cp -f $@ $(O)/$@

define sed_FLASH
	sed	-e 's,@BOOTLOADER@,$(BOOTLOADER),' \
		-e 's,@BOOTLOADER_BASE@,$(BOOTLOADER_BASE),' \
		-e 's,@FACTORY@,$(1),' \
		-e 's,@FACTORY_BASE@,$(FACTORY_BASE),' \
		-e 's,@UBI_DEV@,$(2),' \
		-e 's,@UBI_DEV_BASE@,$(UBI_DEV_BASE),' \
		FLASH.lds.tmpl > FLASH.lds$(3);
endef

define ld_FLASH
	$(LD) -o $@$(2).o \
		-b binary $(BOOTLOADER) \
		-b binary $(1) \
		-b binary $(UBI_DEV) \
		-T FLASH.lds$(2) -Map $(BUILD_NAME).map \
		-b elf64-littleaarch64;
endef

image: $(BOOTLOADER) $(UBI_DEV) $(FACTORY)
	@echo; echo "Prepare image $(BIN_FILE).bin"
ifeq ($(HW_ID),)
	@$(call sed_FLASH,$(FACTORY),$(UBI_DEV),)
	@$(call ld_FLASH,$(FACTORY),)
	@$(OBJCOPY) --gap-fill=0xff --pad-to $(FLASH_SIZE) -O binary $@.o $(BIN_FILE).bin
	@cp -f $(BIN_FILE).bin $(O)/$(BIN_FILE).bin
else
	@$(foreach id,$(HW_ID),$(call sed_FLASH,$(FACTORY)_HWID-$(id),$(UBI_DEV),_HWID-$(id)))
	@$(foreach id,$(HW_ID),$(call ld_FLASH,$(FACTORY)_HWID-$(id),_HWID-$(id)))
	@$(foreach id,$(HW_ID),$(OBJCOPY) --gap-fill=0xff --pad-to $(FLASH_SIZE) -O binary $@_HWID-$(id).o $(BIN_FILE)_HWID-$(id).bin;)
	@$(foreach id,$(HW_ID),cp -f $(BIN_FILE)_HWID-$(id).bin $(O)/$(BIN_FILE)_HWID-$(id).bin;)
endif

# Build Bootloader binary: BL2 at 0x000000, FIP at 0x380000
$(BOOTLOADER):
	@echo; echo "Prepare $@"
	@$(DUMPIMAGE) -T flat_dt -p 0 -o $(BL2) $(UBOOT_IMG)
	@$(DUMPIMAGE) -T flat_dt -p 1 -o $(FIP) $(UBOOT_IMG)
	@$(LD) -o $@.o \
		-b binary $(BL2) \
		-b binary $(FIP) \
		-T BOOT.lds -Map BOOT.map \
		-b elf64-littleaarch64
	@$(OBJCOPY) --gap-fill=0xff --pad-to $(UBI_DEV_BASE) -O binary $@.o $@

# FIT_SIZE_KB: computed from FW image at sed_INI expansion time
# (recursively expanded variable = lazy, re-evaluated each use)
FIT_SIZE_KB = $(shell [ -f '$(FW_FILE)' ] && expr \( `stat -c %s '$(FW_FILE)'` + 1023 \) / 1024 || echo 0)

# UBI_DEV ini template (OpenWRT-style: fit volume + nvram)
define sed_INI
	sed	-e 's,@NVRAM_SIZE@,$(NVRAM_SIZE_KB),' \
		-e 's,@FIT_IMG@,$(FW_FILE),' \
		-e 's,@FIT_SIZE@,$(FIT_SIZE_KB),' \
		-e 's,@JFFS_SIZE@,$(JFFS_SIZE_KB),' \
		UBI_DEV_128M.ini.tmpl > $(1).ini;
endef

$(UBI_DEV): $(FW_FILE) $(FACTORY_POSTFIX)
	@echo; echo "Prepare $@ (FIT_SIZE=$(FIT_SIZE_KB) KiB)"
	@$(call sed_INI,$@)
	@ubinize -o $@ --peb-size=128KiB --min-io-size=2048 \
		--sub-page-size=2048 --vid-hdr-offset=2048 -v $@.ini
ifneq ($(HW_ID),)
	@$(foreach id,$(HW_ID),$(call sed_INI,$@_HWID-$(id)))
	@$(foreach id,$(HW_ID),ubinize -o $@_HWID-$(id) --peb-size=128KiB --min-io-size=2048 \
		--sub-page-size=2048 --vid-hdr-offset=2048 -v $@_HWID-$(id).ini;)
endif

# HwId offset 0xA0000+0x10000+0xFE00=0xBFE00 (Factory partition base + postfix offset)
define set_HWID
	cp -f $(1) $(1)_HWID-$(2); \
	$(MD) "$(1)_HWID-$(2)" 0xBFE00 "$(2)";
endef

$(FACTORY_POSTFIX): $(FACTORY)
	@echo; echo "Prepare $@"
	@cp -f $< $@
	@# Replace data at offset 0xA0000+0x10000+0x188=0xB0188 to "DB100X".
	@# It should be at offset 0xB0188 of source file. The 100X is equal to UBOOT_VER.
	# Set BootVersion
	$(MD) $@ 0xB018A "$(UBOOT_VER)"
	# Set 2G MAC address
	$(MD) $@ 0x4 hex 00:AA:BB:CC:DD:E0
	# HwVersion offset 0xA0000+0x10000+0xFE04=0xBFE04
	$(MD) $@ 0xBFE04 "$(HW_VER)"
ifneq ($(HW_ID),)
	@$(foreach id,$(HW_ID),$(call set_HWID,$@,$(id)))
	@echo "Post fix result:"
	@$(foreach id,$(HW_ID),$(call compare_binary_file,$<,$@_HWID-$(id)))
endif
	@echo "Post fix result:"
	@$(call compare_binary_file,$<,$@)

$(FACTORY):
	@echo; echo "Prepare dummy $@ ($(FACTORY_SIZE_IN_BYTES) bytes)"
	@dd if=/dev/zero bs=$(FACTORY_SIZE_IN_BYTES) count=1 | sed -e "s,\x0,\xff,g" > $@

clean:
	@-$(RM) -f $(BL2) $(FIP) *.map FLASH.lds *.o *.ini *.postfix $(BIN_FILE).bin $(BIN_FILE)_*.bin $(UBI_FILE) $(UBI_FILE)_* $(BOOT_FILE) *.ecc_log *.mbn *.mbne *.def *.defe

.PHONY: all tools clean image $(BUILD_NAME)_PartitionTable.mbn $(BUILD_NAME)_PartitionTable.def $(BOOTLOADER) $(UBI_DEV) $(FACTORY) $(FACTORY_POSTFIX)
