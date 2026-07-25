// SPDX-License-Identifier: GPL-2.0
/* FILE NAME:  en8801sc.c
 * PURPOSE:
 *      EN8801S phy driver for Linux
 * NOTES:
 *
 */

/* INCLUDE FILE DECLARATIONS
 */
#include <common.h>
#include <phy.h>
#include <linux/delay.h>
#include <linux/mii.h>
#include <linux/mdio.h>

#include "en8801sc.h"
//#define VV_DEBUG

enum {
    PHY_STATE_DONE = 0,
    PHY_STATE_INIT = 1,
    PHY_STATE_PROCESS = 2,
    PHY_STATE_FAIL = 3,
};
static int phystate;

struct en8801s_priv {
	bool first_init;
	u16 count;
	u16 pro_version;
#if 0 //(KERNEL_VERSION(4, 16, 0) > LINUX_VERSION_CODE)
	struct gpio_desc *hw_reset;
#endif
} glpriv;

int bk_addr;

#undef dev_err
#undef dev_info
#undef dev_dbg

#define dev_err(dev, fmt, ...) \
	printf(fmt, ##__VA_ARGS__)
#define dev_info(dev, fmt, ...) \
	printf(fmt, ##__VA_ARGS__)
#ifdef VV_DEBUG
#define dev_dbg(dev, fmt, ...) \
	printf(fmt, ##__VA_ARGS__)
#else
#define dev_dbg(dev, fmt, ...) {}
#endif

/************************************************************************
*                  F U N C T I O N S
************************************************************************/
unsigned int airoha_cl45_write(struct mii_dev *bus, u32 port, u32 devad, u32 reg, u16 val)
{
    bus->write(bus, port, MDIO_DEVAD_NONE, MII_MMD_ACC_CTL_REG, devad);
    bus->write(bus, port, MDIO_DEVAD_NONE, MII_MMD_ADDR_DATA_REG, reg);
    bus->write(bus, port, MDIO_DEVAD_NONE, MII_MMD_ACC_CTL_REG, MMD_OP_MODE_DATA | devad);
    bus->write(bus, port, MDIO_DEVAD_NONE, MII_MMD_ADDR_DATA_REG, val);
    return 0;
}

unsigned int airoha_cl45_read(struct mii_dev *bus, u32 port, u32 devad, u32 reg, u16 *read_data)
{
    bus->write(bus, port, MDIO_DEVAD_NONE, MII_MMD_ACC_CTL_REG, devad);
    bus->write(bus, port, MDIO_DEVAD_NONE, MII_MMD_ADDR_DATA_REG, reg);
    bus->write(bus, port, MDIO_DEVAD_NONE, MII_MMD_ACC_CTL_REG, MMD_OP_MODE_DATA | devad);
    *read_data = bus->read(bus, port, MDIO_DEVAD_NONE, MII_MMD_ADDR_DATA_REG);
    return 0;
}

unsigned int airoha_cl22_read(struct mii_dev *bus, unsigned int phy_addr,unsigned int phy_register,unsigned int *read_data)
{
    *read_data = bus->read(bus, phy_addr, MDIO_DEVAD_NONE, phy_register);
    return 0;
}

unsigned int airoha_cl22_write(struct mii_dev *bus, unsigned int phy_addr, unsigned int phy_register,unsigned int write_data)
{
    bus->write(bus, phy_addr, MDIO_DEVAD_NONE, phy_register, write_data);
    return 0;
}

int airoha_pbus_write(struct mii_dev *bus, unsigned long pbus_id, unsigned long pbus_address, unsigned long pbus_data)
{
    airoha_cl22_write(bus, pbus_id, 0x1F, (unsigned int)(pbus_address >> 6));
    airoha_cl22_write(bus, pbus_id, (unsigned int)((pbus_address >> 2) & 0xf), (unsigned int)(pbus_data & 0xFFFF));
    airoha_cl22_write(bus, pbus_id, 0x10, (unsigned int)(pbus_data >> 16));
    return 0;
}

unsigned long airoha_pbus_read(struct mii_dev *bus, unsigned long pbus_id, unsigned long pbus_address)
{
    unsigned long pbus_data;
    unsigned int pbus_data_low, pbus_data_high;

    airoha_cl22_write(bus, pbus_id, 0x1F, (unsigned int)(pbus_address >> 6));
    airoha_cl22_read(bus, pbus_id, (unsigned int)((pbus_address >> 2) & 0xf), &pbus_data_low);
    airoha_cl22_read(bus, pbus_id, 0x10, &pbus_data_high);
    pbus_data = (pbus_data_high << 16) + pbus_data_low;
    return pbus_data;
}

/* Airoha Token Ring Write function */
int airoha_tr_reg_write(struct mii_dev *bus, unsigned long tr_address, unsigned long tr_data)
{
    airoha_cl22_write(bus, EN8801S_MDIO_PHY_ID, 0x1F, 0x52b5);       /* page select */
    airoha_cl22_write(bus, EN8801S_MDIO_PHY_ID, 0x11, (unsigned int)(tr_data & 0xffff));
    airoha_cl22_write(bus, EN8801S_MDIO_PHY_ID, 0x12, (unsigned int)(tr_data >> 16));
    airoha_cl22_write(bus, EN8801S_MDIO_PHY_ID, 0x10, (unsigned int)(tr_address | TrReg_WR));
    airoha_cl22_write(bus, EN8801S_MDIO_PHY_ID, 0x1F, 0x0);          /* page resetore */
    return 0;
}

/* Airoha Token Ring Read function */
unsigned long airoha_tr_reg_read(struct mii_dev *bus, unsigned long tr_address)
{
    unsigned long tr_data;
    unsigned int tr_data_low, tr_data_high;

    airoha_cl22_write(bus, EN8801S_MDIO_PHY_ID, 0x1F, 0x52b5);       /* page select */
    airoha_cl22_write(bus, EN8801S_MDIO_PHY_ID, 0x10, (unsigned int)(tr_address | TrReg_RD));
    airoha_cl22_read(bus, EN8801S_MDIO_PHY_ID, 0x11, &tr_data_low);
    airoha_cl22_read(bus, EN8801S_MDIO_PHY_ID, 0x12, &tr_data_high);
    airoha_cl22_write(bus, EN8801S_MDIO_PHY_ID, 0x1F, 0x0);          /* page resetore */
    tr_data = (tr_data_high << 16) + tr_data_low;
    return tr_data;
}

void en8801s_led_init(struct mii_dev *bus)
{
    u32 reg_value;
    airoha_pbus_write(bus, EN8801S_PBUS_PHY_ID, 0x186c, 0x3);
    airoha_pbus_write(bus, EN8801S_PBUS_PHY_ID, 0X1870, 0x100);
    reg_value = (airoha_pbus_read(bus, EN8801S_PBUS_PHY_ID, 0x1880) & ~(0x3));
    airoha_pbus_write(bus, EN8801S_PBUS_PHY_ID, 0x1880, reg_value);
    airoha_cl45_write(bus, EN8801S_MDIO_PHY_ID, 0x1f, 0x21, 0x8008);
    airoha_cl45_write(bus, EN8801S_MDIO_PHY_ID, 0x1f, 0x22, 0x600);
    airoha_cl45_write(bus, EN8801S_MDIO_PHY_ID, 0x1f, 0x23, 0xc00);
    /* LED0: 10M/100M */
    airoha_cl45_write(bus, EN8801S_MDIO_PHY_ID, 0x1f, 0x24, 0x8006);
    /* LED0: blink 10M/100M Tx/Rx */
    airoha_cl45_write(bus, EN8801S_MDIO_PHY_ID, 0x1f, 0x25, 0x3c);
    /* LED1: 1000M */
    airoha_cl45_write(bus, EN8801S_MDIO_PHY_ID, 0x1f, 0x26, 0x8001);
    /* LED1: blink 1000M Tx/Rx */
    airoha_cl45_write(bus, EN8801S_MDIO_PHY_ID, 0x1f, 0x27, 0x3);
}

static int en8801s_phy_process(struct mii_dev *bus)
{
    u32 reg_value = 0;

    reg_value = airoha_pbus_read(bus, EN8801S_PBUS_PHY_ID, 0x19e0);
    reg_value |= (1 << 0);
    airoha_pbus_write(bus, EN8801S_PBUS_PHY_ID, 0x19e0, reg_value);
    reg_value = airoha_pbus_read(bus, EN8801S_PBUS_PHY_ID, 0x19e0);
    reg_value &= ~(1 << 0);
    airoha_pbus_write(bus, EN8801S_PBUS_PHY_ID, 0x19e0, reg_value);
    return 0;
}

static int en8801s_phase2_init(struct mii_dev *mbus, int addr)
{
	union gephy_all_REG_LpiReg1Ch      GPHY_RG_LPI_1C;
	union gephy_all_REG_dev1Eh_reg324h GPHY_RG_1E_324;
	union gephy_all_REG_dev1Eh_reg012h GPHY_RG_1E_012;
	union gephy_all_REG_dev1Eh_reg017h GPHY_RG_1E_017;
	unsigned long pbus_data;
	int phy_addr = addr;
	int pbus_addr = EN8801S_PBUS_PHY_ID;
	u16 cl45_value;
	int retry, ret = 0;

	pbus_data = airoha_pbus_read(mbus, pbus_addr, 0x1690);
	pbus_data |= BIT(31);
	ret = airoha_pbus_write(mbus, pbus_addr, 0x1690, pbus_data);
	if (ret < 0)
		return ret;

	ret = airoha_pbus_write(mbus, pbus_addr, 0x0600, 0x0c000c00);
	if (ret < 0)
		return ret;
	ret = airoha_pbus_write(mbus, pbus_addr, 0x10, 0xD801);
	if (ret < 0)
		return ret;
	ret = airoha_pbus_write(mbus, pbus_addr, 0x0,  0x9140);
	if (ret < 0)
		return ret;

	ret = airoha_pbus_write(mbus, pbus_addr, 0x0A14, 0x0003);
	if (ret < 0)
		return ret;
	ret = airoha_pbus_write(mbus, pbus_addr, 0x0600, 0x0c000c00);
	if (ret < 0)
		return ret;
	/* Set FCM control */
	ret = airoha_pbus_write(mbus, pbus_addr, 0x1404, 0x004b);
	if (ret < 0)
		return ret;
	ret = airoha_pbus_write(mbus, pbus_addr, 0x140c, 0x0007);
	if (ret < 0)
		return ret;

	ret = airoha_pbus_write(mbus, pbus_addr, 0x142c, 0x05050505);
	if (ret < 0)
		return ret;
	pbus_data = airoha_pbus_read(mbus, pbus_addr, 0x1440);
	ret = airoha_pbus_write(mbus, pbus_addr, 0x1440, pbus_data & ~BIT(11));
	if (ret < 0)
		return ret;

	pbus_data = airoha_pbus_read(mbus, pbus_addr, 0x1408);
	ret = airoha_pbus_write(mbus, pbus_addr, 0x1408, pbus_data | BIT(5));
	if (ret < 0)
		return ret;

	/* Set GPHY Perfomance*/
	/* Token Ring */
	ret = airoha_tr_reg_write(mbus, RgAddr_R1000DEC_15h, 0x0055A0);
	if (ret < 0)
		return ret;
	ret = airoha_tr_reg_write(mbus, RgAddr_R1000DEC_17h, 0x07FF3F);
	if (ret < 0)
		return ret;
	ret = airoha_tr_reg_write(mbus, RgAddr_PMA_00h,      0x00001E);
	if (ret < 0)
		return ret;
	ret = airoha_tr_reg_write(mbus, RgAddr_PMA_01h,      0x6FB90A);
	if (ret < 0)
		return ret;
	ret = airoha_tr_reg_write(mbus, RgAddr_PMA_17h,      0x060671);
	if (ret < 0)
		return ret;
	ret = airoha_tr_reg_write(mbus, RgAddr_PMA_18h,      0x0E2F00);
	if (ret < 0)
		return ret;
	ret = airoha_tr_reg_write(mbus, RgAddr_TR_26h,       0x444444);
	if (ret < 0)
		return ret;
	ret = airoha_tr_reg_write(mbus, RgAddr_DSPF_03h,     0x000000);
	if (ret < 0)
		return ret;
	ret = airoha_tr_reg_write(mbus, RgAddr_DSPF_06h,     0x2EBAEF);
	if (ret < 0)
		return ret;
	ret = airoha_tr_reg_write(mbus, RgAddr_DSPF_08h,     0x00000B);
	if (ret < 0)
		return ret;
	ret = airoha_tr_reg_write(mbus, RgAddr_DSPF_0Ch,     0x00504D);
	if (ret < 0)
		return ret;
	ret = airoha_tr_reg_write(mbus, RgAddr_DSPF_0Dh,     0x02314F);
	if (ret < 0)
		return ret;
	ret = airoha_tr_reg_write(mbus, RgAddr_DSPF_0Fh,     0x003028);
	if (ret < 0)
		return ret;
	ret = airoha_tr_reg_write(mbus, RgAddr_DSPF_10h,     0x005010);
	if (ret < 0)
		return ret;
	ret = airoha_tr_reg_write(mbus, RgAddr_DSPF_11h,     0x040001);
	if (ret < 0)
		return ret;
	ret = airoha_tr_reg_write(mbus, RgAddr_DSPF_13h,     0x018670);
	if (ret < 0)
		return ret;
	ret = airoha_tr_reg_write(mbus, RgAddr_DSPF_14h,     0x00024A);
	if (ret < 0)
		return ret;
	ret = airoha_tr_reg_write(mbus, RgAddr_DSPF_1Bh,     0x000072);
	if (ret < 0)
		return ret;
	ret = airoha_tr_reg_write(mbus, RgAddr_DSPF_1Ch,     0x003210);
	if (ret < 0)
		return ret;

	/* CL22 & CL45 */
	ret = mbus->write(mbus, addr, MDIO_DEVAD_NONE, 0x1f, 0x03);
	if (ret < 0)
		return ret;
	GPHY_RG_LPI_1C.DATA = mbus->read(mbus, addr, MDIO_DEVAD_NONE, RgAddr_LPI_1Ch);
	GPHY_RG_LPI_1C.DataBitField.smi_deton_th = 0x0C;
	ret = mbus->write(mbus, addr, MDIO_DEVAD_NONE, RgAddr_LPI_1Ch, GPHY_RG_LPI_1C.DATA);
	if (ret < 0)
		return ret;
	ret = mbus->write(mbus, addr, MDIO_DEVAD_NONE, RgAddr_LPI_1Ch, 0xC92);
	if (ret < 0)
		return ret;
	ret = mbus->write(mbus, addr, MDIO_DEVAD_NONE, RgAddr_AUXILIARY_1Dh, 0x1);
	if (ret < 0)
		return ret;
	ret = mbus->write(mbus, addr, MDIO_DEVAD_NONE, 0x1f, 0x0);
	if (ret < 0)
		return ret;
	ret = airoha_cl45_write(mbus, phy_addr, 0x1E, 0x120, 0x8014);
	if (ret < 0)
		return ret;
	ret = airoha_cl45_write(mbus, phy_addr, 0x1E, 0x122, 0xffff);
	if (ret < 0)
		return ret;
	ret = airoha_cl45_write(mbus, phy_addr, 0x1E, 0x123, 0xffff);
	if (ret < 0)
		return ret;
	ret = airoha_cl45_write(mbus, phy_addr, 0x1E, 0x144, 0x0200);
	if (ret < 0)
		return ret;
	ret = airoha_cl45_write(mbus, phy_addr, 0x1E, 0x14A, 0xEE20);
	if (ret < 0)
		return ret;
	ret = airoha_cl45_write(mbus, phy_addr, 0x1E, 0x189, 0x0110);
	if (ret < 0)
		return ret;
	ret = airoha_cl45_write(mbus, phy_addr, 0x1E, 0x19B, 0x0111);
	if (ret < 0)
		return ret;
	ret = airoha_cl45_write(mbus, phy_addr, 0x1E, 0x234, 0x0181);
	if (ret < 0)
		return ret;
	ret = airoha_cl45_write(mbus, phy_addr, 0x1E, 0x238, 0x0120);
	if (ret < 0)
		return ret;
	ret = airoha_cl45_write(mbus, phy_addr, 0x1E, 0x239, 0x0117);
	if (ret < 0)
		return ret;
	ret = airoha_cl45_write(mbus, phy_addr, 0x1E, 0x268, 0x07F4);
	if (ret < 0)
		return ret;
	ret = airoha_cl45_write(mbus, phy_addr, 0x1E, 0x2D1, 0x0733);
	if (ret < 0)
		return ret;
	ret = airoha_cl45_write(mbus, phy_addr, 0x1E, 0x323, 0x0011);
	if (ret < 0)
		return ret;
	ret = airoha_cl45_write(mbus, phy_addr, 0x1E, 0x324, 0x013F);
	if (ret < 0)
		return ret;
	ret = airoha_cl45_write(mbus, phy_addr, 0x1E, 0x326, 0x0037);
	if (ret < 0)
		return ret;

	ret = airoha_cl45_read(mbus, phy_addr, 0x1E, 0x324, &cl45_value);
	if (ret < 0)
		return ret;
	GPHY_RG_1E_324.DATA = cl45_value;
	GPHY_RG_1E_324.DataBitField.smi_det_deglitch_off = 0;
	ret = airoha_cl45_write(mbus, phy_addr, 0x1E, 0x324,
				GPHY_RG_1E_324.DATA);
	if (ret < 0)
		return ret;
	ret = airoha_cl45_write(mbus, phy_addr, 0x1E, 0x19E, 0xC2);
	if (ret < 0)
		return ret;
	ret = airoha_cl45_write(mbus, phy_addr, 0x1E, 0x013, 0x0);
	if (ret < 0)
		return ret;

	/* EFUSE */
	airoha_pbus_write(mbus, pbus_addr, 0x1C08, 0x40000040);
	retry = MAX_RETRY;
	while (retry != 0) {
		mdelay(1);
		pbus_data = airoha_pbus_read(mbus, pbus_addr, 0x1C08);
		if ((pbus_data & BIT(30)) == 0)
			break;

		retry--;
	}
	pbus_data = airoha_pbus_read(mbus, pbus_addr, 0x1C38); /* RAW#2 */
	ret = airoha_cl45_read(mbus, phy_addr, 0x1E, 0x12, &cl45_value);
	if (ret < 0)
		return ret;
	GPHY_RG_1E_012.DATA = cl45_value;
	GPHY_RG_1E_012.DataBitField.da_tx_i2mpb_a_tbt =
				(u16)(pbus_data & 0x03f);
	ret = airoha_cl45_write(mbus, phy_addr, 0x1E, 0x12,
				GPHY_RG_1E_012.DATA);
	if (ret < 0)
		return ret;
	ret = airoha_cl45_read(mbus, phy_addr, 0x1E, 0x17, &cl45_value);
	if (ret < 0)
		return ret;
	GPHY_RG_1E_017.DATA = cl45_value;
	GPHY_RG_1E_017.DataBitField.da_tx_i2mpb_b_tbt =
				(u16)((pbus_data >> 8) & 0x03f);
	ret = airoha_cl45_write(mbus, phy_addr, 0x1E, 0x17,
				GPHY_RG_1E_017.DATA);
	if (ret < 0)
		return ret;

	airoha_pbus_write(mbus, pbus_addr, 0x1C08, 0x40400040);
	retry = MAX_RETRY;
	while (retry != 0) {
		mdelay(1);
		pbus_data = airoha_pbus_read(mbus, pbus_addr, 0x1C08);
		if ((pbus_data & BIT(30)) == 0)
			break;

		retry--;
	}
	pbus_data = airoha_pbus_read(mbus, pbus_addr, 0x1C30); /* RAW#16 */
	GPHY_RG_1E_324.DataBitField.smi_det_deglitch_off =
				(u16)((pbus_data >> 12) & 0x01);
	ret = airoha_cl45_write(mbus, phy_addr, 0x1E, 0x324,
				GPHY_RG_1E_324.DATA);
	if (ret < 0)
		return ret;
#ifdef AIR_LED_SUPPORT
	ret = en8801s_led_init(phydev);
	if (ret != 0)
		dev_err(dev, "en8801s_led_init fail (ret:%d) !\n", ret);
#endif

	ret = airoha_cl45_read(mbus, phy_addr, MDIO_MMD_AN,
				MDIO_AN_EEE_ADV, &cl45_value);
	if (ret < 0)
		return ret;
	if (cl45_value == 0) {
		pbus_data = airoha_pbus_read(mbus, pbus_addr, 0x1960);
		if (0xA == ((pbus_data & 0x07c00000) >> 22)) {
			pbus_data = (pbus_data & 0xf83fffff) | (0xC << 22);
			ret = airoha_pbus_write(mbus, pbus_addr, 0x1960,
						pbus_data);
			if (ret < 0)
				return ret;
			mdelay(10);
			pbus_data = (pbus_data & 0xf83fffff) | (0xE << 22);
			ret = airoha_pbus_write(mbus, pbus_addr, 0x1960,
						pbus_data);
			if (ret < 0)
				return ret;
			mdelay(10);
		}
	} else {
		pbus_data = airoha_pbus_read(mbus, pbus_addr, 0x1960);
		if (0xE == ((pbus_data & 0x07c00000) >> 22)) {
			pbus_data = (pbus_data & 0xf83fffff) | (0xC << 22);
			ret = airoha_pbus_write(mbus, pbus_addr, 0x1960,
						pbus_data);
			if (ret < 0)
				return ret;
			mdelay(10);
			pbus_data = (pbus_data & 0xf83fffff) | (0xA << 22);
			ret = airoha_pbus_write(mbus, pbus_addr, 0x1960,
						pbus_data);
			if (ret < 0)
				return ret;
			mdelay(10);
		}
	}

	glpriv.first_init = false;
	dev_info(phydev_dev(phydev), "Phase2 initialize OK !\n");
	return 0;
}

static int en8801s_phase1_init(struct mii_dev *mbus, int addr)
{
	unsigned long pbus_data;
	int pbus_addr = EN8801S_PBUS_DEFAULT_ADDR;
	u16 reg_value;
	int retry, ret = 0;

#if 0 // (KERNEL_VERSION(4, 16, 0) > LINUX_VERSION_CODE)
	/* Deassert the reset signal */
	if (glpriv.hw_reset)
		gpiod_set_value(glpriv.hw_reset, 0);
#endif
	glpriv.count = 1;
	//msleep(1000);

	retry = MAX_OUI_CHECK;
	while (1) {
		pbus_data = airoha_pbus_read(mbus, pbus_addr,
				EN8801S_RG_ETHER_PHY_OUI);      /* PHY OUI */
		if (pbus_data == EN8801S_PBUS_OUI) {
			dev_info(dev, "PBUS addr 0x%x: Start initialized.\n",
					pbus_addr);
			break;
		}
		pbus_addr = EN8801S_PBUS_PHY_ID;
		if (0 == --retry) {
			dev_err(dev, "Probe fail !\n");
			return 0;
		}
	}

	ret = airoha_pbus_write(mbus, pbus_addr, EN8801S_RG_BUCK_CTL, 0x03);
	if (ret < 0)
		return ret;
	pbus_data = airoha_pbus_read(mbus, pbus_addr, EN8801S_RG_PROD_VER);
	glpriv.pro_version = pbus_data & 0xf;
	dev_info(dev, "EN8801S Procduct Version :E%d\n", glpriv.pro_version);
	mdelay(10);
	pbus_data = (airoha_pbus_read(mbus, pbus_addr, EN8801S_RG_LTR_CTL)
				 & 0xfffffffc) | BIT(2);
	ret = airoha_pbus_write(mbus, pbus_addr,
				EN8801S_RG_LTR_CTL, pbus_data);
	if (ret < 0)
		return ret;
	mdelay(500);
	pbus_data = (pbus_data & ~BIT(2)) |
				EN8801S_RX_POLARITY_NORMAL |
				EN8801S_TX_POLARITY_NORMAL;
	ret = airoha_pbus_write(mbus, pbus_addr,
				EN8801S_RG_LTR_CTL, pbus_data);
	if (ret < 0)
		return ret;
	mdelay(500);
	if (glpriv.pro_version == 4) {
		pbus_data = airoha_pbus_read(mbus, pbus_addr, 0x1900);
		dev_dbg(dev, "Before 0x1900 0x%x\n", pbus_data);
		ret = airoha_pbus_write(mbus, pbus_addr, 0x1900, 0x101009f);
		if (ret < 0)
			return ret;
		pbus_data = airoha_pbus_read(mbus, pbus_addr, 0x1900);
		dev_dbg(dev, "After 0x1900 0x%x\n", pbus_data);
		pbus_data = airoha_pbus_read(mbus, pbus_addr, 0x19a8);
		dev_dbg(dev, "Before 19a8 0x%x\n", pbus_data);
		ret = airoha_pbus_write(mbus, pbus_addr,
				0x19a8, pbus_data & ~BIT(16));
		if (ret < 0)
			return ret;
		pbus_data = airoha_pbus_read(mbus, pbus_addr, 0x19a8);
		dev_dbg(dev, "After 19a8 0x%x\n", pbus_data);
	}
	pbus_data = airoha_pbus_read(mbus, pbus_addr,
				EN8801S_RG_SMI_ADDR); /* SMI ADDR */
	pbus_data = (pbus_data & 0xffff0000) |
				(unsigned long)(EN8801S_PBUS_PHY_ID << 8) |
				(unsigned long)(EN8801S_MDIO_PHY_ID);
	dev_info(phydev_dev(phydev), "SMI_ADDR=%lx (renew)\n", pbus_data);
	ret = airoha_pbus_write(mbus, pbus_addr,
				EN8801S_RG_SMI_ADDR, pbus_data);
	mdelay(10);

	retry = MAX_RETRY;
	while (1) {
		mdelay(10);
		reg_value = mbus->read(mbus, addr, MDIO_DEVAD_NONE, MII_PHYSID2);

		if (reg_value == EN8801S_PHY_ID2)
			break;    /* wait GPHY ready */

		retry--;
		if (retry == 0) {
			dev_err(dev, "Initialize fail !\n");
			return 0;
		}
	}
	/* Software Reset PHY */
	reg_value = mbus->read(mbus, addr, MDIO_DEVAD_NONE, MII_BMCR);
	reg_value |= BMCR_RESET;
	ret = mbus->write(mbus, addr, MDIO_DEVAD_NONE, MII_BMCR, reg_value);
	if (ret < 0)
		return ret;
	retry = MAX_RETRY;
	do {
		mdelay(10);
		reg_value = mbus->read(mbus, addr, MDIO_DEVAD_NONE, MII_BMCR);
		retry--;
		if (retry == 0) {
			dev_err(dev, "Reset fail !\n");
			return 0;
		}
	} while (reg_value & BMCR_RESET);

	phystate = PHY_STATE_INIT;

	dev_info(dev, "Phase1 initialize OK ! (%s)\n", EN8801S_DRIVER_VERSION);
	if (glpriv.pro_version == 4) {
		ret = en8801s_phase2_init(mbus, addr);
		if (ret != 0) {
			dev_info(dev, "en8801_phase2_init failed\n");
			phystate = PHY_STATE_FAIL;
			return 0;
		}
		phystate = PHY_STATE_PROCESS;
	}

	return 0;
}

int en8801s_update_status(struct phy_device *phydev)
{
	int ret = 0, preSpeed = phydev->speed;
	u32 reg_value;
	int pbus_addr = EN8801S_PBUS_PHY_ID;

#ifdef VV_DEBUG
	printf("\n[%s]LINK_DOWN:%d, LINK_UP:%d, phydev->link:%d, speed:%d, phystate:%d, preSpeed:%d\n", __func__, LINK_DOWN, LINK_UP, phydev->link, phydev->speed, phystate, preSpeed);
#endif
	//ret = genphy_read_status(phydev);
	if (phydev->link == LINK_DOWN)
		preSpeed = phydev->speed = 0;

	if (phystate == PHY_STATE_PROCESS) {
#ifdef VV_DEBUG
		printf("[%s:%d], set_process\n", __func__, __LINE__);
#endif
		en8801s_phy_process(phydev->bus);
		phystate = PHY_STATE_DONE;
	}

	if (phystate == PHY_STATE_INIT) {
		dev_dbg(dev, "phydev->link %d, count %d\n",
					phydev->link, glpriv.count);
		if ((phydev->link) || (glpriv.count == 5)) {
			if (glpriv.pro_version != 4) {
				ret = en8801s_phase2_init(phydev->bus, bk_addr);
				if (ret != 0) {
					dev_info(dev, "en8801_phase2_init failed\n");
					phystate = PHY_STATE_FAIL;
					return 0;
				}
				phystate = PHY_STATE_PROCESS;
			}
		}
		glpriv.count++;
	}

	if ((preSpeed != phydev->speed) && (phydev->link == LINK_UP)) {
		preSpeed = phydev->speed;

		if (preSpeed == SPEED_10) {
			reg_value = airoha_pbus_read(phydev->bus, pbus_addr, 0x1694);
			reg_value |= BIT(31);
			ret = airoha_pbus_write(phydev->bus, pbus_addr, 0x1694,
					reg_value);
			if (ret < 0)
				return ret;
			phystate = PHY_STATE_PROCESS;
		} else {
			reg_value = airoha_pbus_read(phydev->bus, pbus_addr, 0x1694);
			reg_value &= ~BIT(31);
			ret = airoha_pbus_write(phydev->bus, pbus_addr, 0x1694,
					reg_value);
			if (ret < 0)
				return ret;
			phystate = PHY_STATE_PROCESS;
		}

		airoha_pbus_write(phydev->bus, pbus_addr, 0x0600,
				0x0c000c00);
		if (preSpeed == SPEED_1000) {
#ifdef VV_DEBUG
			printf("[%s:%d], set 1000\n", __func__, __LINE__);
#endif
			dev_dbg(dev, "SPEED_1000\n");
			ret = airoha_pbus_write(phydev->bus, pbus_addr, 0x10,
					0xD801);
			if (ret < 0)
				return ret;
			ret = airoha_pbus_write(phydev->bus, pbus_addr, 0x0,
					0x9140);
			if (ret < 0)
				return ret;

			ret = airoha_pbus_write(phydev->bus, pbus_addr, 0x0A14,
					0x0003);
			if (ret < 0)
				return ret;
			ret = airoha_pbus_write(phydev->bus, pbus_addr, 0x0600,
					0x0c000c00);
			if (ret < 0)
				return ret;
			mdelay(2);      /* delay 2 ms */
			ret = airoha_pbus_write(phydev->bus, pbus_addr, 0x1404,
					0x004b);
			if (ret < 0)
				return ret;
			ret = airoha_pbus_write(phydev->bus, pbus_addr, 0x140c,
					0x0007);
			if (ret < 0)
				return ret;
		} else if (preSpeed == SPEED_100) {
			dev_dbg(dev, "SPEED_100\n");
			ret = airoha_pbus_write(phydev->bus, pbus_addr, 0x10,
					0xD401);
			if (ret < 0)
				return ret;
			ret = airoha_pbus_write(phydev->bus, pbus_addr, 0x0,
					0x9140);
			if (ret < 0)
				return ret;

			ret = airoha_pbus_write(phydev->bus, pbus_addr, 0x0A14,
					0x0007);
			if (ret < 0)
				return ret;
			ret = airoha_pbus_write(phydev->bus, pbus_addr, 0x0600,
					0x0c11);
			if (ret < 0)
				return ret;
			mdelay(2);      /* delay 2 ms */
			ret = airoha_pbus_write(phydev->bus, pbus_addr, 0x1404,
					0x0027);
			if (ret < 0)
				return ret;
			ret = airoha_pbus_write(phydev->bus, pbus_addr, 0x140c,
					0x0007);
			if (ret < 0)
				return ret;
		} else if (preSpeed == SPEED_10) {
			dev_dbg(dev, "SPEED_10\n");
			ret = airoha_pbus_write(phydev->bus, pbus_addr, 0x10,
					0xD001);
			if (ret < 0)
				return ret;
			ret = airoha_pbus_write(phydev->bus, pbus_addr, 0x0,
					0x9140);
			if (ret < 0)
				return ret;

			ret = airoha_pbus_write(phydev->bus, pbus_addr, 0x0A14,
					0x000b);
			if (ret < 0)
				return ret;
			ret = airoha_pbus_write(phydev->bus, pbus_addr, 0x0600,
					0x0c11);
			if (ret < 0)
				return ret;
			mdelay(2);      /* delay 2 ms */
			ret = airoha_pbus_write(phydev->bus, pbus_addr, 0x1404,
					0x0027);
			if (ret < 0)
				return ret;
			ret = airoha_pbus_write(phydev->bus, pbus_addr, 0x140c,
					0x0007);
			if (ret < 0)
				return ret;
		}
	}
	return ret;
}

static int en8801s_probe(struct mii_dev *mbus, int addr)
{
	//unsigned long phy_addr = addr;
#if 0 //(KERNEL_VERSION(4, 16, 0) > LINUX_VERSION_CODE)
	struct gpio_desc *en8801s_reset;
	int err = 0;
#endif

	glpriv.count = 0;
	glpriv.first_init = true;

#if 0 //(KERNEL_VERSION(4, 16, 0) > LINUX_VERSION_CODE)
	/* Assert the optional reset signal */
	en8801s_reset = gpiod_get_optional(&phydev->dev,
				"reset", GPIOD_OUT_HIGH);
	err = PTR_ERR_OR_ZERO(en8801s_reset);
	if (err) {
		dev_dbg(phydev_dev(phydev),
				"PHY %lx have no reset pin in device tree.\n",
				phy_addr);
	} else {
		dev_dbg(phydev_dev(phydev),
				"Assert PHY %lx HWRST until config_init\n",
				phy_addr);
		glpriv.hw_reset = en8801s_reset;
	}

#endif
	return 0;
}


int en8801s_init(struct mii_dev *bus, int addr)
{
	int ret;
	bk_addr = addr;
	ret = en8801s_probe(bus, addr);
	ret = en8801s_phase1_init(bus, addr);
	if (ret == 0 && glpriv.pro_version != 4) {
		mdelay(800);
		en8801s_phase2_init(bus, addr);
		//mdelay(100);
		phystate = PHY_STATE_PROCESS;
	}
	return ret;
}
