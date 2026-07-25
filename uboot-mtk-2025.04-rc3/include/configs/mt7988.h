/* SPDX-License-Identifier: GPL-2.0 */
/*
 * Configuration for MediaTek MT7988 SoC
 *
 * Copyright (C) 2022 MediaTek Inc.
 * Author: Sam Shih <sam.shih@mediatek.com>
 */

#ifndef __MT7988_H
#define __MT7988_H

#define CFG_MAX_MEM_MAPPED		0xC0000000

#if defined(CONFIG_ASUS_PRODUCT)
#define CFG_SYS_FLASH_BASE	0xC0000000	/* define fake flash address. */
#define XMK_STR(x)	#x
#define MK_STR(x)	XMK_STR(x)

#ifndef __ASSEMBLY__
extern const char *model;
extern const char *blver;
extern int modifies;
#endif

///////////// Partition ///////////////
// 0x00000000 - 0x00100000  BL2
// 0x00100000 - 0x00180000  uboot-env
// 0x00180000 - 0x00400000  FIP(bl31+uboot)
// 0x00400000 - xxxxx       FW (Factory, nvram, linux/linux2, jffs2)
///////////////////////////////////////

/*-----------------------------------------------------------------------
 * Bootloader size and Config size definitions
 */
#define CFG_MAX_BL2_BINARY_SIZE		0x100000
#define CFG_ENV_MAX_SIZE		0x80000
#define CFG_MAX_FIP_BINARY_SIZE		0x280000
#define CFG_BOOTLOADER_SIZE		(CFG_MAX_BL2_BINARY_SIZE + CFG_MAX_FIP_BINARY_SIZE)
#if CONFIG_ENV_OFFSET != 0x100000
#error check ENV offset!
#endif
#if CONFIG_ENV_SIZE > CFG_ENV_MAX_SIZE
#error check ENV size!
#endif

#define CFG_BL2_OFFSET			0x0
#define CFG_FIP_OFFSET			(CFG_BL2_OFFSET + CFG_MAX_BL2_BINARY_SIZE + CFG_ENV_MAX_SIZE)
/*
 * UBI volume size definitions
 * Don't define size for tailed reserved space due to it's size varies.
 */
#define PEB_SIZE			(128 * 1024)
#define LEB_SIZE			(PEB_SIZE - (2 * 2 * 1024))
#define CFG_UBI_NVRAM_NR_LEB		1
#if defined(GS7) || defined(GSBE7200X) // MT7992
#define CFG_UBI_FACTORY_NR_LEB		15	/* 124KB * 15 = 1860KB, eeprom occupy 1392KB(0x15c000) */

#define CFG_UBI_FIRMWARE_NR_LEB		570	/* 124KB x 570 ~= 69.02MB */
#define CFG_UBI_APP_NR_LEB		389	/* 124KB x 389 ~= 47.10MB => minus overhead ~= 40 MB */
#else // MT7990
#define CFG_UBI_FACTORY_NR_LEB		11	/* 124KB * 11 = 1364KB, eeprom occupy 964KB(0xF1000) */

#define CFG_UBI_FIRMWARE_NR_LEB		536	/* 124KB x 536 ~= 64.91MB */
#define CFG_UBI_APP_NR_LEB		431	/* 124KB x 431 ~= 52.19MB => minus overhead ~= 45 MB */
#endif

#define CFG_UBI_NVRAM_SIZE		(LEB_SIZE * CFG_UBI_NVRAM_NR_LEB)
#define CFG_UBI_FACTORY_SIZE		(LEB_SIZE * CFG_UBI_FACTORY_NR_LEB)
#define CFG_UBI_FACTORY2_SIZE		(LEB_SIZE * CFG_UBI_FACTORY_NR_LEB)
#define CFG_UBI_FIRMWARE_SIZE		(LEB_SIZE * CFG_UBI_FIRMWARE_NR_LEB)
#define CFG_UBI_FIRMWARE2_SIZE		(LEB_SIZE * CFG_UBI_FIRMWARE_NR_LEB)	/* linux2 size same as linux */
#define CFG_UBI_APP_SIZE		(LEB_SIZE * CFG_UBI_APP_NR_LEB)

#define CFG_NVRAM_SIZE			CFG_UBI_NVRAM_SIZE

#define CFG_FACTORY_SIZE		(CFG_UBI_FACTORY_SIZE + CFG_UBI_FACTORY2_SIZE)

#define CFG_UBI_DEV_OFFSET		(CFG_BOOTLOADER_SIZE + CFG_ENV_MAX_SIZE)

/* Environment address, factory address, and firmware address definitions */
/* Basically, CFG_FACTORY_ADDR and CFG_KERN_ADDR are used to compatible to original code infrastructure.
 * Real nvram area would be moved into the nvram volume of UBI device.
 * Real Factory area would be moved into the Factory volume of UBI device.
 * Real firmware area would be moved into the linux and linux2 volume of UBI device.
 */
#define CFG_NVRAM_ADDR			(CFG_SYS_FLASH_BASE + CFG_UBI_DEV_OFFSET)
#define CFG_FACTORY_ADDR		(CFG_NVRAM_ADDR + CFG_NVRAM_SIZE)
#define CFG_KERN_ADDR			(CFG_FACTORY_ADDR + CFG_FACTORY_SIZE)
#define CFG_KERN2_ADDR			(CFG_KERN_ADDR + CFG_UBI_FIRMWARE_SIZE)

/*-----------------------------------------------------------------------
 * Factory
 */
#define CFG_EEPROM_OFFSET	0x0
#if defined(GS7) || defined(GSBE7200X) // MT7992
#define CFG_EEPROM_SIZE		0x15C000 /* 1392KB*/
#else
#define CFG_EEPROM_SIZE		0xF1000 /* 964KB*/
#endif
#define CFG_MAC_OFFSET		0x4	/* ra0  MAC address */
#define CFG_MAC_OFFSET_5G	0xA	/* rai0 MAC address */
#define CFG_MAC_OFFSET_6G	0x2C0	/* rax0 MAC address */

#define FTRY_PARM_SHIFT			(CFG_EEPROM_OFFSET + CFG_EEPROM_SIZE + 0x10000) /* EEPROM end + 64KB */
#define OFFSET_PIN_CODE			(FTRY_PARM_SHIFT + 0x180)	/* 8 bytes */
#define OFFSET_COUNTRY_CODE		(FTRY_PARM_SHIFT + 0x188)	/* 2 bytes */
#define OFFSET_BOOT_VER			(FTRY_PARM_SHIFT + 0x18A)	/* 4 bytes */
#define OFFSET_HWID			(FTRY_PARM_SHIFT + 0xFE00)	/* 4 bytes */
#define OFFSET_ODMPID			(FTRY_PARM_SHIFT + 0xFFB0)	/* 16 bytes */

/*-----------------------------------------------------------------------*/

#define CFG_ETHADDR		00:aa:bb:cc:dd:e0
#define CFG_ETHADDR_5G		00:aa:bb:cc:dd:e1
#define CFG_ETHADDR_6G		00:aa:bb:cc:dd:e2

#define CFG_UBI_SUPPORT
#define CFG_FLASH_TYPE		"nand"
//#define CFG_DUAL_TRX
#define ASUS_EXTRA_ENV_SETTINGS	"ethact=ethernet@15110100\0"
#define ASUS_EXTRA_ENV2		"ethrotate=no\0"

#if defined(EAGLE_A) || defined(EAGLE_D)
#define CFG_BLVER		"1003"
#elif defined(BT8)
#define CFG_BLVER		"1014"
#elif defined(BT6)
#define CFG_BLVER		"1014"
#elif defined(BT8P)
#define CFG_BLVER		"1014"
#elif defined(GS7)
#define CFG_BLVER		"1011"
#elif defined(GSBE7200X)
#define CFG_BLVER		"1010"
#endif
#endif // ASUS_PRODUCT

/* Extra environment variables */
#ifdef CONFIG_MTK_DEFAULT_FIT_BOOT_CONF
#define FIT_BOOT_CONF_ENV	"bootconf=" CONFIG_MTK_DEFAULT_FIT_BOOT_CONF "\0"
#else
#define FIT_BOOT_CONF_ENV
#endif

#define CFG_EXTRA_ENV_SETTINGS	\
	ASUS_EXTRA_ENV_SETTINGS	\
	ASUS_EXTRA_ENV2 \
	FIT_BOOT_CONF_ENV

#endif
